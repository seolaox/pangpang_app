import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pangpang_app/util/token_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
     // 저장된 accessToken 읽기
    final accessToken = await TokenManager.getAccessToken();

    if (!mounted) return; // 화면이 dispose된 경우 방지

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (accessToken != null && accessToken.isNotEmpty) {
      context.go('/first_view');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  
}