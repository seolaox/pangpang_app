import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        child: Column(
          children: [
            myTextStyle('Home Card', 20.sp, fontWeight: FontWeight.bold),
            SizedBox(height: 10.h),
            // 방법 1: MediaQuery를 사용한 반응형 크기
            Container(
              width: screenWidth * 0.8, // 화면 너비의 80%
              height: screenHeight * 0.25, // 화면 높이의 25%
              child: Image.asset(
                'assets/images/pang.png',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}