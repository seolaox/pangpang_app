import 'package:pangpang_app/place/core/result.dart';
import 'package:pangpang_app/place/domain/repository/place_repository.dart';

class DeleteFavoritePlaceUseCase {
  final PlaceRepository repository;

  DeleteFavoritePlaceUseCase(this.repository);

  Future<Result<void>> call(int placeId) async {
    return await repository.deleteFavoritePlace(placeId);
  }
}