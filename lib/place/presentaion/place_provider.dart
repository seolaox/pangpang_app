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
import 'package:pangpang_app/place/domain/usecase/search_hospital.dart';
import 'package:pangpang_app/data/source/remote/dio_client.dart';
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

//전체보기 모드 상태 Provider
final showAllHospitalsProvider = StateProvider<bool>((ref) => false);

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

// 검색 UseCase Provider
final searchHospitalsUseCaseProvider = Provider((ref) {
  return SearchHospitalsUseCase(ref.watch(placeRepositoryProvider));
});

// 장소 상세 정보 Provider
final placeDetailProvider = StateNotifierProvider.family<PlaceDetailNotifier, AsyncValue<PlaceEntity?>, int>((ref, placeId) {
  return PlaceDetailNotifier(
    ref.watch(searchHospitalsUseCaseProvider),
    placeId,
  );
});

// 검색 결과 Provider (향상된 버전)
final hospitalSearchProvider = StateNotifierProvider<HospitalSearchNotifier, AsyncValue<List<AnimalHospitalEntity>>>((ref) {
  return HospitalSearchNotifier(
    ref.watch(searchHospitalsUseCaseProvider),
  );
});

// 즐겨찾기 검색 Provider
final favoriteSearchProvider = StateNotifierProvider<FavoriteSearchNotifier, AsyncValue<List<PlaceEntity>>>((ref) {
  return FavoriteSearchNotifier(
    ref.watch(searchHospitalsUseCaseProvider),
  );
});

// 검색 상태 Provider들
final searchQueryProvider = StateProvider<String>((ref) => '');
final searchModeProvider = StateProvider<SearchMode>((ref) => SearchMode.hospitals);
final recentSearchesProvider = StateProvider<List<String>>((ref) => []);

// 검색 모드 enum
enum SearchMode {
  hospitals,    // 동물병원 검색
  favorites,    // 즐겨찾기 검색
}

// 장소 상세 정보 관리 StateNotifier
class PlaceDetailNotifier extends StateNotifier<AsyncValue<PlaceEntity?>> {
  final SearchHospitalsUseCase _searchUseCase;
  final int placeId;

  PlaceDetailNotifier(this._searchUseCase, this.placeId) : super(const AsyncValue.loading()) {
    loadPlaceDetail();
  }

  Future<void> loadPlaceDetail() async {
    state = const AsyncValue.loading();
    
    final result = await _searchUseCase.getPlaceDetail(placeId);
    
    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (place) => state = AsyncValue.data(place),
    );
  }

  Future<void> refresh() async {
    await loadPlaceDetail();
  }
}

// 향상된 병원 검색 StateNotifier
class HospitalSearchNotifier extends StateNotifier<AsyncValue<List<AnimalHospitalEntity>>> {
  final SearchHospitalsUseCase _searchUseCase;
  
  String _currentQuery = '';
  List<AnimalHospitalEntity> _allHospitals = [];

  HospitalSearchNotifier(this._searchUseCase) : super(const AsyncValue.loading());

  String get currentQuery => _currentQuery;
  bool get hasSearchResults => _currentQuery.isNotEmpty;
  int get totalHospitals => _allHospitals.length;

  // 초기 병원 목록 로드
  Future<void> loadAllHospitals() async {
    state = const AsyncValue.loading();
    
    final result = await _searchUseCase.searchHospitals(''); // 빈 쿼리로 전체 목록
    
    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (hospitals) {
        _allHospitals = hospitals;
        state = AsyncValue.data(hospitals);
      },
    );
  }

  // 검색 수행
  Future<void> search(String query) async {
    _currentQuery = query.trim();
    
    if (_currentQuery.isEmpty) {
      // 검색어가 없으면 전체 목록 표시
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

  // 검색 초기화
  void clearSearch() {
    _currentQuery = '';
    state = AsyncValue.data(_allHospitals);
  }

  // 특정 병원 찾기 (ID나 이름으로)
  AnimalHospitalEntity? findHospital({int? id, String? name}) {
    final hospitals = state.asData?.value ?? [];
    
    if (id != null) {
      // ID로 찾기는 불가능 (AnimalHospitalEntity에 ID가 없음)
      return null;
    }
    
    if (name != null) {
      return hospitals.where((h) => h.name == name).firstOrNull;
    }
    
    return null;
  }
}

// 즐겨찾기 검색 StateNotifier
class FavoriteSearchNotifier extends StateNotifier<AsyncValue<List<PlaceEntity>>> {
  final SearchHospitalsUseCase _searchUseCase;
  
  String _currentQuery = '';
  List<PlaceEntity> _allFavorites = [];

  FavoriteSearchNotifier(this._searchUseCase) : super(const AsyncValue.loading());

  String get currentQuery => _currentQuery;
  bool get hasSearchResults => _currentQuery.isNotEmpty;
  int get totalFavorites => _allFavorites.length;

  // 즐겨찾기 목록 로드
  Future<void> loadAllFavorites() async {
    state = const AsyncValue.loading();
    
    final result = await _searchUseCase.searchMyPlaces(''); // 빈 쿼리로 전체 목록
    
    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (favorites) {
        _allFavorites = favorites;
        state = AsyncValue.data(favorites);
      },
    );
  }

  // 즐겨찾기 검색
  Future<void> search(String query) async {
    _currentQuery = query.trim();
    
    if (_currentQuery.isEmpty) {
      state = AsyncValue.data(_allFavorites);
      return;
    }

    state = const AsyncValue.loading();
    
    final result = await _searchUseCase.searchMyPlaces(_currentQuery);
    
    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (filteredFavorites) => state = AsyncValue.data(filteredFavorites),
    );
  }

  // 검색 초기화
  void clearSearch() {
    _currentQuery = '';
    state = AsyncValue.data(_allFavorites);
  }

  // 특정 즐겨찾기 상세 정보 가져오기
  Future<PlaceEntity?> getPlaceDetail(int placeId) async {
    final result = await _searchUseCase.getPlaceDetail(placeId);
    
    return result.fold(
      (error) {
        print('장소 상세 정보 로드 실패: $error');
        return null;
      },
      (place) => place,
    );
  }
}

