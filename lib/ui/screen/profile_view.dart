import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pangpang_app/presentation/provider/auth_provider/auth_provider.dart';
import 'package:pangpang_app/presentation/vm/auth_vm/auth_vm.dart';
import 'package:pangpang_app/util/token_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return  Scaffold(
      body: Center(
        // child: Text('Profile'),
        child: ElevatedButton(
          onPressed: () async {
                  await TokenManager.clearTokens(); // SecureStorage에서 토큰 삭제
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('autoLogin', false);
                  await prefs.setBool('isLoggedIn', false);

                  ref.read(loginVmProvider.notifier).resetState(); // 로그인 상태 초기화
                  ref.read(idTextProvider).clear();
                  ref.read(pwTextProvider).clear();

                  if (context.mounted) {
                    context.go('/login'); // 로그인 화면으로 이동
                  }
                },
       child: Text('로그아웃')),
        
      ),
    );
  }
}