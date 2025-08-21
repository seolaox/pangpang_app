import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/util/api_endpoint.dart';
import 'package:pangpang_app/util/token_manager.dart';

class TokenInterceptor extends Interceptor {
  final Dio _dio;
  final String? baseUrl = dotenv.env['baseurl'];
  final ProviderContainer? _providerContainer;
  
  // 토큰 갱신 중인지 확인하는 플래그
  bool _isRefreshing = false;
  final List<Completer<String?>> _refreshCompleters = [];
  
  TokenInterceptor(this._dio, [this._providerContainer]);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 로그인과 토큰 갱신 API는 토큰 없이 호출
    if (options.path.contains('user/login') || 
        options.path.contains('api/auth/refresh') ||
        options.path.contains('auth/refresh')) {
      handler.next(options);
      return;
    }

    // 토큰이 필요한 API에 자동으로 토큰 추가
    final token = await TokenManager.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 에러 (토큰 만료)인 경우에만 토큰 갱신 시도
    if (err.response?.statusCode == 401) {
      print('토큰 만료 감지, 토큰 갱신 시도...');
      
      // 토큰 갱신 API 자체의 401 에러는 처리하지 않음
      if (err.requestOptions.path.contains('api/auth/refresh') ||
          err.requestOptions.path.contains('auth/refresh')) {
        print('토큰 갱신 API 자체가 401 - 로그아웃 처리');
        await _handleTokenRefreshFailure();
        handler.next(err);
        return;
      }
      
      // 이미 토큰 갱신 중이면 대기
      if (_isRefreshing) {
        final completer = Completer<String?>();
        _refreshCompleters.add(completer);
        
        try {
          final newToken = await completer.future;
          
          if (newToken != null) {
            await _retryWithNewToken(err, handler, newToken);
            return;
          }
        } catch (e) {
          print('대기 중 에러: $e');
        }
        
        handler.next(err);
        return;
      }
      
      _isRefreshing = true;
      
      try {
        final newToken = await _refreshToken();
        
        // 대기 중인 요청들에 새 토큰 전달
        for (final completer in _refreshCompleters) {
          if (!completer.isCompleted) {
            completer.complete(newToken);
          }
        }
        _refreshCompleters.clear();
        
        if (newToken != null) {
          await _retryWithNewToken(err, handler, newToken);
          return;
        } else {
          await _handleTokenRefreshFailure();
        }
      } catch (e) {
        print('토큰 갱신 중 에러: $e');
        await _handleTokenRefreshFailure();
        
        // 대기 중인 요청들에 실패 알림
        for (final completer in _refreshCompleters) {
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        }
        _refreshCompleters.clear();
      } finally {
        _isRefreshing = false;
      }
    }
    
    handler.next(err);
  }

  Future<void> _retryWithNewToken(
    DioException err, 
    ErrorInterceptorHandler handler, 
    String newToken
  ) async {
    final retryOptions = err.requestOptions;
    retryOptions.headers['Authorization'] = 'Bearer $newToken';
    
    try {
      print('새 토큰으로 요청 재시도: ${retryOptions.path}');
      final retryResponse = await _dio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } catch (e) {
      print('재시도 요청 실패: $e');
      handler.next(err);
    }
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await TokenManager.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        print('리프레시 토큰이 없습니다');
        return null;
      }

      print('토큰 갱신 요청 시작...');
      
      // 새로운 Dio 인스턴스로 토큰 갱신 요청 (인터셉터 중복 호출 방지)
      final refreshDio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      
      final response = await refreshDio.post(
        '$baseUrl${ApiEndpoint.getRefresh}',
        data: {
          'refresh_token': refreshToken,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print('토큰 갱신 응답: ${response.statusCode}');
      print('토큰 갱신 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final newAccessToken = data['access_token'] as String?;
        // 서버 응답에 refresh_token이 없으므로 기존 것 유지
        
        if (newAccessToken != null) {
          // 새 액세스 토큰만 저장, 리프레시 토큰은 기존 것 유지
          await TokenManager.saveTokens(
            accessToken: newAccessToken,
            refreshToken: refreshToken,
          );
          
          print('토큰 갱신 성공');
          return newAccessToken;
        } else {
          print('응답에 access_token이 없습니다');
        }
      } else {
        print('토큰 갱신 응답 오류: ${response.statusCode}');
      }
      
      return null;
    } catch (e) {
      print('토큰 갱신 요청 실패: $e');
      if (e is DioException) {
        print('에러 응답: ${e.response?.data}');
        print('에러 상태코드: ${e.response?.statusCode}');
      }
      return null;
    }
  }

  Future<void> _handleTokenRefreshFailure() async {
    print('토큰 갱신 실패 - 모든 토큰 삭제');
    await TokenManager.clearTokens();
    
    // Provider 상태도 초기화
    if (_providerContainer != null) {
      try {
        // accessTokenProvider의 상태 초기화
        // _providerContainer!.read(accessTokenProvider.notifier).clearToken();
      } catch (e) {
        print('Provider 상태 초기화 실패: $e');
      }
    }
  }
}