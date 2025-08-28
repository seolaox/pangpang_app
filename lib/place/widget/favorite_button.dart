import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/place/domain/entity/hospital_entity.dart';
import 'package:pangpang_app/place/presentaion/place_provider.dart';
import 'package:pangpang_app/util/token_manager.dart';

class FavoriteButtonWidget extends ConsumerStatefulWidget {
  final AnimalHospitalEntity hospital;
  final VoidCallback? onFavoriteChanged;

  const FavoriteButtonWidget({
    super.key,
    required this.hospital,
    this.onFavoriteChanged,
  });

  @override
  ConsumerState<FavoriteButtonWidget> createState() =>
      _FavoriteButtonWidgetState();
}

class _FavoriteButtonWidgetState extends ConsumerState<FavoriteButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _isLoading ? null : _toggleFavorite,
              iconSize: 24,
              icon:
                  _isLoading
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.hospital.isFavorite
                                ? Colors.red
                                : Colors.grey,
                          ),
                        ),
                      )
                      : Icon(
                        widget.hospital.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                            widget.hospital.isFavorite
                                ? Colors.red
                                : Colors.grey[600],
                      ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    final token = await TokenManager.getAccessToken();
    if (token == null || token.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.login, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('로그인이 필요한 기능입니다'),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(
              label: '로그인',
              textColor: Colors.white,
              onPressed: () {
                print('로그인 페이지로 이동');
              },
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // 애니메이션 실행
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    try {
      await ref
          .read(animalHospitalsProvider.notifier)
          .toggleFavorite(widget.hospital);

      // 지도 마커 업데이트를 위해 myPlacesProvider도 새로고침
      ref.read(myPlacesProvider.notifier).loadMyPlaces();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.hospital.isFavorite
                      ? Icons.favorite_border
                      : Icons.favorite,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.hospital.isFavorite
                      ? '즐겨찾기에서 제거되었습니다'
                      : '즐겨찾기에 추가되었습니다',
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        // 즐겨찾기 상태 변경 콜백 호출 (바텀시트 닫기용)
        widget.onFavoriteChanged?.call();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = '오류가 발생했습니다';
        Color backgroundColor = Colors.red;

        if (e.toString().contains('이미 즐겨찾기에 등록된')) {
          errorMessage = '이미 즐겨찾기에 등록된 장소입니다';
          backgroundColor = Colors.orange;
        } else if (e.toString().contains('로그인이 필요')) {
          errorMessage = '로그인이 필요한 기능입니다';
          backgroundColor = Colors.blue;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  e.toString().contains('이미 즐겨찾기에 등록된')
                      ? Icons.info_outline
                      : Icons.error_outline,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
