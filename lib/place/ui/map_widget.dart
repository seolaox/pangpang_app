import 'dart:typed_data';
import 'dart:ui' as ui;
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

  @override
  void initState() {
    super.initState();
    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(animalHospitalsProvider.notifier).loadAnimalHospitals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hospitalsState = ref.watch(animalHospitalsProvider);

    // 데이터가 변경되면 마커 업데이트
    ref.listen<AsyncValue<List<dynamic>>>(animalHospitalsProvider, (
      previous,
      next,
    ) {
      next.whenData((hospitals) {
        if (_controller != null) {
          _addMarkersToMap(hospitals);
        }
      });
    });

    return Scaffold(
      body: Stack(
        children: [
          NaverMap(
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
              _controller = controller;
              // 현재 로드된 데이터가 있으면 마커 추가
              hospitalsState.whenData((hospitals) {
                _addMarkersToMap(hospitals);
              });
            },
          ),
          
          // 🎨 마커 범례 추가
          Positioned(
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '일반 병원',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.red,
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
                ],
              ),
            ),
          ),
          
          if (hospitalsState.isLoading)
            const Center(
              child: CircularProgressIndicator(backgroundColor: Colors.white),
            ),
          if (hospitalsState.hasError)
            Center(
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
                      '데이터를 불러올 수 없습니다',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${hospitalsState.error}',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(animalHospitalsProvider.notifier)
                            .loadAnimalHospitals();
                      },
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addMarkersToMap(List<dynamic> hospitals) async {
    if (_controller == null || hospitals.isEmpty) return;

    // 마커 추가 중이면 리턴
    if (_isAddingMarkers) return;
    _isAddingMarkers = true;

    try {
      // 기존 마커 제거 - 안전한 방법으로
      final markersToRemove = List<NMarker>.from(_markers);
      for (final marker in markersToRemove) {
        try {
          await _controller!.deleteOverlay(marker.info);
        } catch (e) {
          print('마커 삭제 오류: $e');
        }
      }
      _markers.clear();

      // 새 마커 추가 - 배치로 처리
      final newMarkers = <NMarker>[];
      
      for (int i = 0; i < hospitals.length; i++) {
        final hospital = hospitals[i];
        
        try {
          // 🎯 즐겨찾기 여부에 따라 다른 마커 생성
          final marker = await _createMarkerForHospital(hospital, i);

          marker.setOnTapListener((NMarker marker) {
            _showHospitalBottomSheet(hospital);
          });

          newMarkers.add(marker);
          await _controller!.addOverlay(marker);
        } catch (e) {
          print('마커 추가 오류: $e');
        }
      }
      
      _markers.addAll(newMarkers);
    } finally {
      _isAddingMarkers = false;
    }
  }

  // 🎨 병원에 따라 다른 마커 생성
  Future<NMarker> _createMarkerForHospital(dynamic hospital, int index) async {
    if (hospital.isFavorite) {
      // 💖 즐겨찾기 마커 - 빨간색 병원 아이콘
      return NMarker(
        id: 'favorite_hospital_$index',
        position: NLatLng(hospital.latitude, hospital.longitude),
        caption: NOverlayCaption(
          text: hospital.name,
          textSize: 12,
          color: Colors.white,
          haloColor: Colors.red,
        ),
        // 빨간색 병원 아이콘 마커
        icon: await _createCustomMarkerIcon(
          icon: Icons.local_hospital,
          backgroundColor: Colors.red,
          iconColor: Colors.white,
          size: 48,
        ),
        size: const Size(48, 48),
      );
    } else {
      // 🏥 일반 병원 마커 - 파란색 병원 아이콘
      return NMarker(
        id: 'hospital_$index',
        position: NLatLng(hospital.latitude, hospital.longitude),
        caption: NOverlayCaption(
          text: hospital.name,
          textSize: 12,
          color: Colors.white,
          haloColor: Colors.blue,
        ),
        // 파란색 병원 아이콘 마커
        icon: await _createCustomMarkerIcon(
          icon: Icons.local_hospital,
          backgroundColor: Colors.blue,
          iconColor: Colors.white,
          size: 40,
        ),
        size: const Size(40, 40),
      );
    }
  }

  // 🎨 커스텀 마커 아이콘 생성
  Future<NOverlayImage> _createCustomMarkerIcon({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required double size,
  }) async {
    // CustomPainter를 사용해서 커스텀 마커 그리기
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = backgroundColor;
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // 원형 배경 그리기
    final center = Offset(size / 2, size / 2);
    final radius = size / 2;
    
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius, borderPaint);

    // 아이콘 그리기
    final iconSize = size * 0.6;
    final iconPainter = TextPainter(
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
    
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        (size - iconPainter.width) / 2,
        (size - iconPainter.height) / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    
    // 네이버 지도 API에 맞는 방식으로 수정
    return NOverlayImage.fromByteArray(bytes!.buffer.asUint8List());
  }

  void _showHospitalBottomSheet(dynamic hospital) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceBottomSheet(hospital: hospital),
    );
  }
}