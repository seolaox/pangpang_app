import 'package:pangpang_app/data/model/user/login_model.dart';
import 'package:pangpang_app/data/model/user/user_model.dart';
import 'package:pangpang_app/domain/repository/user_repo_abst.dart';

class AuthUseCase {
  final UserRepoAbst _userRepoAbst;

  AuthUseCase(this._userRepoAbst);

  Future<LoginResult> loginUser({required String idText, required String pwText}) async {
    return await _userRepoAbst.loginUser(idText, pwText);
  }

  Future<UserModel> getCurrentUser() async {
    return await _userRepoAbst.getCurrentUser();
  }

    Future<UserModel> getProfileUser({required String uid}) async {
  return await _userRepoAbst.getProfileUser(uid);
}
}