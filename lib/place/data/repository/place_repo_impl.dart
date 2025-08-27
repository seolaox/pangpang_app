import 'package:pangpang_app/core/excetions.dart';
import 'package:pangpang_app/core/result.dart';
import 'package:pangpang_app/place/data/datasource/place_datasource.dart';
import 'package:pangpang_app/place/data/model/place_model.dart';
import 'package:pangpang_app/place/domain/entity/hospital_entity.dart';
import 'package:pangpang_app/place/domain/entity/place_entity.dart';
import 'package:pangpang_app/place/domain/repository/place_repository.dart';

class PlaceRepositoryImpl implements PlaceRepository {
  final PlaceRemoteDataSource remoteDataSource;

  PlaceRepositoryImpl(this.remoteDataSource);

  //공통으로 에러 처리하기
  Future<Result<T>> _executeWithErrorHandling<T>(
    Future<T> Function() operation,
  ) async {
    try {
      final result = await operation();
      return Result.success(result);
    } on ServerException catch (e) {
      return Result.failure(e.message);
    } on NetworkException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('알 수 없는 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<Result<List<PlaceEntity>>> getMyPlaces() async {
    return _executeWithErrorHandling<List<PlaceEntity>>(() async {
      final places = await remoteDataSource.getMyPlaces();
      return places.cast<PlaceEntity>();
    });
  }

  @override
  Future<Result<PlaceEntity>> getPlaceById(int id) async {
    return _executeWithErrorHandling<PlaceEntity>(() async {
      return await remoteDataSource.getPlaceById(id);
    });
  }

  @override
  Future<Result<PlaceEntity>> addFavoritePlace(PlaceEntity place) async {
    return _executeWithErrorHandling<PlaceEntity>(() async {
      final placeModel = PlaceModel.fromEntity(place);
      return await remoteDataSource.addFavoritePlace(placeModel);
    });
  }

  @override
  Future<Result<void>> deleteFavoritePlace(int id) async {
    return _executeWithErrorHandling<void>(() async {
      await remoteDataSource.deleteFavoritePlace(id);
    });
  }

  @override
  Future<Result<List<AnimalHospitalEntity>>> getAnimalHospitals() async {
    return _executeWithErrorHandling<List<AnimalHospitalEntity>>(() async {
      final hospitals = await remoteDataSource.getAnimalHospitals();
      return hospitals.cast<AnimalHospitalEntity>();
    });
  }
}