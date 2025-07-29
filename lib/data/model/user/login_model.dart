import 'package:pangpang_app/data/model/user/user_model.dart';

class LoginResult {
  final bool loginResult;
  final String loginResultText;
  final List<UserModel> userInfoList;
  final String accessToken;
  final String refreshToken;

  LoginResult({
    required this.loginResult,
    required this.loginResultText,
    required this.userInfoList,
    this.accessToken = '',
    this.refreshToken = '',
  });
}
