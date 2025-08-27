

import 'package:pangpang_app/core/result.dart';
import 'package:pangpang_app/place/domain/entity/hospital_entity.dart';
import 'package:pangpang_app/place/domain/entity/place_entity.dart';

abstract class PlaceRepository {
  Future<Result<List<PlaceEntity>>> getMyPlaces();
  Future<Result<PlaceEntity>> getPlaceById(int id);
  Future<Result<PlaceEntity>> addFavoritePlace(PlaceEntity place);
  Future<Result<void>> deleteFavoritePlace(int id);
  Future<Result<List<AnimalHospitalEntity>>> getAnimalHospitals();
}