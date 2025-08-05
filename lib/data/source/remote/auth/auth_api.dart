import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pangpang_app/data/model/post_model.dart';
import 'package:pangpang_app/data/model/user/login_model.dart';
import 'package:pangpang_app/data/model/user/user_model.dart';
import 'package:pangpang_app/util/api_endpoint.dart';
import 'package:dio/dio.dart';
import 'package:pangpang_app/util/token_manager.dart';

class AuthApi {
  final Dio _dio = Dio();

  String? baseUrl = dotenv.env['baseurl'];

  /// @@@ login Api request
  /// return 값들
  /// 1. login data (usermodel)
  /// 2. login status (bool)
  /// 3. login resultText (String)
  Future<LoginResult> loginUserApi({
    required String idText,
    required String pwText,
  }) async {
    bool loginResult = false;
    String loginResultText = '';
    List<UserModel> userInfoList = [];
    String accessToken = '';
    String refreshToken = '';

    if (idText.isNotEmpty && pwText.isNotEmpty) {
      String url = '$baseUrl${ApiEndpoint.loginUser}';

      try {
        final response = await _dio.post(
          url,
          data: {'uid': idText, 'upw': pwText},
          options: Options(headers: {'Content-Type': 'application/json'}),
        );
        if (response.statusCode == 200) {
          loginResult = true;

          try {
            final data = response.data as Map<String, dynamic>;
            // 토큰 저장
            accessToken = data['access_token'] ?? '';
            refreshToken = data['refresh_token'] ?? '';
            print('accessToken: $accessToken');

            // FCM 토큰 업데이트
            try {
              // final fcmService = FCMService();
              // String? fcmToken = await fcmService.getFCMToken();
              // if (fcmToken != null) {
              // await updateFCMToken(idText, fcmToken);
              // }
            } catch (e) {
              print('FCM Token retrieval error: $e');
              // FCM 토큰을 가져오지 못해도 로그인은 계속 진행
            }

            if (data.containsKey('user')) {
              final userData = data['user'] as Map<String, dynamic>;
              userInfoList.add(UserModel.fromMap(userData));
            } else {
              print('No user data in response');
              loginResultText = "서버 응답에 사용자 정보가 없습니다.";
            }
          } catch (e) {
            print('Error parsing response: $e');
            loginResultText = "서버 응답 처리 중 오류가 발생했습니다.";
          }
        }
      } catch (e) {
        loginResultText = "아이디나 비밀번호를 확인해주세요.";
        print('Error: $e');
      }
    } else {
      loginResultText = "아이디나 비밀번호를 입력해주세요.";
    }

    return LoginResult(
      loginResult: loginResult,
      loginResultText: loginResultText,
      userInfoList: userInfoList,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  // 사용자 정보 조회 API 추가
  Future<UserModel> getCurrentUserApi() async {
    try {
      final token = await TokenManager.getAccessToken();
      String url = '$baseUrl${ApiEndpoint.getCurrentUser}';
      final response = await _dio.get(
        url, // 새로운 엔드포인트 필요
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        // fromJson 대신 fromMap 사용
        return UserModel.fromMap(response.data);
      } else {
        throw Exception('Failed to get current user');
      }
    } catch (e) {
      print('Error getting current user: $e');
      rethrow;
    }
  }

  //프로필 가져오는 api
  Future<UserModel> getProfileUserApi(String uid) async {
    final token = await TokenManager.getAccessToken();
    String url = '$baseUrl${ApiEndpoint.getProfile}/$uid';
    final response = await _dio.get(
      url,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.statusCode == 200) {
      final user = UserModel.fromMap(response.data);
      print('families: ${user.families}');
      for (final fam in user.families) {
        print('가족 이름: ${fam.family.fname}');
        print('리더: ${fam.family.leader_uid}');
        print('상태: ${fam.status}');
      }
      print('animals: ${user.animals}');
      for (final animal in user.animals) {
        print('동물이름: ${animal.aname}');
        print('소개: ${animal.aintroduction}');
      }
      return user;
    } else {
      throw Exception('사용자 플로필 가져오기 실패');
    }
  }



  Future<List<PostModel>> fetchPosts({int page = 1, int size = 10}) async {
    final url = '$baseUrl${ApiEndpoint.postList}?page=$page&size=$size';
    final response = await _dio.get(url);

    if (response.statusCode == 200) {
      final data = response.data;
      // print(data);
      final postsJson = data['posts'] as List<dynamic>;
      return postsJson.map((json) => PostModel.fromJson(json)).toList();
    } else {
      throw Exception('게시글을 불러오는데 실패했습니다');
    }
  }

  Future createPostFormData(FormData formData) async {
  final token = await TokenManager.getAccessToken();
  final url = '$baseUrl${ApiEndpoint.postCreate}'; 

  final response = await _dio.post(
    url,
    data: formData,
    options: Options(
      contentType: 'multipart/form-data',
      headers: {'Authorization': 'Bearer $token'},
      validateStatus: (status) => status != null && status >= 200 && status < 300,
    ),
  );
  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception('게시글 생성 실패: ${response.statusCode}');
  }
  return response.data;
}

Future updatePostFormData(int postId, FormData formData) async {
  final token = await TokenManager.getAccessToken();
  final url = '$baseUrl${ApiEndpoint.postUpdate}/$postId'; 

  final response = await _dio.put(
    url,
    data: formData,
    options: Options(
      contentType: 'multipart/form-data',
      headers: {'Authorization': 'Bearer $token'},
      validateStatus: (status) => status != null && status >= 200 && status < 300,
    ),
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception('게시글 수정 실패: ${response.statusCode}');
  }
  return response.data;
}


  Future<void> deletePost(int postId) async {
    final url = '$baseUrl${ApiEndpoint.postDelete}/$postId';
    final token = await TokenManager.getAccessToken();
    final response = await _dio.delete(
      url,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.statusCode != 200) {
      throw Exception('글 삭제 실패');
    }
  }
}
