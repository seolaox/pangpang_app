import 'package:pangpang_app/data/model/user/login_model.dart';
import 'package:pangpang_app/data/model/user/user_model.dart';
import 'package:pangpang_app/data/source/remote/auth/auth_api.dart';
import 'package:pangpang_app/domain/repository/user_repo_abst.dart';

class UserRepoImpl implements UserRepoAbst {
  final AuthApi _authApi;

  UserRepoImpl(this._authApi);

  @override
  Future<LoginResult> loginUser(String idText, String pwText) async {
    return await _authApi.loginUserApi(idText: idText, pwText: pwText);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    return await _authApi.getCurrentUserApi();
  }

    @override
  Future getProfileUser(String uid) async {
    return await _authApi.getProfileUserApi(uid);
  }
} 