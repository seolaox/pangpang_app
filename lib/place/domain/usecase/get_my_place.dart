import 'package:pangpang_app/place/core/result.dart';
import 'package:pangpang_app/place/domain/entity/place_entity.dart';
import 'package:pangpang_app/place/domain/repository/place_repository.dart';

class GetMyPlacesUseCase {
  final PlaceRepository repository;

  GetMyPlacesUseCase(this.repository);

  Future<Result<List<PlaceEntity>>> call() async {
    return await repository.getMyPlaces();
  }
}