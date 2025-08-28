import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pangpang_app/data/model/user/family_model.dart';

class FamilyInfoSection extends StatelessWidget {
  final List<FamilyMember> families;

  const FamilyInfoSection({
    super.key,
    required this.families,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.family_restroom, color: Colors.blue),
                SizedBox(width: 8.w),
                Text(
                  '가족 정보',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            if (families.isNotEmpty)
              ...families.map((family) => FamilyCard(family: family))
            else
              Text(
                '가족 정보 없음',
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
          ],
        ),
      ),
    );
  }
}

class FamilyCard extends StatelessWidget {
  final FamilyMember family;

  const FamilyCard({super.key, required this.family});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이름: ${family.family.fname}',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            '리더: ${family.family.leader_uid}',
            style: TextStyle(fontSize: 13.sp),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Text(
                '상태: ',
                style: TextStyle(fontSize: 13.sp),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(family.status),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  family.status,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case '활성':
        return Colors.green;
      case 'pending':
      case '대기':
        return Colors.orange;
      case 'inactive':
      case '비활성':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}