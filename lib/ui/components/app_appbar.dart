import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pangpang_app/presentation/provider/appbar_provider.dart';
import 'package:pangpang_app/presentation/provider/auth_provider/auth_provider.dart';
import 'package:pangpang_app/ui/components/my_dialog.dart';
import 'package:pangpang_app/ui/widget/my_animation.dart';
import 'package:pangpang_app/util/style/my_text_style.dart';

class AppAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const AppAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appBarState = ref.watch(appBarProvider);
    final appBarVM = ref.read(appBarProvider.notifier);

    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          myTextStyle('황도는', 16.sp, fontWeight: FontWeight.w500),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.r),
            child: myTextStyle(
              appBarState.isWalking ? '산책중' : '쉬는중',
              16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: appBarState.isWalking,
              onChanged: (value) {
                showDialog(
                  context: context,
                  builder:
                      (context) => MyDialog(
                        title: value ? '산책 시작' : '산책 종료',
                        content:
                            value
                                ? '산책을 시작하시겠습니까?\n황도가 행복해보이네요 :)'
                                : '산책을 종료하시겠습니까?\n오늘의 산책 기록이 저장됩니다.',
                        buttonText: value ? '시작하기' : '종료하기',
                        icon:
                            value
                                ? Icons.directions_walk
                                : Icons.stop_circle_outlined,
                        buttonColor: value ? Colors.green : Colors.red,
                        backgroundColor: Colors.white,
                        showTimer: !value,
                        timerText: appBarVM.formattedTime,
                        onPressed: () {
                          if (value) {
                            // 산책 시작 시 타이머 리셋
                            appBarVM.resetTimer();
                          }
                          ref.read(appBarProvider.notifier).toggleSwitch(value);
                          GoRouter.of(context).pop();
                        },
                      ),
                );
              },
              activeColor: Colors.green,
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[300],
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          MyAnimation(),
          // 타이머 표시 (산책중일 때만)
          if (appBarState.isWalking) ...[
            SizedBox(width: 10.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: myTextStyle(
                appBarVM.formattedTime,
                12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ],
        ],
      ),
      actions: [
        IconButton(
          onPressed: () async {
            // final user = await ref.read(authUseCaseProvider).getCurrentUser();
            // GoRouter.of(context).push('/user', extra: user);
            final loginState = ref.read(loginVmProvider);
            if (loginState.userInfoList.isNotEmpty) {
              final currentUid = loginState.userInfoList[0].uid;

              final user = await ref
                  .read(authUseCaseProvider)
                  .getProfileUser(uid: currentUid);
              GoRouter.of(context).push('/user', extra: user);
            }
          },
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
