import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pangpang_app/util/style/my_text_style.dart';

class AnimalGridViewWidget extends StatelessWidget {
  const AnimalGridViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 3,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
      ),
      itemBuilder: (context, index) {
        return Container(
          // width: 100.w,
          // height: 100.h,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            children: [
              // profileImageWidget(context: context, size: 60.r, profileImg: user.uimage, category: 0,),
              Image.asset('assets/images/pang.png'),
              myTextStyle('황도', 16.sp, fontWeight: FontWeight.bold),
            ],
          ),
        );
      },
    );
  }
}