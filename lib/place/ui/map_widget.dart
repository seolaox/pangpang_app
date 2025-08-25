import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:pangpang_app/place/presentaion/place_provider.dart';
import 'package:pangpang_app/place/ui/place_bottomsheet.dart';

class MapWidget extends ConsumerStatefulWidget {
  const MapWidget({super.key});

  @override
  ConsumerState<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends ConsumerState<MapWidget> {
  NaverMapController? _controller;
  final Set<NMarker> _markers = {};
  bool _isAddingMarkers = false;
  bool _isMapReady = false;
  
  // 마커 아이콘 캐시
  NOverlayImage? _favoriteMarkerIcon;
  NOverlayImage? _hospitalMarkerIcon;

  @override
  void initState() {
    super.initState();
    _initializeMapSafely();
  }

  Future<void> _initializeMapSafely() async {
    try {
      // 1. 먼저 마커 아이콘 미리 로드
      await _preloadMarkerIcons();
      
      // 2. UI 빌드 후 데이터 로드
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadFavoriteDataSafely();
        }
      });
    } catch (e) {
      debugPrint("맵 초기화 실패: $e");
    }
  }

  Future<void> _preloadMarkerIcons() async {
    try {
      _favoriteMarkerIcon = await _createCustomMarkerIcon(
        icon: Icons.favorite,
        backgroundColor: Colors.red,
        iconColor: Colors.white,
        size: 32.0,
      );
      
      _hospitalMarkerIcon = await _createCustomMarkerIcon(
        icon: Icons.local_hospital,
        backgroundColor: Colors.blue,
        iconColor: Colors.white,
        size: 32.0,
      );
      
      debugPrint("마커 아이콘 로드 완료");
    } catch (e) {
      debugPrint("마커 아이콘 로드 실패: $e");
    }
  }

  void _loadFavoriteDataSafely() {
    try {
      // 즐겨찾기 데이터만 로드 (지도 마커용)
      ref.read(myPlacesProvider.notifier).loadMyPlaces();
    } catch (e) {
      debugPrint("즐겨찾기 데이터 로드 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final myPlacesState = ref.watch(myPlacesProvider);

    // 안전한 리스너 등록
    ref.listen<AsyncValue<List<dynamic>>>(myPlacesProvider, (previous, next) {
      if (!mounted || !_isMapReady || _controller == null) return;
      
      next.whenData((places) {
        _safeAddFavoriteMarkersToMap(places);
      });
    });

    return Scaffold(
      body: Stack(
        children: [
          // 네이버 맵
          _buildNaverMapSafely(),
          
          // 범례 (즐겨찾기만)
          _buildSimpleLegend(),
          
          // 로딩 인디케이터
          if (myPlacesState.isLoading)
            const Center(
              child: CircularProgressIndicator(backgroundColor: Colors.white),
            ),
            
          // 에러 표시
          if (myPlacesState.hasError)
            _buildErrorWidget(myPlacesState.error.toString()),
        ],
      ),
    );
  }

  Widget _buildNaverMapSafely() {
    try {
      return NaverMap(
        options: const NaverMapViewOptions(
          indoorEnable: true,
          locationButtonEnable: true,
          consumeSymbolTapEvents: false,
          initialCameraPosition: NCameraPosition(
            target: NLatLng(37.5666102, 126.9783881), // 서울 시청 좌표
            zoom: 12,
          ),
        ),
        onMapReady: (controller) async {
          try {
            _controller = controller;
            _isMapReady = true;
            debugPrint("네이버 맵 준비 완료");
            
            // 현재 로드된 즐겨찾기 데이터가 있으면 마커 추가
            final myPlacesState = ref.read(myPlacesProvider);
            myPlacesState.whenData((places) {
              if (places.isNotEmpty && mounted) {
                _safeAddFavoriteMarkersToMap(places);
              }
            });
          } catch (e) {
            debugPrint("맵 준비 중 오류: $e");
          }
        },
      );
    } catch (e) {
      debugPrint("NaverMap 생성 오류: $e");
      // 지도 생성 실패 시 대체 UI 표시
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('지도를 불러올 수 없습니다'),
            ElevatedButton(
              onPressed: () {
                setState(() {}); // 재시도
              },
              child: Text('다시 시도'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSimpleLegend() {
    return Positioned(
      top: 50,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 248, 133, 242),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '즐겨찾기',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              '즐겨찾기를 불러올 수 없습니다',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
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
      ),
    );
  }

  Future<void> _safeAddFavoriteMarkersToMap(List<dynamic> places) async {
    if (!_isMapReady || _controller == null || places.isEmpty || _isAddingMarkers) {
      return;
    }

    _isAddingMarkers = true;

    try {
      debugPrint("즐겨찾기 마커 추가 시작: ${places.length}개");
      
      // 기존 마커 제거
      await _clearMarkers();

      // 즐겨찾기 마커만 추가 (개별적으로 추가)
      for (int i = 0; i < places.length; i++) {
        final place = places[i];
        
        try {
          final marker = await _createFavoriteMarker(place, i);
          if (marker != null) {
            // 🔥 수정: addOverlay 사용 (개별 추가)
            await _controller!.addOverlay(marker);
            _markers.add(marker);
          }
        } catch (e) {
          debugPrint("즐겨찾기 마커 $i 추가 실패: $e");
          continue;
        }
        
        // 각 마커 추가 후 짧은 딜레이 (안정성을 위해)
        await Future.delayed(const Duration(milliseconds: 50));
      }
      
      debugPrint("즐겨찾기 마커 추가 완료: ${_markers.length}개");
    } catch (e) {
      debugPrint("즐겨찾기 마커 추가 과정에서 오류: $e");
    } finally {
      _isAddingMarkers = false;
    }
  }

  Future<void> _clearMarkers() async {
    try {
      // 마커를 하나씩 안전하게 제거
      final markersToRemove = List<NMarker>.from(_markers);
      _markers.clear();
      
      for (final marker in markersToRemove) {
        try {
          await _controller!.deleteOverlay(marker.info);
        } catch (e) {
          debugPrint("개별 마커 삭제 오류: $e");
        }
      }
    } catch (e) {
      debugPrint("마커 클리어 오류: $e");
    }
  }

  Future<NMarker?> _createFavoriteMarker(dynamic place, int index) async {
    try {
      // 좌표 검증
      if (place.latitude == null || place.longitude == null) {
        debugPrint("잘못된 좌표: $index");
        return null;
      }

      final isValidCoordinate = place.latitude >= -90 && 
                               place.latitude <= 90 && 
                               place.longitude >= -180 && 
                               place.longitude <= 180;
      
      if (!isValidCoordinate) {
        debugPrint("비정상적인 좌표 범위: ${place.latitude}, ${place.longitude}");
        return null;
      }

      // 즐겨찾기 마커 생성
      final marker = NMarker(
        id: 'favorite_place_$index',
        position: NLatLng(place.latitude, place.longitude),
        caption: NOverlayCaption(
          text: place.pname ?? '',
          textSize: 12,
          color: Colors.black,
          // haloColor: Colors.black,
        ),
        size: const Size(32, 32),
      );

      // 마커 아이콘 설정 (안전하게)
      if (_favoriteMarkerIcon != null) {
        marker.setIcon(_favoriteMarkerIcon!);
      } else {
        // 아이콘 생성 실패 시 기본 마커 사용
        final fallbackIcon = await _createCustomMarkerIcon(
          icon: Icons.favorite,
          backgroundColor: Colors.red,
          iconColor: Colors.white,
          size: 32.0,
        );
        if (fallbackIcon != null) {
          marker.setIcon(fallbackIcon);
        }
        // 아이콘 설정 실패해도 기본 마커로 표시됨
      }

      // 마커 탭 리스너 설정
      marker.setOnTapListener((NMarker marker) {
        try {
          _showPlaceBottomSheet(place);
        } catch (e) {
          debugPrint("바텀시트 표시 오류: $e");
        }
      });

      return marker;
    } catch (e) {
      debugPrint("즐겨찾기 마커 생성 오류 ($index): $e");
      return null;
    }
  }

  // Flutter 아이콘을 마커로 변환
  Future<NOverlayImage?> _createCustomMarkerIcon({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required double size,
  }) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // 원형 배경 그리기
      final backgroundPaint = Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.fill;
        
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final center = Offset(size / 2, size / 2);
      final radius = size / 2 - 1;
      
      canvas.drawCircle(center, radius, backgroundPaint);
      canvas.drawCircle(center, radius, borderPaint);

      // 아이콘 그리기
      final iconSize = size * 0.6;
      final textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontSize: iconSize,
            fontFamily: icon.fontFamily,
            color: iconColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size - textPainter.width) / 2,
          (size - textPainter.height) / 2,
        ),
      );

      final picture = recorder.endRecording();
      final image = await picture.toImage(size.toInt(), size.toInt());
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      
      return NOverlayImage.fromByteArray(bytes!.buffer.asUint8List());
    } catch (e) {
      debugPrint("커스텀 마커 아이콘 생성 오류: $e");
      // 에러 시 null 반환
      return null;
    }
  }

  void _showPlaceBottomSheet(dynamic place) {
    try {
      // 즐겨찾기 장소용 바텀시트 표시
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildPlaceDetailSheet(place),
      );
    } catch (e) {
      debugPrint("바텀시트 표시 실패: $e");
    }
  }

  Widget _buildPlaceDetailSheet(dynamic place) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목과 즐겨찾기 표시
                Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        place.pname ?? '이름 없음',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 전화번호
                if (place.pphone != null && place.pphone.isNotEmpty) ...[
                  _buildInfoRow(
                    icon: Icons.phone,
                    text: place.pphone,
                  ),
                  const SizedBox(height: 12),
                ],
                
                // 주소
                if (place.paddress != null && place.paddress.isNotEmpty) ...[
                  _buildInfoRow(
                    icon: Icons.location_on,
                    text: place.paddress,
                  ),
                  const SizedBox(height: 12),
                ],
                
                // 좌표
                _buildInfoRow(
                  icon: Icons.my_location,
                  text: '위도: ${place.latitude?.toStringAsFixed(6) ?? 'N/A'}\n경도: ${place.longitude?.toStringAsFixed(6) ?? 'N/A'}',
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller = null;
    _isMapReady = false;
    super.dispose();
  }
}