import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pangpang_app/presentation/provider/appbar_provider.dart';

class MyDialog extends ConsumerWidget {
  final Function() onPressed;
  final String title;
  final String content;
  final String buttonText;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? buttonColor;
  final double? borderRadius;
  final bool showIcon;
  final bool showTimer; // 타이머 표시 여부
  final String? timerText; // 타이머 텍스트 (Provider에서 가져올 예정)
  
  const MyDialog({
    super.key, 
    required this.onPressed,
    this.title = '알림',
    this.content = '알림 내용',
    this.buttonText = '확인',
    this.icon = Icons.info_outline,
    this.backgroundColor,
    this.textColor,
    this.buttonColor,
    this.borderRadius,
    this.showIcon = true,
    this.showTimer = false,
    this.timerText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appBarVM = ref.watch(appBarProvider);
    // final appBarVM = ref.read(appBarProvider.notifier);
    return Dialog(
      // 다이얼로그 모양 커스터마이징
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 20.r),
      ),
      elevation: 10,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(borderRadius ?? 20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘 (선택사항)
            if (showIcon) ...[
              Container(
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: (buttonColor ?? Colors.blue).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40.sp,
                  color: buttonColor ?? Colors.blue,
                ),
              ),
              SizedBox(height: 15.h),
            ],
            
            // 제목
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: textColor ?? Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 15.h),
            
            // 내용
            Text(
              content,
              style: TextStyle(
                fontSize: 16.sp,
                color: textColor?.withOpacity(0.8) ?? Colors.black54,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            // 타이머 표시 (실시간 업데이트)
            if (showTimer && timerText != null) ...[
              SizedBox(height: 15.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Text(
                  '산책 시간: ${ref.read(appBarProvider.notifier).formattedTime}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            
            SizedBox(height: 25.h),
            
            // 버튼들
            Row(
              children: [
                // 취소 버튼
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: SizedBox(
                      height: 45.h,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // 다이얼로그 닫기
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          '취소',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // 확인 버튼
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: SizedBox(
                      height: 45.h,
                      child: ElevatedButton(
                        onPressed: () {
                          onPressed();
                          // Navigator.of(context).pop(); // 다이얼로그 닫기
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor ?? Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          buttonText,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 추가적인 다이얼로그 스타일들
class SuccessDialog extends StatelessWidget {
  final Function() onPressed;
  final String title;
  final String content;
  
  const SuccessDialog({
    super.key,
    required this.onPressed,
    this.title = '성공!',
    this.content = '작업이 완료되었습니다.',
  });

  @override
  Widget build(BuildContext context) {
    return MyDialog(
      onPressed: onPressed,
      title: title,
      content: content,
      icon: Icons.check_circle_outline,
      buttonColor: Colors.green,
      backgroundColor: Colors.white,
      buttonText: '',
    );
  }
}

class ErrorDialog extends StatelessWidget {
  final Function() onPressed;
  final String title;
  final String content;
  
  const ErrorDialog({
    super.key,
    required this.onPressed,
    this.title = '오류',
    this.content = '문제가 발생했습니다.',
  });

  @override
  Widget build(BuildContext context) {
    return MyDialog(
      onPressed: onPressed,
      title: title,
      content: content,
      icon: Icons.error_outline,
      buttonColor: Colors.red,
      backgroundColor: Colors.white, buttonText: '',
    );
  }
}

class WarningDialog extends StatelessWidget {
  final Function() onPressed;
  final String title;
  final String content;
  
  const WarningDialog({
    super.key,
    required this.onPressed,
    this.title = '경고',
    this.content = '주의가 필요합니다.',
  });

  @override
  Widget build(BuildContext context) {
    return MyDialog(
      onPressed: onPressed,
      title: title,
      content: content,
      icon: Icons.warning_amber_outlined,
      buttonColor: Colors.orange,
      backgroundColor: Colors.white,
      buttonText: '',
    );
  }
}
