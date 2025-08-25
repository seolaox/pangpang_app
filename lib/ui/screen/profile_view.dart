import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/place/presentaion/place_provider.dart';
import 'package:pangpang_app/place/ui/favorite_bottomsheet.dart';
import 'package:pangpang_app/place/ui/map_widget.dart';
import 'package:pangpang_app/place/ui/searchbar_bottomsheet.dart';
import 'package:pangpang_app/ui/screen/searchbar.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  bool _isSearchMode = false;
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(animalHospitalsProvider.notifier).loadAnimalHospitals();
      ref.read(hospitalSearchProvider.notifier).loadAllHospitals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hospitalsState = ref.watch(animalHospitalsProvider);
    final searchState = ref.watch(hospitalSearchProvider);

    return Scaffold(
      appBar: SearchAppBar(
        onSearch: _handleSearch,
        onShowFavorites: () => _showFavoriteList(context),
      ),
      body: Stack(
        children: [
          // 지도 위젯
          const MapWidget(),
          
          // 검색 결과 오버레이
          if (_isSearchMode && _currentSearchQuery.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 100, // 하단 정보 표시 공간 확보
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 검색 결과 헤더
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            size: 20,
                            color: Colors.blue[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '"$_currentSearchQuery" 검색 결과',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                          searchState.when(
                            data: (results) => Text(
                              '${results.length}개',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[600],
                              ),
                            ),
                            loading: () => const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            error: (_, __) => const Text('오류'),
                          ),
                        ],
                      ),
                    ),
                    
                    // 검색 결과 목록
                    Expanded(
                      child: searchState.when(
                        data: (results) {
                          if (results.isEmpty) {
                            return _buildNoResultsWidget();
                          }
                          return _buildSearchResultsList(results);
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (error, _) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '검색 중 오류가 발생했습니다',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      
      // 하단 정보 표시
      bottomSheet: _isSearchMode ? null : hospitalsState.when(
        data: (hospitals) => Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '동물병원 ${hospitals.length}개 • 즐겨찾기 ${hospitals.where((h) => h.isFavorite).length}개',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                InkWell(
                  onTap: () => _showFavoriteList(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 12,
                          color: Color.fromARGB(255, 248, 133, 242),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '목록',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  void _handleSearch(String query) {
    setState(() {
      _currentSearchQuery = query;
      _isSearchMode = query.isNotEmpty;
    });

    if (query.isNotEmpty) {
      ref.read(hospitalSearchProvider.notifier).search(query);
    }
  }


  void _showFavoriteList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FavoriteListBottomSheet(),
    );
  }

  Widget _buildNoResultsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '검색 결과가 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"$_currentSearchQuery"와 일치하는\n동물병원을 찾을 수 없습니다',
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

  Widget _buildSearchResultsList(List<dynamic> results) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final hospital = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue[100],
            child: Icon(
              Icons.local_hospital,
              color: Colors.blue[600],
              size: 20,
            ),
          ),
          title: Text(
            hospital.name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hospital.address,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (hospital.phone.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  hospital.phone,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hospital.isFavorite)
                const Icon(
                  Icons.favorite,
                  color: Color.fromARGB(255, 248, 133, 242),
                  size: 16,
                ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Colors.grey[400],
              ),
            ],
          ),
          onTap: () => _showHospitalDetail(hospital),
        );
      },
    );
  }

  void _showHospitalDetail(dynamic hospital) {
    // 검색 모드 종료
    setState(() {
      _isSearchMode = false;
      _currentSearchQuery = '';
    });

    // 상세 정보 바텀시트 표시
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HospitalDetailSheet(
        hospital: hospital,
        // placeId는 hospital이 즐겨찾기인 경우에만 전달
        placeId: hospital.isFavorite ? _findPlaceIdForHospital(hospital) : null,
      ),
    );
  }

  // 병원에 해당하는 place ID 찾기 (즐겨찾기 목록에서)
  int? _findPlaceIdForHospital(dynamic hospital) {
    final myPlacesState = ref.read(myPlacesProvider);
    return myPlacesState.whenOrNull(
      data: (places) {
        for (final place in places) {
          if (place.pname == hospital.name && 
              place.paddress == hospital.address) {
            return place.id;
          }
        }
        return null;
      },
    );
  }

  void _moveToHospitalOnMap(dynamic hospital, dynamic selectedHospitalProvider) {
    // TODO: MapWidget의 컨트롤러를 통해 해당 위치로 이동
    // 또는 Provider를 통해 선택된 병원 정보 전달
    print('지도에서 ${hospital.name} 위치로 이동: ${hospital.latitude}, ${hospital.longitude}');
    
    // 선택된 병원을 Provider에 저장 (MapWidget에서 사용할 수 있도록)
    ref.read(selectedHospitalProvider.notifier).state = hospital;
  }
}