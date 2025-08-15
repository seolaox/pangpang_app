import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pangpang_app/data/model/user/login_model.dart';
import 'package:pangpang_app/data/repository/user_repo_impl.dart';
import 'package:pangpang_app/data/source/remote/auth/auth_api.dart';
import 'package:pangpang_app/domain/use_case/auth/auth_use_case.dart';
import 'package:pangpang_app/presentation/vm/auth_vm/auth_vm.dart';
import 'package:pangpang_app/util/token_manager.dart';


//storageProvider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) => FlutterSecureStorage());


// Use Case Provider
final authUseCaseProvider = Provider<AuthUseCase>((ref) {
  return AuthUseCase(UserRepoImpl(AuthApi()));
});

// Login VM Provider
final loginVmProvider = NotifierProvider<LoginVmClassProvider, LoginResult>(
  LoginVmClassProvider.new,
);

// 개선된 Access Token Provider
final accessTokenProvider = StateNotifierProvider<AccessTokenNotifier, String?>((ref) {
  return AccessTokenNotifier();
});

class AccessTokenNotifier extends StateNotifier<String?> {
  AccessTokenNotifier() : super(null) {
    _loadToken();
  }

  // 앱 시작시 토큰 로드
  Future<void> _loadToken() async {
    final token = await TokenManager.getAccessToken();
    state = token;
  }

  // 토큰 설정
  void setToken(String? token) {
    state = token;
  }

  // 토큰 삭제
  void clearToken() {
    state = null;
  }

  // 토큰 유효성 검사
  bool get isTokenValid => state != null && state!.isNotEmpty;
}

// 토큰 저장 헬퍼 함수 개선
Future<void> saveAccessToken(String token, WidgetRef ref) async {
  await TokenManager.saveAccessToken(token);
  ref.read(accessTokenProvider.notifier).setToken(token);
}

// 토큰 동기화 함수 추가
Future<void> syncTokenWithProvider(WidgetRef ref) async {
  final token = await TokenManager.getAccessToken();
  ref.read(accessTokenProvider.notifier).setToken(token);
}