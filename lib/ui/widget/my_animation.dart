import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:pangpang_app/presentation/provider/appbar_provider.dart';

class MyAnimation extends ConsumerWidget {
  const MyAnimation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appBarState = ref.watch(appBarProvider); // appBarProvider 사용

    return SizedBox(
      width: 50.w,
      height: 50.h,
      child: Lottie.asset(
        'assets/json/dog.json',
        repeat: appBarState.isWalking, // Switch가 켜져있을 때만 반복 재생
        fit: BoxFit.contain,
      ),
    );
  }
}