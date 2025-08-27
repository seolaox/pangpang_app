import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/place/presentaion/place_vm.dart';
import 'package:pangpang_app/place/domain/entity/hospital_entity.dart';
import 'package:pangpang_app/place/domain/entity/place_entity.dart';
import 'package:pangpang_app/place/widget/favorite_button.dart';

class HospitalDetailSheet extends ConsumerStatefulWidget {
  final AnimalHospitalEntity hospital;
  final int? placeId; 

  const HospitalDetailSheet({
    super.key,
    required this.hospital,
    this.placeId,
  });

  @override
  ConsumerState<HospitalDetailSheet> createState() => _HospitalDetailSheetState();
}

class _HospitalDetailSheetState extends ConsumerState<HospitalDetailSheet> {
  PlaceEntity? _placeDetail;
  bool _isLoadingDetail = false;
  String? _detailError;

  @override
  void initState() {
    super.initState();
    // placeId가 있으면 상세 정보 로드
    if (widget.placeId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadPlaceDetail();
      });
    }
  }

  Future<void> _loadPlaceDetail() async {
    if (widget.placeId == null) return;

    setState(() {
      _isLoadingDetail = true;
      _detailError = null;
    });

    try {
      final result = await ref
          .read(searchHospitalsUseCaseProvider)
          .getPlaceDetail(widget.placeId!);

      result.fold(
        (error) {
          setState(() {
            _detailError = error;
            _isLoadingDetail = false;
          });
        },
        (place) {
          setState(() {
            _placeDetail = place;
            _isLoadingDetail = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _detailError = e.toString();
        _isLoadingDetail = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Icon(
                  Icons.local_hospital,
                  size: 24,
                  color: Colors.blue[600],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.hospital.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FavoriteButtonWidget(hospital: widget.hospital),
              ],
            ),
          ),

          const Divider(height: 1),

          // 상세 정보
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 기본 정보
                  _buildBasicInfo(),

                  const SizedBox(height: 24),

                  // 추가 정보 (placeId가 있는 경우)
                  if (widget.placeId != null) ...[
                    if (_isLoadingDetail)
                      _buildLoadingWidget()
                    else if (_detailError != null)
                      _buildErrorWidget(_detailError!)
                    else if (_placeDetail != null)
                      _buildAdditionalInfo(_placeDetail!)
                    else
                      const SizedBox.shrink(),
                    const SizedBox(height: 24),
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
        if (widget.hospital.phone.isNotEmpty) ...[
          _buildInfoRow(
            icon: Icons.phone,
            title: '전화번호',
            content: widget.hospital.phone,
          ),
          const SizedBox(height: 16),
        ],

        _buildInfoRow(
          icon: Icons.location_on,
          title: '주소',
          content: widget.hospital.address,
        ),

        const SizedBox(height: 16),

      ],
    );
  }

  Widget _buildAdditionalInfo(PlaceEntity place) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '추가 정보',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),

        if (place.id != null) ...[
          _buildInfoRow(
            icon: Icons.tag,
            title: '장소 ID',
            content: place.id.toString(),
          ),
          const SizedBox(height: 12),
        ],

        if (place.createdAt != null) ...[
          _buildInfoRow(
            icon: Icons.access_time,
            title: '등록일',
            content: _formatDateTime(place.createdAt!),
          ),
          const SizedBox(height: 12),
        ],

        // 서버 데이터와 비교
        if (place.pname != widget.hospital.name ||
            place.paddress != widget.hospital.address ||
            place.pphone != widget.hospital.phone) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Text(
                      '즐겨찾기 정보',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (place.pname != widget.hospital.name)
                  Text('저장된 이름: ${place.pname}', style: TextStyle(fontSize: 12, color: Colors.orange[600])),
                if (place.paddress != widget.hospital.address)
                  Text('저장된 주소: ${place.paddress}', style: TextStyle(fontSize: 12, color: Colors.orange[600])),
                if (place.pphone != widget.hospital.phone)
                  Text('저장된 전화번호: ${place.pphone}', style: TextStyle(fontSize: 12, color: Colors.orange[600])),
              ],
            ),
          ),
        ],

        // 새로고침 버튼
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: _loadPlaceDetail,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('새로고침'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue[600],
            ),
          ),
        ),
      ],
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

  Widget _buildLoadingWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('상세 정보를 불러오는 중...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '상세 정보를 불러올 수 없습니다\n$error',
              style: TextStyle(color: Colors.red[700], fontSize: 12),
            ),
          ),
          // 재시도 버튼
          TextButton(
            onPressed: _loadPlaceDetail,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[600],
              minimumSize: const Size(60, 32),
            ),
            child: const Text('재시도', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }


}