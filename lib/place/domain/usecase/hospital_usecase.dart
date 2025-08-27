import 'package:pangpang_app/core/result.dart';
import 'package:pangpang_app/place/domain/entity/hospital_entity.dart';
import 'package:pangpang_app/place/domain/repository/place_repository.dart';

class GetAnimalHospitalsUseCase {
  final PlaceRepository repository;

  GetAnimalHospitalsUseCase(this.repository);

  Future<Result<List<AnimalHospitalEntity>>> call() async {
    final hospitalsResult = await repository.getAnimalHospitals();

    return hospitalsResult.fold((error) => Result.failure(error), (
      hospitals,
    ) async {
      // 즐겨찾기 상태 확인
      try {
        final favoritesResult = await repository.getMyPlaces();

        return favoritesResult.fold(
          (error) {
            print('즐겨찾기 로드 실패: $error');
            return Result.success(hospitals);
          },
          (favorites) {
            print('즐겨찾기 ${favorites.length}개');

            final updatedHospitals =
                hospitals.map((hospital) {
                  final isFavorite = favorites.any(
                    (fav) =>
                        fav.pname.trim() == hospital.name.trim() &&
                        fav.paddress.trim() == hospital.address.trim(),
                  );
                  return hospital.copyWith(isFavorite: isFavorite);
                }).toList();

            final favoriteCount =
                updatedHospitals.where((h) => h.isFavorite).length;
            print('즐겨찾기 상태 적용된 병원: $favoriteCount개');

            return Result.success(updatedHospitals);
          },
        );
      } catch (e) {
        print('즐겨찾기 상태 확인 중 오류: $e');
        return Result.success(hospitals);
      }
    });
  }
}
