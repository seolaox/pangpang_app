// ui/widget/user/animal_list_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pangpang_app/data/model/user/animal_model.dart';
import 'package:pangpang_app/ui/widget/image_widget/profile_image_widget.dart';

class AnimalListSection extends StatelessWidget {
  final List<Animal> animals;

  const AnimalListSection({
    super.key,
    required this.animals,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.pets, color: Colors.brown),
            SizedBox(width: 8.w),
            Text(
              '동물 목록',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (animals.isNotEmpty)
          ...animals.map((animal) => AnimalCard(animal: animal))
        else
          Center(
            child: Container(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  Icon(
                    Icons.pets_outlined,
                    size: 48.w,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '등록된 동물이 없습니다',
                    style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class AnimalCard extends StatelessWidget {
  final Animal animal;

  const AnimalCard({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 동물 이미지
            animal.aimage != null && animal.aimage!.isNotEmpty
                ? profileImageWidget(
                    context: context,
                    height: 120.h,
                    width: 100.w,
                    profileImg: animal.aimage,
                    category: 'animal',
                  )
                : Container(
                    height: 120.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.pets,
                      size: 60.w,
                      color: Colors.grey[600],
                    ),
                  ),
            SizedBox(width: 16.w),
            // 동물 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    animal.aname,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _buildInfoRow('소개', animal.aintroduction ?? '소개 없음'),
                  _buildInfoRow(
                    '생일',
                    animal.abirthday != null
                        ? animal.abirthday!.split('T')[0]
                        : '생일 없음',
                  ),
                  _buildInfoRow('품종', animal.abreed ?? '품종 없음'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}