import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/place/domain/entity/hospital_entity.dart';
import 'package:pangpang_app/place/domain/entity/place_entity.dart';
import 'package:pangpang_app/place/domain/usecase/add_favorite.dart';
import 'package:pangpang_app/place/domain/usecase/delete_favorite.dart';
import 'package:pangpang_app/place/domain/usecase/get_my_place.dart';
import 'package:pangpang_app/place/domain/usecase/hospital_usecase.dart';
import 'package:pangpang_app/place/domain/usecase/search_hospital.dart';
import 'package:pangpang_app/place/presentaion/place_vm.dart';
import 'package:pangpang_app/util/token_manager.dart';


//전체보기 모드 상태 Provider
final showAllHospitalsProvider = StateProvider<bool>((ref) => false);

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

// 병원 검색 Provider 
final hospitalSearchProvider = StateNotifierProvider<HospitalSearchNotifier, AsyncValue<List<AnimalHospitalEntity>>>((ref) {
  return HospitalSearchNotifier(
    ref.watch(searchHospitalsUseCaseProvider),
  );
});

// State Notifiers ------------------------------------
class AnimalHospitalsNotifier extends StateNotifier<AsyncValue<List<AnimalHospitalEntity>>> {
  final GetAnimalHospitalsUseCase _getAnimalHospitalsUseCase;
  final AddFavoritePlaceUseCase _addFavoritePlaceUseCase;
  final DeleteFavoritePlaceUseCase _deleteFavoritePlaceUseCase;
  final GetMyPlacesUseCase _getMyPlacesUseCase;

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
    final token = await TokenManager.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('로그인이 필요합니다');
    }

    final currentHospitals = state.asData?.value ?? [];
    final hospitalKey = '${hospital.name}_${hospital.address}';
    
    try {
      if (hospital.isFavorite) {
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
        final result = await _addFavoritePlaceUseCase(hospital);
        result.fold(
          (error) {
            if (error.contains('이미 즐겨찾기에 등록된')) {
              print('이미 즐겨찾기에 등록된 장소입니다.');
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
      
      final updatedHospitals = currentHospitals.map((h) {
        if (h.name == hospital.name && h.address == hospital.address) {
          return h.copyWith(isFavorite: !h.isFavorite);
        }
        return h;
      }).toList();
      
      state = AsyncValue.data(updatedHospitals);
    } catch (e) {
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

// 병원 검색 StateNotifier
class HospitalSearchNotifier extends StateNotifier<AsyncValue<List<AnimalHospitalEntity>>> {
  final SearchHospitalsUseCase _searchUseCase;
  
  String _currentQuery = '';
  List<AnimalHospitalEntity> _allHospitals = [];

  HospitalSearchNotifier(this._searchUseCase) : super(const AsyncValue.loading());

  String get currentQuery => _currentQuery;
  bool get hasSearchResults => _currentQuery.isNotEmpty;
  int get totalHospitals => _allHospitals.length;

  Future<void> loadAllHospitals() async {
    state = const AsyncValue.loading();
    
    final result = await _searchUseCase.searchHospitals('');
    
    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (hospitals) {
        _allHospitals = hospitals;
        state = AsyncValue.data(hospitals);
      },
    );
  }

  Future<void> search(String query) async {
    _currentQuery = query.trim();
    
    if (_currentQuery.isEmpty) {
      state = AsyncValue.data(_allHospitals);
      return;
    }

    state = const AsyncValue.loading();
    
    final result = await _searchUseCase.searchHospitals(_currentQuery);
    
    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (filteredHospitals) => state = AsyncValue.data(filteredHospitals),
    );
  }

  void clearSearch() {
    _currentQuery = '';
    state = AsyncValue.data(_allHospitals);
  }

  AnimalHospitalEntity? findHospital({String? name}) {
    final hospitals = state.asData?.value ?? [];
    
    if (name != null) {
      return hospitals.where((h) => h.name == name).firstOrNull;
    }
    
    return null;
  }
}

