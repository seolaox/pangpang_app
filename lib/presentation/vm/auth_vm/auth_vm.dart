import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/data/model/user/login_model.dart';
import 'package:pangpang_app/data/model/user/user_model.dart';
import 'package:pangpang_app/presentation/provider/auth_provider/auth_provider.dart';
import 'package:pangpang_app/util/token_manager.dart';

// Text Controllers
final idTextProvider = StateProvider.autoDispose<TextEditingController>(
  (ref) => TextEditingController(),
);

final pwTextProvider = StateProvider.autoDispose<TextEditingController>(
  (ref) => TextEditingController(),
);


class LoginVmClassProvider extends Notifier<LoginResult> {
  @override
  LoginResult build() {
    return LoginResult(
      loginResult: false,
      loginResultText: '',
      userInfoList: [],
    );
  }

    //상태 초기화 함수
    void resetState() {
    state = LoginResult(
      loginResult: false,
      loginResultText: '',
      userInfoList: [],
    );
  }

  Future<List<UserModel>> getLoginInfo() async {
    try {

      final authUseCase = ref.read(authUseCaseProvider);
      final idController = ref.read(idTextProvider);
      final pwController = ref.read(pwTextProvider);

      final result = await authUseCase.loginUser(
        idText: idController.text,
        pwText: pwController.text,
      );

      await TokenManager.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      state = result;
      return result.userInfoList;
    } catch (e) {
      print('Error in getLoginInfo: $e');
      // 에러 발생 시 빈 리스트 반환
      return [];
    }
  }
}

// 현재 사용자 정보를 관리하는 provider
final currentUserProvider = FutureProvider.autoDispose<UserModel>((ref) async {
  try {
    final user = await ref.read(authUseCaseProvider).getCurrentUser();
    return user;
  } catch (e) {
    print('Error in currentUserProvider: $e');
    rethrow;
  }
});
