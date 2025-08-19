import 'package:pangpang_app/place/core/result.dart';
import 'package:pangpang_app/place/domain/entity/hospital_entity.dart';
import 'package:pangpang_app/place/domain/entity/place_entity.dart';
import 'package:pangpang_app/place/domain/repository/place_repository.dart';

class AddFavoritePlaceUseCase {
  final PlaceRepository repository;

  AddFavoritePlaceUseCase(this.repository);

  Future<Result<PlaceEntity>> call(AnimalHospitalEntity hospital) async {
    final place = PlaceEntity(
      pname: hospital.name,
      pphone: hospital.phone,
      paddress: hospital.address,
      latitude: hospital.latitude,
      longitude: hospital.longitude,
    );

    return await repository.addFavoritePlace(place);
  }
}