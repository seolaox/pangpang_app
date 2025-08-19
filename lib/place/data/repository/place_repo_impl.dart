import 'package:pangpang_app/place/core/excetions.dart';
import 'package:pangpang_app/place/core/result.dart';
import 'package:pangpang_app/place/data/datasource/place_api.dart';
import 'package:pangpang_app/place/data/model/place_model.dart';
import 'package:pangpang_app/place/domain/entity/hospital_entity.dart';
import 'package:pangpang_app/place/domain/entity/place_entity.dart';
import 'package:pangpang_app/place/domain/repository/place_repository.dart';

class PlaceRepositoryImpl implements PlaceRepository {
  final PlaceRemoteDataSource remoteDataSource;

  PlaceRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<PlaceEntity>>> getMyPlaces() async {
    try {
      final places = await remoteDataSource.getMyPlaces();
      return Result.success(places.cast<PlaceEntity>());
    } on ServerException catch (e) {
      return Result.failure(e.message);
    } on NetworkException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('알 수 없는 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<Result<PlaceEntity>> getPlaceById(int id) async {
    try {
      final place = await remoteDataSource.getPlaceById(id);
      return Result.success(place);
    } on ServerException catch (e) {
      return Result.failure(e.message);
    } on NetworkException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('알 수 없는 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<Result<PlaceEntity>> addFavoritePlace(PlaceEntity place) async {
    try {
      final placeModel = PlaceModel.fromEntity(place);
      final result = await remoteDataSource.addFavoritePlace(placeModel);
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
  Future<Result<void>> deleteFavoritePlace(int id) async {
    try {
      await remoteDataSource.deleteFavoritePlace(id);
      return Result.success(null);
    } on ServerException catch (e) {
      return Result.failure(e.message);
    } on NetworkException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('알 수 없는 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<Result<List<AnimalHospitalEntity>>> getAnimalHospitals() async {
    try {
      final hospitals = await remoteDataSource.getAnimalHospitals();
      return Result.success(hospitals.cast<AnimalHospitalEntity>());
    } on ServerException catch (e) {
      return Result.failure(e.message);
    } on NetworkException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('알 수 없는 오류가 발생했습니다: $e');
    }
  }
}