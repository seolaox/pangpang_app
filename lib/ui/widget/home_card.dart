import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pangpang_app/ui/widget/image_slider/image_slider.dart';
import 'package:pangpang_app/util/style/my_text_style.dart';

class HomeCard extends ConsumerWidget {
  const HomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // MediaQuery를 사용해서 화면 크기 가져오기
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Card(
      child: Container(
        padding: EdgeInsets.all(5.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[300]!,
              blurRadius: 10.r,
              offset: Offset(0.r, 3.r),
            ),
          ],
        ),

        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(5.h),
              child: Row(
                children: [
                  // 왼쪽 공간 (빈 공간)
                  Expanded(child: SizedBox()),
                  // 가운데 정렬할 텍스트
                  myTextStyle('Home Card', 20.sp, fontWeight: FontWeight.bold),
                  // 오른쪽 정렬할 텍스트
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: myTextStyle(
                        '2025.06.19',
                        13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5.h),
              child: ImageSlider(),
              // Container(
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(10.r),
              //   ),
              //   width: screenWidth * 0.9, // 화면 너비의 80%
              //   height: screenHeight * 0.3, // 화면 높이의 25%
              //   child: Image.asset('assets/images/pang.png', fit: BoxFit.cover),
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
