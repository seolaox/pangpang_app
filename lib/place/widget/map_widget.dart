import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:pangpang_app/place/presentaion/place_provider.dart';
import 'package:pangpang_app/place/domain/entity/hospital_entity.dart';
import 'package:pangpang_app/place/widget/hospital_bottomsheet.dart';

class MapWidget extends ConsumerStatefulWidget {
  const MapWidget({super.key});

  @override
  ConsumerState<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends ConsumerState<MapWidget> {
  NaverMapController? _controller;
  final Set<NMarker> _markers = {};
  final Set<NMarker> _searchMarkers = {}; //검색 결과 마커들
  bool _isAddingMarkers = false;
  bool _isMapReady = false;
  bool _isDisposed = false;

  // 마커 아이콘 캐시
  NOverlayImage? _favoriteMarkerIcon;
  NOverlayImage? _searchMarkerIcon; //검색 결과물 마커들

  @override
  void initState() {
    super.initState();
    _initializeMapSafely();
  }

  Future<void> _initializeMapSafely() async {
    if (_isDisposed) return; // dispose된 경우 조기 return

    try {
      // 1. 먼저 마커 아이콘 미리 로드!
      await _preloadMarkerIcons();

      // 2. UI 빌드 후 데이터 로드!!!
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed) {
          _loadFavoriteDataSafely();
        }
      });
    } catch (e) {
      debugPrint("맵 초기화 실패: $e");
    }
  }

  Future<void> _preloadMarkerIcons() async {
    if (_isDisposed) return;

    try {
      _favoriteMarkerIcon = await _createCustomMarkerIcon(
        icon: Icons.favorite,
        backgroundColor: Colors.red,
        iconColor: Colors.white,
        size: 32.0,
      );

      _searchMarkerIcon = await _createCustomMarkerIcon(
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
    if (_isDisposed) return;

    try {
      // 즐겨찾기 데이터만 로드 (지도 마커용)
      ref.read(myPlacesProvider.notifier).loadMyPlaces();
    } catch (e) {
      debugPrint("즐겨찾기 데이터 로드 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) {
      return const SizedBox.shrink(); // dispose된 경우 빈 위젯 반환
    }

    final myPlacesState = ref.watch(myPlacesProvider);
    // final selectedHospital = ref.watch(selectedHospitalProvider);

    ref.listen<AsyncValue<List<dynamic>>>(myPlacesProvider, (previous, next) {
      if (!mounted || !_isMapReady || _controller == null || _isDisposed)
        return;

      next.whenData((places) {
        _safeAddFavoriteMarkersToMap(places);
      });
    });

    // 선택된 병원이 변경되면 지도 이동
    ref.listen<AnimalHospitalEntity?>(selectedHospitalProvider, (
      previous,
      next,
    ) {
      if (next != null && _controller != null && _isMapReady && !_isDisposed) {
        _handleSelectedHospital(next);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          _buildNaverMapSafely(),

          if (myPlacesState.isLoading)
            const Center(
              child: CircularProgressIndicator(backgroundColor: Colors.white),
            ),

          if (myPlacesState.hasError)
            _buildErrorWidget(myPlacesState.error.toString()),
        ],
      ),
    );
  }

  Widget _buildNaverMapSafely() {
    if (_isDisposed) {
      return const SizedBox.shrink();
    }

    try {
      return NaverMap(
        options: const NaverMapViewOptions(
          indoorEnable: true,
          locationButtonEnable: true,
          consumeSymbolTapEvents: false,
          initialCameraPosition: NCameraPosition(
            target: NLatLng(37.5666102, 126.9783881),
            zoom: 12,
          ),
        ),
        onMapReady: (controller) async {
          if (_isDisposed) return; // dispose 체크

          try {
            _controller = controller;
            _isMapReady = true;
            debugPrint("네이버 맵 준비 완료");

            // 현재 로드된 즐겨찾기 데이터가 있으면 마커 추가
            final myPlacesState = ref.read(myPlacesProvider);
            myPlacesState.whenData((places) {
              if (places.isNotEmpty && mounted && !_isDisposed) {
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
                if (mounted && !_isDisposed) {
                  setState(() {});
                }
              },
              child: Text('다시 시도'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('즐겨찾기를 불러올 수 없습니다'),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (!_isDisposed) {
                  ref.read(myPlacesProvider.notifier).loadMyPlaces();
                }
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  // 즐겨찾기 장소 리스트를 받아서 지도에 대응하는 마커를 안전하게 추가하는 함수
  Future<void> _safeAddFavoriteMarkersToMap(List<dynamic> places) async {
    if (!_isMapReady || //지도 준비 완료 상태
        _controller == null || //컨트롤러 존재 여부
        places.isEmpty ||
        _isAddingMarkers || //마커 추가 작업중인지 여부
        _isDisposed) {
      //위제 해제 여부 검사
      return;
    }

    _isAddingMarkers = true; //마커 추가 작업 중 상태 플래그 설정

    try {
      debugPrint("즐겨찾기 마커 추가 시작: ${places.length}개");

      await _clearMarkers(); // 기존 마커 제거

      if (_isDisposed) return; // dispose 체크

      // 즐겨찾기 장소별 마커 개별 추가 박복 처리
      for (int i = 0; i < places.length; i++) {
        if (_isDisposed) break; // dispose 체크

        final place = places[i];

        try {
          final marker = await _createFavoriteMarker(place, i);
          if (marker != null && !_isDisposed) {
            await _controller!.addOverlay(marker);
            _markers.add(marker);
          }
        } catch (e) {
          debugPrint("즐겨찾기 마커 $i 추가 실패: $e");
          continue;
        }
      }

      debugPrint("즐겨찾기 마커 추가 완료: ${_markers.length}개");
    } catch (e) {
      debugPrint("즐겨찾기 마커 추가 과정에서 오류: $e");
    } finally {
      _isAddingMarkers = false; //작업 완료 후 상태 플래그 해제
    }
  }

  Future<void> _clearMarkers() async {
    if (_isDisposed || _controller == null) return;

    try {
      final markersToRemove = List<NMarker>.from(_markers);
      _markers.clear();

      for (final marker in markersToRemove) {
        if (_isDisposed) break; // dispose 체크

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
    if (_isDisposed) return null;

    try {
      if (place.latitude == null || place.longitude == null) {
        debugPrint("잘못된 좌표: $index");
        return null;
      }

      final isValidCoordinate =
          place.latitude >= -90 &&
          place.latitude <= 90 &&
          place.longitude >= -180 &&
          place.longitude <= 180;

      if (!isValidCoordinate) {
        debugPrint("비정상적인 좌표 범위: ${place.latitude}, ${place.longitude}");
        return null;
      }

      // 즐겨찾기 마커 생성----------
      final marker = NMarker(
        id: 'favorite_place_$index',
        position: NLatLng(place.latitude, place.longitude),
        caption: NOverlayCaption(
          text: place.pname ?? '',
          textSize: 12,
          color: Colors.black,
        ),
        size: const Size(32, 32),
      );

      if (_favoriteMarkerIcon != null) {
        marker.setIcon(_favoriteMarkerIcon!);
      } else {
        final fallbackIcon = await _createCustomMarkerIcon(
          icon: Icons.favorite,
          backgroundColor: Colors.red,
          iconColor: Colors.white,
          size: 32.0,
        );
        if (fallbackIcon != null) {
          marker.setIcon(fallbackIcon);
        }
      }

      //마커 실행시 바텀시트 호출 -----
      marker.setOnTapListener((NMarker marker) {
        if (!_isDisposed) {
          try {
            _showPlaceBottomSheet(place);
          } catch (e) {
            debugPrint("바텀시트 표시 오류: $e");
          }
        }
      });

      return marker;
    } catch (e) {
      debugPrint("즐겨찾기 마커 생성 오류 ($index): $e");
      return null;
    }
  }

  // 선택된 병원 처리 (지도 이동 + 마커 추가)
  Future<void> _handleSelectedHospital(AnimalHospitalEntity hospital) async {
    if (_controller == null || !_isMapReady || _isDisposed) return;

    try {
      // 1. 기존 검색 마커들 제거
      await _clearSearchMarkers();

      // 2. 병원 위치로 카메라 이동
      final cameraUpdate = NCameraUpdate.fromCameraPosition(
        NCameraPosition(
          target: NLatLng(hospital.latitude, hospital.longitude),
          zoom: 16,
        ),
      );
      await _controller!.updateCamera(cameraUpdate);

      //3. 즐겨찾기 병원인지 확인하기
      final myPlaceState = ref.read(myPlacesProvider);
      bool isAlreadyFavorite = false;

      myPlaceState.whenData((places) {
        isAlreadyFavorite = places.any(
          (place) =>
              place.pname == hospital.name &&
              place.paddress == hospital.address,
        );
      });

      // 4. 즐겨찾기에 없는 병원만 파란색 검색 마커 추가
      if (!isAlreadyFavorite) {
        await _addSearchMarker(hospital);
        debugPrint("새로운 병원 검색 마커 추가: ${hospital.name}");
      } else {
        debugPrint("즐겨찾기 병원이므로 검색 마커 추가하지 않음: ${hospital.name}");
      }

      // 4. 선택된 병원 초기화 (한 번만 이동하도록)
      ref.read(selectedHospitalProvider.notifier).state = null;
    } catch (e) {
      debugPrint("선택된 병원 처리 실패: $e");
    }
  }

  // 검색 결과 마커 추가
  Future<void> _addSearchMarker(AnimalHospitalEntity hospital) async {
    if (_controller == null || _isDisposed) return;

    try {
      final marker = NMarker(
        id: 'search_result_${hospital.name}',
        position: NLatLng(hospital.latitude, hospital.longitude),
        caption: NOverlayCaption(
          text: hospital.name,
          textSize: 12,
          color: Colors.black,
        ),
        size: const Size(36, 36),
      );

      // 검색 마커 아이콘 설정
      if (_searchMarkerIcon != null) {
        marker.setIcon(_searchMarkerIcon!);
      } else {
        final fallbackIcon = await _createCustomMarkerIcon(
          icon: Icons.local_hospital,
          backgroundColor: Colors.blue,
          iconColor: Colors.white,
          size: 36.0,
        );
        if (fallbackIcon != null) {
          marker.setIcon(fallbackIcon);
        }
      }

      // 마커 탭 리스너 설정
      marker.setOnTapListener((NMarker marker) {
        if (!_isDisposed) {
          _showHospitalBottomSheet(hospital);
        }
      });

      await _controller!.addOverlay(marker);
      _searchMarkers.add(marker);

      debugPrint("검색 마커 추가 완료: ${hospital.name}");
    } catch (e) {
      debugPrint("검색 마커 추가 실패: $e");
    }
  }

  // 검색 마커들 제거
  Future<void> _clearSearchMarkers() async {
    if (_isDisposed || _controller == null) return;

    try {
      final markersToRemove = List<NMarker>.from(_searchMarkers);
      _searchMarkers.clear();

      for (final marker in markersToRemove) {
        if (_isDisposed) break;
        try {
          await _controller!.deleteOverlay(marker.info);
        } catch (e) {
          debugPrint("개별 검색 마커 삭제 오류: $e");
        }
      }
    } catch (e) {
      debugPrint("검색 마커 클리어 오류: $e");
    }
  }

  // 병원 바텀시트 표시
  void _showHospitalBottomSheet(AnimalHospitalEntity hospital) {
    if (_isDisposed) return;

    try {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (context) => CommonHospitalBottomSheet(
              hospital: hospital,
              onMapMove: () {
                Navigator.pop(context);
              },
              onFavoriteChanged: () {
                _clearSearchMarkers(); // 1. 파란색 검색 마커 제거
                ref
                    .read(myPlacesProvider.notifier)
                    .loadMyPlaces(); //2.즐겨찾기 새로고침 로드하기
              },
            ),
      );
    } catch (e) {
      debugPrint("병원 바텀시트 표시 실패: $e");
    }
  }

  // Flutter 아이콘을 마커로 변환
  Future<NOverlayImage?> _createCustomMarkerIcon({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required double size,
  }) async {
    if (_isDisposed) return null;

    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final backgroundPaint =
          Paint()
            ..color = backgroundColor
            ..style = PaintingStyle.fill;

      final borderPaint =
          Paint()
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
        Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
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
    if (_isDisposed) return;

    try {
      // PlaceEntity를 AnimalHospitalEntity로 변환
      final hospital = AnimalHospitalEntity(
        name: place.pname ?? '',
        address: place.paddress ?? '',
        phone: place.pphone ?? '',
        latitude: place.latitude ?? 0.0,
        longitude: place.longitude ?? 0.0,
        isFavorite: true, // 즐겨찾기에서 온 것이므로 true
      );

      // 공통 바텀시트 표시
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CommonHospitalBottomSheet(hospital: hospital),
      );
    } catch (e) {
      debugPrint("바텀시트 표시 실패: $e");
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller = null;
    _isMapReady = false;
    super.dispose();
  }
}
