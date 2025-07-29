import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pangpang_app/util/token_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final autoLogin = prefs.getBool('autoLogin') ?? false;
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final token = await TokenManager.getAccessToken();

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (autoLogin && isLoggedIn && token != null && token.isNotEmpty) {
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