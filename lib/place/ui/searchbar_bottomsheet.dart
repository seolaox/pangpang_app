import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pangpang_app/place/domain/entity/hospital_entity.dart';
import 'package:pangpang_app/place/domain/entity/place_entity.dart';
import 'package:pangpang_app/place/presentaion/place_provider.dart';
import 'package:pangpang_app/place/ui/favorite_button.dart';

class HospitalDetailSheet extends ConsumerStatefulWidget {
  final AnimalHospitalEntity hospital;
  final int? placeId; // 즐겨찾기에 저장된 경우의 place ID

  const HospitalDetailSheet({
    super.key,
    required this.hospital,
    this.placeId,
  });

  @override
  ConsumerState<HospitalDetailSheet> createState() => _HospitalDetailSheetState();
}

class _HospitalDetailSheetState extends ConsumerState<HospitalDetailSheet> {
  @override
  void initState() {
    super.initState();
    // placeId가 있으면 상세 정보 로드
    if (widget.placeId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(placeDetailProvider(widget.placeId!).notifier).loadPlaceDetail();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // placeId가 있으면 상세 정보를 가져오고, 없으면 hospital 정보만 사용
    final placeDetailState = widget.placeId != null
        ? ref.watch(placeDetailProvider(widget.placeId!))
        : null;

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
          // 핸들
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
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
                  if (placeDetailState != null) ...[
                    placeDetailState.when(
                      data: (place) => place != null
                          ? _buildAdditionalInfo(place)
                          : const SizedBox.shrink(),
                      loading: () => _buildLoadingWidget(),
                      error: (error, _) => _buildErrorWidget(error.toString()),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 액션 버튼들
                  _buildActionButtons(),
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
        // 전화번호
        if (widget.hospital.phone.isNotEmpty) ...[
          _buildInfoRow(
            icon: Icons.phone,
            title: '전화번호',
            content: widget.hospital.phone,
            onTap: () => _makePhoneCall(widget.hospital.phone),
            actionIcon: Icons.call,
          ),
          const SizedBox(height: 16),
        ],

        // 주소
        _buildInfoRow(
          icon: Icons.location_on,
          title: '주소',
          content: widget.hospital.address,
          onTap: () => _openMap(),
          actionIcon: Icons.directions,
        ),

        const SizedBox(height: 16),

        // 좌표 정보
        _buildInfoRow(
          icon: Icons.my_location,
          title: '위치',
          content: '위도: ${widget.hospital.latitude.toStringAsFixed(6)}\n'
                  '경도: ${widget.hospital.longitude.toStringAsFixed(6)}',
        ),

        // 즐겨찾기 상태
        const SizedBox(height: 16),
        _buildInfoRow(
          icon: widget.hospital.isFavorite ? Icons.favorite : Icons.favorite_border,
          title: '즐겨찾기',
          content: widget.hospital.isFavorite ? '즐겨찾기에 등록됨' : '즐겨찾기에 등록되지 않음',
          iconColor: widget.hospital.isFavorite ? Colors.red : Colors.grey,
        ),
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
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
    VoidCallback? onTap,
    IconData? actionIcon,
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
            if (actionIcon != null) ...[
              const SizedBox(width: 8),
              Icon(
                actionIcon,
                size: 16,
                color: Colors.blue[600],
              ),
            ],
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
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // 전화 및 길찾기 버튼
        Row(
          children: [
            if (widget.hospital.phone.isNotEmpty) ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _makePhoneCall(widget.hospital.phone),
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text('전화하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _openMap,
                icon: const Icon(Icons.directions, size: 18),
                label: const Text('길찾기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 지도에서 보기 버튼
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 지도에서 해당 위치로 이동
              _moveToMapLocation();
            },
            icon: const Icon(Icons.map, size: 18),
            label: const Text('지도에서 보기'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Colors.blue[300]!),
              foregroundColor: Colors.blue[600],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openMap() async {
    final kakaoMapUri = Uri.parse(
      'kakaomap://route?ep=${widget.hospital.latitude},${widget.hospital.longitude}&by=CAR',
    );
    
    final googleMapUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${widget.hospital.latitude},${widget.hospital.longitude}',
    );

    try {
      if (await canLaunchUrl(kakaoMapUri)) {
        await launchUrl(kakaoMapUri);
      } else {
        await launchUrl(googleMapUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('지도 앱 실행 오류: $e');
    }
  }

  void _moveToMapLocation() {
    // TODO: MapWidget 컨트롤러를 통해 해당 위치로 이동
    print('지도에서 ${widget.hospital.name} 위치로 이동: ${widget.hospital.latitude}, ${widget.hospital.longitude}');
  }
}