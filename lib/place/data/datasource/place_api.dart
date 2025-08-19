import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pangpang_app/place/core/excetions.dart';
import 'package:pangpang_app/place/data/model/hospital_model.dart';
import 'package:pangpang_app/place/data/model/place_model.dart';
import 'package:pangpang_app/util/api_endpoint.dart';
import 'package:pangpang_app/util/token_manager.dart';  // 토큰 매니저 추가

abstract class PlaceRemoteDataSource {
  Future<List<PlaceModel>> getMyPlaces();
  Future<PlaceModel> getPlaceById(int id);
  Future<PlaceModel> addFavoritePlace(PlaceModel place);
  Future<void> deleteFavoritePlace(int id);
  Future<List<AnimalHospitalModel>> getAnimalHospitals();
}

class PlaceRemoteDataSourceImpl implements PlaceRemoteDataSource {
  final Dio dio;

  String? baseUrl = dotenv.env['baseurl'];

  PlaceRemoteDataSourceImpl(this.dio);

  // 인증 헤더를 추가하는 헬퍼 메소드
Future<Options?> _getAuthOptions() async {
  try {
    final token = await TokenManager.getAccessToken();
    if (token == null || token.isEmpty) {
      return null; // 토큰이 없으면 null 반환
    }
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  } catch (e) {
    print('토큰 조회 오류: $e');
    return null;
  }
}


@override
Future<List<PlaceModel>> getMyPlaces() async {
  final url = '$baseUrl${ApiEndpoint.getPlaces}';

  try {
    final options = await _getAuthOptions();
    if (options == null) {
      throw const ServerException(message: '로그인이 필요합니다');
    }
    
    final response = await dio.get(url, options: options);
    
    if (response.statusCode == 200) {
      final data = response.data;
      final places = (data['places'] as List)
          .map((json) => PlaceModel.fromJson(json))
          .toList();
      return places;
    } else {
      throw ServerException(
        message: '즐겨찾기 목록을 불러올 수 없습니다',
        statusCode: response.statusCode,
      );
    }
  } on DioException catch (e) {
    if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
      throw const ServerException(message: '로그인이 필요합니다');
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw const NetworkException('네트워크 연결을 확인해주세요');
    } else {
      throw ServerException(
        message: e.message ?? '서버 오류가 발생했습니다',
        statusCode: e.response?.statusCode,
      );
    }
  } catch (e) {
    throw ServerException(message: '알 수 없는 오류가 발생했습니다: $e');
  }
}

  @override
  Future<PlaceModel> getPlaceById(int placeId) async {
    final url = '$baseUrl${ApiEndpoint.getPlaces}/${placeId}';

    try {
      final options = await _getAuthOptions();
      final response = await dio.get(url, options: options);
      
      if (response.statusCode == 200) {
        return PlaceModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: '장소 정보를 불러올 수 없습니다',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw const ServerException(message: '로그인이 필요합니다');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('네트워크 연결을 확인해주세요');
      } else {
        throw ServerException(
          message: e.message ?? '서버 오류가 발생했습니다',
          statusCode: e.response?.statusCode,
        );
      }
    }
  }

  @override
Future<PlaceModel> addFavoritePlace(PlaceModel place) async {
  final url = '$baseUrl${ApiEndpoint.getPlaces}';

  try {
    final options = await _getAuthOptions();
    if (options == null) {
      throw const ServerException(message: '로그인이 필요합니다');
    }
    
    final response = await dio.post(
      url,
      data: place.toCreateJson(),
      options: options,
    );
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      return PlaceModel.fromJson(response.data);
    } else {
      throw ServerException(
        message: '즐겨찾기 추가에 실패했습니다',
        statusCode: response.statusCode,
      );
    }
  } on DioException catch (e) {
    if (e.response?.statusCode == 409) {
      // 중복 장소인 경우 - 이미 즐겨찾기에 있다는 의미
      throw const ServerException(message: '이미 즐겨찾기에 등록된 장소입니다');
    }
    if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
      throw const ServerException(message: '로그인이 필요합니다');
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw const NetworkException('네트워크 연결을 확인해주세요');
    } else {
      throw ServerException(
        message: e.message ?? '서버 오류가 발생했습니다',
        statusCode: e.response?.statusCode,
      );
    }
  } catch (e) {
    throw ServerException(message: '알 수 없는 오류가 발생했습니다: $e');
  }
}



  @override
  Future<void> deleteFavoritePlace(int placeId) async {
    final url = '$baseUrl${ApiEndpoint.getPlaces}/${placeId}';

    try {
      final options = await _getAuthOptions();
      final response = await dio.delete(url, options: options);
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: '즐겨찾기 삭제에 실패했습니다',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw const ServerException(message: '로그인이 필요합니다');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('네트워크 연결을 확인해주세요');
      } else {
        throw ServerException(
          message: e.message ?? '서버 오류가 발생했습니다',
          statusCode: e.response?.statusCode,
        );
      }
    }
  }

  @override
  Future<List<AnimalHospitalModel>> getAnimalHospitals() async {
    final url = '$baseUrl${ApiEndpoint.getAnimalHospitals}';

    try {
      // 동물병원 목록은 인증이 필요 없을 수도 있으니, 먼저 인증 없이 시도
      final response = await dio.get(url);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final List<dynamic> hospitals = data['hospitals'] as List<dynamic>;
        return hospitals.map((json) => AnimalHospitalModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: '동물병원 목록을 불러올 수 없습니다',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('네트워크 연결을 확인해주세요');
      } else {
        throw ServerException(
          message: e.message ?? '서버 오류가 발생했습니다',
          statusCode: e.response?.statusCode,
        );
      }
    } catch (e) {
      throw ServerException(message: '알 수 없는 오류가 발생했습니다: $e');
    }
  }
}