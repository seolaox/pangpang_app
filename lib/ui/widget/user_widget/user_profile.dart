import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pangpang_app/data/model/user/user_model.dart';
import 'package:pangpang_app/ui/widget/image_widget/profile_image_widget.dart';
import 'package:pangpang_app/ui/widget/user_widget/family_profile.dart';
import 'package:pangpang_app/util/style/my_text_style.dart';

class UserProfileSection extends StatelessWidget {
  final UserModel user;

  const UserProfileSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                profileImageWidget(
                  context: context,
                  height: 80,
                  width: 80,
                  profileImg: user.uimage,
                  category: 'user',
                ),
                SizedBox(height: 8.h),
                myTextStyle(user.uname, 20.sp, fontWeight: FontWeight.bold),
                Text(
                  '아이디: ${user.uid}',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 5),
        Expanded(child: FamilyInfoSection(families: user.families)),
      ],
    );
  }
}
