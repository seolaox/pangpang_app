import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnimalGridViewWidget extends StatelessWidget {
  const AnimalGridViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 임시 데이터 (실제 데이터로 교체 필요)
    final List<String> animals = [
      '강아지', '고양이', '토끼', '햄스터',
      '새', '물고기', '거북이', '기타'
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true, // 부모 위젯에 맞춰 크기 조정
          physics: const NeverScrollableScrollPhysics(), // 스크롤 비활성화
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 4열로 설정
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
            childAspectRatio: 1.0, // 정사각형 비율
          ),
          itemCount: animals.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pets,
                    size: 24.sp,
                    color: Colors.blue[700],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    animals[index],
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
} 