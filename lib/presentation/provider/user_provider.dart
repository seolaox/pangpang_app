import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/data/model/user/user_model.dart';
import 'package:pangpang_app/domain/use_case/auth/auth_use_case.dart';
import 'package:pangpang_app/presentation/provider/auth_provider/auth_provider.dart';

// 현재 사용자 정보 Provider (전체 정보 포함)
final currentUserProvider = FutureProvider.autoDispose<UserModel>((ref) async {
  final authUseCase = ref.watch(authUseCaseProvider);
  
  // 🔥 변경점: 2단계 조회로 전체 정보 가져오기
  try {
    // 1단계: 기본 정보로 uid 얻기
    final basicUser = await authUseCase.getCurrentUser();
    
    // 2단계: uid로 전체 프로필 정보 조회
    final fullUser = await authUseCase.getProfileUser(uid: basicUser.uid);
    
    return fullUser;
  } catch (e) {
    // 에러 발생시 기본 정보라도 반환
    return await authUseCase.getCurrentUser();
  }
});

// 특정 사용자 정보 Provider (uid 기반)
final userProfileProvider = FutureProvider.autoDispose.family<UserModel, String>((ref, uid) async {
  final authUseCase = ref.watch(authUseCaseProvider);
  return await authUseCase.getProfileUser(uid: uid);
});

// 사용자 상태 관리 (로딩, 에러 등)
class UserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthUseCase _authUseCase;

  UserNotifier(this._authUseCase) : super(const AsyncValue.loading());



  Future<void> loadCurrentUser() async {
    state = const AsyncValue.loading();
    try {
      // 1단계: 기본 사용자 정보로 uid 얻기
      final basicUser = await _authUseCase.getCurrentUser();
      
      // 2단계: uid로 전체 프로필 정보 조회
      final fullUser = await _authUseCase.getProfileUser(uid: basicUser.uid);
      
      state = AsyncValue.data(fullUser);
    } catch (e, stackTrace) {
      print('loadCurrentUser error: $e');
      
      // 전체 정보 조회 실패시 기본 정보라도 시도
      try {
        final basicUser = await _authUseCase.getCurrentUser();
        state = AsyncValue.data(basicUser);
      } catch (e2, stackTrace2) {
        state = AsyncValue.error(e2, stackTrace2);
      }
    }
  }

  // 특정 사용자 로드
  Future<void> loadUserProfile(String uid) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authUseCase.getProfileUser(uid: uid);
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }



}

final userNotifierProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserModel?>>((ref) {
  final authUseCase = ref.watch(authUseCaseProvider);
  return UserNotifier(authUseCase);
});