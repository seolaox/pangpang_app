import 'package:pangpang_app/data/model/user/login_model.dart';
import 'package:pangpang_app/data/model/user/user_model.dart';

abstract class UserRepoAbst {
  Future<LoginResult> loginUser(String idText, String pwText);
  Future<UserModel> getCurrentUser();
  Future getProfileUser(String uid);
}