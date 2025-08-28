import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/place/presentaion/place_vm.dart';
import 'package:pangpang_app/place/domain/entity/place_entity.dart';
import 'package:pangpang_app/place/domain/entity/hospital_entity.dart';
import 'package:pangpang_app/place/presentaion/place_provider.dart';
import 'package:pangpang_app/place/widget/hospital_bottomsheet.dart';

class FavoriteListBottomSheet extends ConsumerStatefulWidget {
  const FavoriteListBottomSheet({super.key});

  @override
  ConsumerState<FavoriteListBottomSheet> createState() => _FavoriteListBottomSheetState();
}

class _FavoriteListBottomSheetState extends ConsumerState<FavoriteListBottomSheet> {
  @override
  void initState() {
    super.initState();
    // 즐겨찾기 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myPlacesProvider.notifier).loadMyPlaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    final myPlacesState = ref.watch(myPlacesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.favorite,
                  size: 24,
                  color: Colors.red
                ),
                const SizedBox(width: 12),
                const Text(
                  '즐겨찾기 목록',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    ref.read(myPlacesProvider.notifier).loadMyPlaces();
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: '새로고침',
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          Expanded(
            child: myPlacesState.when(
              data: (places) {
                if (places.isEmpty) {
                  return _EmptyState();
                }
                return _PlacesList(places);
              },
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('즐겨찾기 목록을 불러오는 중...'),
                  ],
                ),
              ),
              error: (error, _) => _ErrorState(error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _EmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '즐겨찾기한 동물병원이 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '지도에서 동물병원을 선택하고\n찜하기 버튼을 눌러 즐겨찾기에 추가해보세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            '목록을 불러올 수 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.contains('로그인') 
                ? '로그인이 필요한 기능입니다'
                : '네트워크 연결을 확인해주세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(myPlacesProvider.notifier).loadMyPlaces();
            },
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _PlacesList(List<PlaceEntity> places) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: places.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final place = places[index];
        return _PlaceCard(place);
      },
    );
  }

  Widget _PlaceCard(PlaceEntity place) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showPlaceDetail(place),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        place.pname.isNotEmpty ? place.pname : '이름 없음',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _confirmDelete(place);
                        } else if (value == 'map') {
                          _moveToPlaceOnMap(place);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'map',
                          child: Row(
                            children: [
                              Icon(Icons.map, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('지도에서 보기'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red),
                              SizedBox(width: 8),
                              Text('삭제'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (place.pphone.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 16,
                        color:  Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          place.pphone,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color:  Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        place.paddress.isNotEmpty ? place.paddress : '주소 정보 없음',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  //공통 바텀시트 사용하기 위해 객체 변환 / 필드 맵핑
  void _showPlaceDetail(PlaceEntity place) {
    final hospital = AnimalHospitalEntity(
      name: place.pname,
      address: place.paddress,
      phone: place.pphone,
      latitude: place.latitude ?? 0.0,
      longitude: place.longitude ?? 0.0,
      isFavorite: true, // 즐겨찾기에서 온 것이므로 true
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommonHospitalBottomSheet(
        hospital: hospital,
        onMapMove: () => _moveToPlaceOnMap(place),
      ),
    );
  }

  // 지도에서 해당 장소로 이동
  void _moveToPlaceOnMap(PlaceEntity place) {
    if (place.latitude == null || place.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('위치 정보가 없어 지도에서 보여줄 수 없습니다'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final hospital = AnimalHospitalEntity(
      name: place.pname,
      address: place.paddress,
      phone: place.pphone,
      latitude: place.latitude!,
      longitude: place.longitude!,
      isFavorite: true,
    );

    // 지도 위젯 등에서 selectedHospitalProvider를 선택된 병원으로 인식
    ref.read(selectedHospitalProvider.notifier).state = hospital;
    
    // 바텀시트 닫기
    Navigator.pop(context);
    
    print('지도에서 ${place.pname} 위치로 이동: ${place.latitude}, ${place.longitude}');
  }

  void _confirmDelete(PlaceEntity place) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('즐겨찾기 삭제'),
        content: Text('${place.pname}을(를) 즐겨찾기에서 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePlace(place);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePlace(PlaceEntity place) async {
    if (place.id == null) return;
    
    try {
      final result = await ref
          .read(deleteFavoritePlaceUseCaseProvider)
          .call(place.id!);
      
      result.fold(
        (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('삭제 실패: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('즐겨찾기에서 삭제되었습니다'),
                backgroundColor: Colors.green,
              ),
            );
          }
          // 목록 새로고침
          ref.read(myPlacesProvider.notifier).loadMyPlaces();
          ref.read(animalHospitalsProvider.notifier).loadAnimalHospitals();
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}