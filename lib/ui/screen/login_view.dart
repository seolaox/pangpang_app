import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pangpang_app/presentation/provider/auth_provider/auth_provider.dart';
import 'package:pangpang_app/presentation/vm/auth_vm/auth_vm.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool value = false; // 체크박스 선택 여부

  void onChanged(bool? newValue) {
    setState(() {
      value = newValue ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginVm = ref.watch(loginVmProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // 로고 또는 앱 이름
                Icon(
                  Icons.favorite,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  '팡팡',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '로그인하고 시작하세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 60),

                // 이메일 입력 필드
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: ref.watch(idTextProvider),
                    decoration: InputDecoration(
                      hintText: '아이디',
                      prefixIcon: Icon(
                        Icons.person_outlined,
                        color: Colors.grey[400],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '아이디를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // 비밀번호 입력 필드
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: ref.watch(pwTextProvider),
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: '비밀번호',
                      prefixIcon: Icon(
                        Icons.lock_outlined,
                        color: Colors.grey[400],
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey[400],
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 입력해주세요';
                      }
                      // if (value.length < 6) {
                      //   return '비밀번호는 6자 이상이어야 합니다';
                      // }
                      return null;
                    },
                  ),
                ),
                Row(
                  children: [
                    Text('자동 로그인'),
                    Checkbox(value: value, onChanged: onChanged),
                  ],
                ),
                const SizedBox(height: 30),

                // 로그인 버튼
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final success =
                            await ref
                                .read(loginVmProvider.notifier)
                                .getLoginInfo();

                        if (success.isNotEmpty && context.mounted) {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('autoLogin', value);
                          GoRouter.of(context).go('/first_view');
                        } else {
                          print('로그인 실패');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('로그인에 실패했습니다.')),
                            );
                          }
                        }
                      } catch (e) {
                        print('로그인 에러: $e');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('로그인 중 오류가 발생했습니다: $e')),
                          );
                        }
                      }
                    } else {
                      print('폼 검증 실패');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    '로그인하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),

                // 가입하기 버튼
                OutlinedButton(
                  onPressed: () {
                    // 가입 페이지로 이동 로직 구현
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('가입 페이지로 이동...')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '가입하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
