import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/place/data/datasource/place_api.dart';
import 'package:pangpang_app/place/data/repository/place_repo_impl.dart';
import 'package:pangpang_app/place/domain/entity/hospital_entity.dart';
import 'package:pangpang_app/place/domain/entity/place_entity.dart';
import 'package:pangpang_app/place/domain/usecase/add_favorite.dart';
import 'package:pangpang_app/place/domain/usecase/delete_favorite.dart';
import 'package:pangpang_app/place/domain/usecase/get_my_place.dart';
import 'package:pangpang_app/place/domain/usecase/hospital_usecase.dart';
import 'package:pangpang_app/place/presentaion/dio_client.dart';
import 'package:pangpang_app/util/token_manager.dart';

final dioProvider = Provider<Dio>((ref) => DioClient().dio);

// DataSource Provider
final placeRemoteDataSourceProvider = Provider<PlaceRemoteDataSource>((ref) {
  return PlaceRemoteDataSourceImpl(ref.watch(dioProvider));
});

// Repository Provider
final placeRepositoryProvider = Provider((ref) {
  return PlaceRepositoryImpl(ref.watch(placeRemoteDataSourceProvider));
});

// UseCase Providers
final getAnimalHospitalsUseCaseProvider = Provider((ref) {
  return GetAnimalHospitalsUseCase(ref.watch(placeRepositoryProvider));
});

final addFavoritePlaceUseCaseProvider = Provider((ref) {
  return AddFavoritePlaceUseCase(ref.watch(placeRepositoryProvider));
});

final deleteFavoritePlaceUseCaseProvider = Provider((ref) {
  return DeleteFavoritePlaceUseCase(ref.watch(placeRepositoryProvider));
});

final getMyPlacesUseCaseProvider = Provider((ref) {
  return GetMyPlacesUseCase(ref.watch(placeRepositoryProvider));
});

// State Providers
final animalHospitalsProvider = StateNotifierProvider<AnimalHospitalsNotifier, AsyncValue<List<AnimalHospitalEntity>>>((ref) {
  return AnimalHospitalsNotifier(
    ref.watch(getAnimalHospitalsUseCaseProvider),
    ref.watch(addFavoritePlaceUseCaseProvider),
    ref.watch(deleteFavoritePlaceUseCaseProvider),
    ref.watch(getMyPlacesUseCaseProvider),
  );
});

final myPlacesProvider = StateNotifierProvider<MyPlacesNotifier, AsyncValue<List<PlaceEntity>>>((ref) {
  return MyPlacesNotifier(ref.watch(getMyPlacesUseCaseProvider));
});

// State Notifiers
class AnimalHospitalsNotifier extends StateNotifier<AsyncValue<List<AnimalHospitalEntity>>> {
  final GetAnimalHospitalsUseCase _getAnimalHospitalsUseCase;
  final AddFavoritePlaceUseCase _addFavoritePlaceUseCase;
  final DeleteFavoritePlaceUseCase _deleteFavoritePlaceUseCase;
  final GetMyPlacesUseCase _getMyPlacesUseCase;

  // 즐겨찾기 ID 매핑을 위한 Map
  final Map<String, int> _favoriteIdMap = {};

  AnimalHospitalsNotifier(
    this._getAnimalHospitalsUseCase,
    this._addFavoritePlaceUseCase,
    this._deleteFavoritePlaceUseCase,
    this._getMyPlacesUseCase,
  ) : super(const AsyncValue.loading());

  Future<void> loadAnimalHospitals() async {
    state = const AsyncValue.loading();
    final result = await _getAnimalHospitalsUseCase();
    
    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (hospitals) {
        state = AsyncValue.data(hospitals);
        _updateFavoriteIdMap(hospitals);
      },
    );
  }

  void _updateFavoriteIdMap(List<AnimalHospitalEntity> hospitals) async {
    final favoritesResult = await _getMyPlacesUseCase();
    favoritesResult.fold(
      (error) {}, // 에러 무시
      (favorites) {
        _favoriteIdMap.clear();
        for (final favorite in favorites) {
          if (favorite.id != null) {
            final key = '${favorite.pname}_${favorite.paddress}';
            _favoriteIdMap[key] = favorite.id!;
          }
        }
      },
    );
  }

Future<void> toggleFavorite(AnimalHospitalEntity hospital) async {
  // 토큰 확인
  final token = await TokenManager.getAccessToken();
  if (token == null || token.isEmpty) {
    throw Exception('로그인이 필요합니다');
  }

  final currentHospitals = state.asData?.value ?? [];
  final hospitalKey = '${hospital.name}_${hospital.address}';
  
  try {
    if (hospital.isFavorite) {
      // 즐겨찾기 해제
      final favoriteId = _favoriteIdMap[hospitalKey];
      if (favoriteId != null) {
        final result = await _deleteFavoritePlaceUseCase(favoriteId);
        result.fold(
          (error) => throw Exception(error),
          (_) {
            _favoriteIdMap.remove(hospitalKey);
          },
        );
      }
    } else {
      // 즐겨찾기 추가
      final result = await _addFavoritePlaceUseCase(hospital);
      result.fold(
        (error) {
          if (error.contains('이미 즐겨찾기에 등록된')) {
            // 409 에러인 경우 - 이미 즐겨찾기 상태로 처리
            print('이미 즐겨찾기에 등록된 장소입니다.');
            // UI에서는 즐겨찾기 상태로 변경
          } else {
            throw Exception(error);
          }
        },
        (place) {
          if (place.id != null) {
            _favoriteIdMap[hospitalKey] = place.id!;
          }
        },
      );
    }
    
    // UI 상태 즉시 업데이트
    final updatedHospitals = currentHospitals.map((h) {
      if (h.name == hospital.name && h.address == hospital.address) {
        return h.copyWith(isFavorite: !h.isFavorite);
      }
      return h;
    }).toList();
    
    state = AsyncValue.data(updatedHospitals);
  } catch (e) {
    // 409 에러가 아닌 경우만 상태 복원
    if (!e.toString().contains('이미 즐겨찾기에 등록된')) {
      state = AsyncValue.data(currentHospitals);
    }
    rethrow;
  }
}
}

class MyPlacesNotifier extends StateNotifier<AsyncValue<List<PlaceEntity>>> {
  final GetMyPlacesUseCase _getMyPlacesUseCase;

  MyPlacesNotifier(this._getMyPlacesUseCase) : super(const AsyncValue.loading());

  Future<void> loadMyPlaces() async {
    state = const AsyncValue.loading();
    final result = await _getMyPlacesUseCase();
    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (places) => state = AsyncValue.data(places),
    );
  }
}