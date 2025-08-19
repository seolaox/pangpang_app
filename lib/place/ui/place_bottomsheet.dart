import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/place/domain/entity/hospital_entity.dart';
import 'package:pangpang_app/place/ui/favorite_button.dart';
import 'package:url_launcher/url_launcher.dart';


class PlaceBottomSheet extends ConsumerWidget {
  final AnimalHospitalEntity hospital;

  const PlaceBottomSheet({
    super.key,
    required this.hospital,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                // 제목과 즐겨찾기 버튼
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hospital.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    FavoriteButtonWidget(hospital: hospital),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 전화번호
                if (hospital.phone.isNotEmpty) ...[
                  _buildInfoRow(
                    icon: Icons.phone,
                    text: hospital.phone,
                  ),
                  const SizedBox(height: 12),
                ],
                
                // 주소
                _buildInfoRow(
                  icon: Icons.location_on,
                  text: hospital.address,

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
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
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
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Colors.grey[400],
              ),
            ],
          ],
        ),
      ),
    );
  }

}