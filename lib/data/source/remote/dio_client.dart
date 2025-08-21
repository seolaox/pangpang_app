import 'package:dio/dio.dart';
import 'package:pangpang_app/data/source/remote/auth/dio_intercepter.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  late final Dio _dio;

  Dio get dio => _dio;

  void init({required String baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 토큰 자동 갱신 인터셉터 추가 (가장 먼저)
    _dio.interceptors.add(TokenInterceptor(_dio));

    // 로깅 인터셉터 추가
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: false,
        responseHeader: false,
      ),
    );

    // 에러 인터셉터 (TokenInterceptor 이후에 실행됨)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          // 전역 에러 처리
          print('DioError: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }
}