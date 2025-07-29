import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/data/model/user/login_model.dart';
import 'package:pangpang_app/data/repository/user_repo_impl.dart';
import 'package:pangpang_app/data/source/remote/auth/auth_api.dart';
import 'package:pangpang_app/domain/use_case/auth/auth_use_case.dart';
import 'package:pangpang_app/presentation/vm/auth_vm/auth_vm.dart';


// Use Case Provider
final authUseCaseProvider = Provider<AuthUseCase>((ref) {
  return AuthUseCase(UserRepoImpl(AuthApi()));
});

// Login VM Provider
final loginVmProvider = NotifierProvider<LoginVmClassProvider, LoginResult>(
  LoginVmClassProvider.new,
);

