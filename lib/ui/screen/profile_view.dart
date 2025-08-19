import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/place/presentaion/place_provider.dart';
import 'package:pangpang_app/place/ui/favorite_bottomsheet.dart';
import 'package:pangpang_app/place/ui/map_widget.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hospitalsState = ref.watch(animalHospitalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('동물병원 찾기'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          // 즐겨찾기 목록 버튼
          IconButton(
            onPressed: () {
              _showFavoriteList(context);
            },
            icon: const Icon(Icons.bookmark),
            tooltip: '즐겨찾기',
          ),
          // 새로고침 버튼
          IconButton(
            onPressed: () {
              ref.read(animalHospitalsProvider.notifier).loadAnimalHospitals();
            },
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
          ),
        ],
      ),
      body: const MapWidget(),
      // 하단 정보 표시
      bottomSheet: hospitalsState.when(
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
                // 즐겨찾기 목록 바로가기 버튼
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
                          Icons.bookmark,
                          size: 12,
                          color: Colors.blue[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '목록',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[600],
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

  void _showFavoriteList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FavoriteListBottomSheet(),
    );
  }
}