import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pangpang_app/data/model/user/user_model.dart';
import 'package:pangpang_app/presentation/provider/appbar_provider.dart';
import 'package:pangpang_app/presentation/provider/auth_provider/auth_provider.dart';
import 'package:pangpang_app/ui/components/my_dialog.dart';
import 'package:pangpang_app/ui/widget/my_animation.dart';
import 'package:pangpang_app/util/style/my_text_style.dart';
import 'package:pangpang_app/util/token_manager.dart';

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
  // IconButton(
  //   onPressed: () async {
  //     try {
  //       // 1. SecureStorage에서 직접 토큰 확인
  //       final accessToken = await TokenManager.getAccessToken();
        
  //       if (accessToken == null || accessToken.isEmpty) {
  //         // 로그인 만료/에러 안내
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('로그인이 필요합니다.'))
  //         );
  //         context.go('/login');
  //         return;
  //       }

  //       // 2. Provider 상태도 동기화
  //       ref.read(accessTokenProvider.notifier).state = accessToken;

  //       // 3. 사용자 정보 조회
  //       final loginState = ref.read(loginVmProvider);
  //       UserModel user;

  //       if (loginState.userInfoList.isNotEmpty) {
  //         final currentUid = loginState.userInfoList[0].uid;
  //         user = await ref
  //             .read(authUseCaseProvider)
  //             .getProfileUser(uid: currentUid);
  //       } else {
  //         // 토큰 기반으로 바로 유저 조회
  //         user = await ref.read(authUseCaseProvider).getCurrentUser();
  //       }

  //       if (context.mounted) {
  //         GoRouter.of(context).push('/user', extra: user);
  //       }
  //     } catch (e) {
  //       debugPrint('사용자 불러오기 실패: $e');
        
  //       // 토큰이 유효하지 않은 경우 처리
  //       if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
  //         await TokenManager.clearTokens();
  //         ref.read(accessTokenProvider.notifier).state = null;
          
  //         if (context.mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(content: Text('로그인이 만료되었습니다. 다시 로그인해주세요.'))
  //           );
  //           context.go('/login');
  //         }
  //       } else {
  //         // 기타 에러
  //         if (context.mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(content: Text('사용자 정보를 불러오는데 실패했습니다.'))
  //           );
  //         }
  //       }
  //     }
  //   },
  //   icon: Icon(Icons.person_rounded),
  // ),
IconButton(
  onPressed: () async {
    try {
      final accessToken = await TokenManager.getAccessToken();
      
      if (accessToken == null || accessToken.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다.'))
        );
        context.go('/login');
        return;
      }

      // 🔥 변경점: 2단계 조회로 전체 정보 가져오기
      final authUseCase = ref.read(authUseCaseProvider);
      
      // 1단계: 기본 정보로 uid 얻기
      final basicUser = await authUseCase.getCurrentUser();
      
      // 2단계: 전체 프로필 정보 조회
      final fullUser = await authUseCase.getProfileUser(uid: basicUser.uid);

      if (context.mounted) {
        GoRouter.of(context).push('/user', extra: fullUser);
      }
      
    } catch (e) {
      debugPrint('사용자 불러오기 실패: $e');
      
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        await TokenManager.clearTokens();
        ref.read(accessTokenProvider.notifier).state = null;
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그인이 만료되었습니다. 다시 로그인해주세요.'))
          );
          context.go('/login');
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('사용자 정보를 불러오는데 실패했습니다.'))
          );
        }
      }
    }
  },
  icon: const Icon(Icons.person_rounded),
),


  IconButton(
    onPressed: () {},
    icon: Icon(Icons.notifications_rounded),
  ),
],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
