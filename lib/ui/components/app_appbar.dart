import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pangpang_app/presentation/provider/appbar_provider.dart';
import 'package:pangpang_app/util/style/my_text_style.dart';

class AppAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const AppAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          myTextStyle('황도는', 16.sp, fontWeight: FontWeight.w500),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.r),
            child: myTextStyle(
              ref.read(appBarProvider) ? '산책중' : '쉬는중',
              16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: ref.watch(appBarProvider),
              onChanged: (value) {
                ref.read(appBarProvider.notifier).toggleSwitch(value);
              },
              activeColor: Colors.green,
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[300],
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.person_rounded), // 로그인 여부에 따라 아이콘 변경
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.notifications_rounded), // 알람 여부에 따라 아이콘 변경
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
