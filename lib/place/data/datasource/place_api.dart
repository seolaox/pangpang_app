import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pangpang_app/place/core/excetions.dart';
import 'package:pangpang_app/place/data/model/hospital_model.dart';
import 'package:pangpang_app/place/data/model/place_model.dart';
import 'package:pangpang_app/util/api_endpoint.dart';

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

  @override
  Future<List<PlaceModel>> getMyPlaces() async {
    final url = '$baseUrl${ApiEndpoint.getPlaces}';

    try {
      // TokenInterceptor가 자동으로 토큰을 추가하므로 별도 설정 불필요
      final response = await dio.get(url);
      
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
      final response = await dio.get(url);
      
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
      final response = await dio.post(
        url,
        data: place.toCreateJson(),
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
      final response = await dio.delete(url);
      
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
      // 동물병원 목록은 인증이 필요 없으므로 그대로 유지
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