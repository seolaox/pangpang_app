import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/place/domain/entity/hospital_entity.dart';
import 'package:pangpang_app/place/widget/favorite_button.dart';

class CommonHospitalBottomSheet extends ConsumerWidget {
  final AnimalHospitalEntity hospital;
  final VoidCallback? onMapMove;
  final Widget? additionalContent;
  final VoidCallback? onFavoriteChanged;

  const CommonHospitalBottomSheet({
    super.key,
    required this.hospital,
    this.onMapMove,
    this.additionalContent,
    this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단 핸들
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 병원명과 즐겨찾기 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(
                  Icons.local_hospital,
                  size: 24,
                  color: Colors.blue[600],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hospital.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FavoriteButtonWidget(
                  hospital: hospital,
                  onFavoriteChanged: () {
                    onFavoriteChanged?.call();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 기본 정보
                  _buildBasicInfo(),

                  // 지도 이동 버튼 (onMapMove가 있을 때만)
                  if (onMapMove != null) ...[
                    const SizedBox(height: 16),
                    _buildMapMoveButton(context),
                  ],

                  // 추가 컨텐츠 (있을 때만)
                  if (additionalContent != null) ...[
                    const SizedBox(height: 24),
                    additionalContent!,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hospital.phone.isNotEmpty) ...[
          _buildInfoRow(
            icon: Icons.phone,
            title: '전화번호',
            content: hospital.phone,
          ),
          const SizedBox(height: 16),
        ],
        _buildInfoRow(
          icon: Icons.location_on,
          title: '주소',
          content: hospital.address,
        ),
      ],
    );
  }

  Widget _buildMapMoveButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          onMapMove?.call();
        },
        icon: const Icon(Icons.map, size: 20),
        label: const Text('지도에서 보기'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: iconColor ?? Colors.blue[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}