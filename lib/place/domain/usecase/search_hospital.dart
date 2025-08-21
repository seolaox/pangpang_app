import 'package:pangpang_app/place/core/result.dart';
import 'package:pangpang_app/place/domain/entity/hospital_entity.dart';
import 'package:pangpang_app/place/domain/entity/place_entity.dart';
import 'package:pangpang_app/place/domain/repository/place_repository.dart';

class SearchHospitalsUseCase {
  final PlaceRepository repository;

  SearchHospitalsUseCase(this.repository);

  // 검색어가 포함되는지 확인 (공백 제거 후 정확한 포함 검색)
  bool _containsQuery(String text, String query) {
    // 공백과 특수문자를 제거하고 소문자로 변환
    final cleanText = text.replaceAll(RegExp(r'[\s\-\·\.\,\(\)]'), '').toLowerCase();
    final cleanQuery = query.replaceAll(RegExp(r'[\s\-\·\.\,\(\)]'), '').toLowerCase();
    
    // 정확한 문자열 포함 여부 확인
    return cleanText.contains(cleanQuery);
  }

  // 동물병원 검색 (클라이언트 사이드)강남
  Future<Result<List<AnimalHospitalEntity>>> searchHospitals(String query) async {
    try {
      // 전체 동물병원 목록 가져오기
      final hospitalsResult = await repository.getAnimalHospitals();
      
      return hospitalsResult.fold(
        (error) => Result.failure(error),
        (hospitals) {
          if (query.trim().isEmpty) {
            return Result.success(hospitals);
          }
          
          final trimmedQuery = query.trim();
          
          // 이름에 검색어가 포함된 것만 검색
          final filteredHospitals = hospitals.where((hospital) {
            return _containsQuery(hospital.name, trimmedQuery);
          }).toList();
          
          // 검색 결과를 관련성 순으로 정렬
          filteredHospitals.sort((a, b) {
            final lowercaseQuery = trimmedQuery.toLowerCase();
            
            // 이름이 정확히 일치하는 것을 최우선
            final aExactNameMatch = a.name.toLowerCase() == lowercaseQuery;
            final bExactNameMatch = b.name.toLowerCase() == lowercaseQuery;
            
            if (aExactNameMatch && !bExactNameMatch) return -1;
            if (!aExactNameMatch && bExactNameMatch) return 1;
            
            // 이름에서 시작하는 것을 우선순위로
            final aNameMatch = a.name.toLowerCase().startsWith(lowercaseQuery);
            final bNameMatch = b.name.toLowerCase().startsWith(lowercaseQuery);
            
            if (aNameMatch && !bNameMatch) return -1;
            if (!aNameMatch && bNameMatch) return 1;
            
            // 그 다음 이름 길이 순 (짧은 것이 더 관련성 높음)
            return a.name.length.compareTo(b.name.length);
          });
          
          return Result.success(filteredHospitals);
        },
      );
    } catch (e) {
      return Result.failure('검색 중 오류가 발생했습니다: $e');
    }
  }

  // 특정 장소 상세 정보 가져오기 (getPlaceById API 활용)
  Future<Result<PlaceEntity>> getPlaceDetail(int placeId) async {
    try {
      final result = await repository.getPlaceById(placeId);
      return result;
    } catch (e) {
      return Result.failure('장소 상세 정보를 불러올 수 없습니다: $e');
    }
  }

  // 즐겨찾기 목록에서 검색
  Future<Result<List<PlaceEntity>>> searchMyPlaces(String query) async {
    try {
      final placesResult = await repository.getMyPlaces();
      
      return placesResult.fold(
        (error) => Result.failure(error),
        (places) {
          if (query.trim().isEmpty) {
            return Result.success(places);
          }
          
          final trimmedQuery = query.trim();
          
          final filteredPlaces = places.where((place) {
            return _containsQuery(place.pname, trimmedQuery);
          }).toList();
          
          // // 관련성 순으로 정렬
          // filteredPlaces.sort((a, b) {
          //   final lowercaseQuery = trimmedQuery.toLowerCase();
            
          //   // 이름이 정확히 일치하는 것을 최우선
          //   final aExactNameMatch = a.pname.toLowerCase() == lowercaseQuery;
          //   final bExactNameMatch = b.pname.toLowerCase() == lowercaseQuery;
            
          //   if (aExactNameMatch && !bExactNameMatch) return -1;
          //   if (!aExactNameMatch && bExactNameMatch) return 1;
            
          //   final aNameMatch = a.pname.toLowerCase().startsWith(lowercaseQuery);
          //   final bNameMatch = b.pname.toLowerCase().startsWith(lowercaseQuery);
            
          //   if (aNameMatch && !bNameMatch) return -1;
          //   if (!aNameMatch && bNameMatch) return 1;
            
          //   return a.pname.length.compareTo(b.pname.length);
          // });
          
          return Result.success(filteredPlaces);
        },
      );
    } catch (e) {
      return Result.failure('즐겨찾기 검색 중 오류가 발생했습니다: $e');
    }
  }

  // 최근 검색한 장소들의 상세 정보 가져오기
  Future<Result<List<PlaceEntity>>> getRecentPlacesDetails(List<int> placeIds) async {
    try {
      final List<PlaceEntity> places = [];
      
      for (final placeId in placeIds) {
        final result = await repository.getPlaceById(placeId);
        result.fold(
          (error) {
            print('장소 ID $placeId 로드 실패: $error');
          },
          (place) {
            places.add(place);
          },
        );
      }
      
      return Result.success(places);
    } catch (e) {
      return Result.failure('최근 장소 정보를 불러올 수 없습니다: $e');
    }
  }
}