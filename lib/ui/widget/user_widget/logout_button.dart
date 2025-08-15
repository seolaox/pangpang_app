import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pangpang_app/presentation/provider/auth_provider/auth_provider.dart';
import 'package:pangpang_app/presentation/vm/auth_vm/auth_vm.dart';
import 'package:pangpang_app/util/token_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () => _showLogoutDialog(context, ref),
      icon: const Icon(Icons.logout),
      label: const Text('로그아웃'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _performLogout(context, ref);
              },
              child: const Text(
                '로그아웃',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context, WidgetRef ref) async {
    try {
      // 1. 토큰 삭제
      await TokenManager.clearTokens();
      
      // 2. SharedPreferences 삭제
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('autoLogin', false);
      await prefs.setBool('isLoggedIn', false);

      // 3. Provider 상태 초기화
      ref.read(loginVmProvider.notifier).resetState();
      ref.read(accessTokenProvider.notifier).clearToken();
      ref.read(idTextProvider).clear();
      ref.read(pwTextProvider).clear();

      // 4. 로그인 페이지로 이동
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그아웃 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }
}