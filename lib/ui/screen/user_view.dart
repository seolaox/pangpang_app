// ui/screen/user_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pangpang_app/data/model/user/user_model.dart';
import 'package:pangpang_app/presentation/provider/user_provider.dart';
import 'package:pangpang_app/ui/widget/user_widget/animal_list.dart';
import 'package:pangpang_app/ui/widget/user_widget/family_profile.dart';
import 'package:pangpang_app/ui/widget/user_widget/logout_button.dart';
import 'package:pangpang_app/ui/widget/user_widget/user_profile.dart';
import 'package:pangpang_app/util/style/my_text_style.dart';

class UserView extends ConsumerStatefulWidget {
  final String? uid; // uid를 받아서 해당 사용자 정보 조회
  final UserModel? initialUser; // 초기 데이터 (옵션)

  const UserView({
    super.key,
    this.uid,
    this.initialUser,
  });

  @override
  ConsumerState<UserView> createState() => _UserViewState();
}

class _UserViewState extends ConsumerState<UserView> {
  @override
  void initState() {
    super.initState();
    
    // 초기 데이터 로딩
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final userNotifier = ref.read(userNotifierProvider.notifier);
    
    if (widget.uid != null) {
      // 특정 사용자 정보 로드
      userNotifier.loadUserProfile(widget.uid!);
    } else {
      // 🔥 현재 사용자 정보 로드 (전체 정보 포함)
      userNotifier.loadCurrentUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: myTextStyle('내 정보', 24.sp, fontWeight: FontWeight.bold),
      ),
      body: userState.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('사용자 정보를 불러오는 중...'),
            ],
          ),
        ),
        error: (error, stackTrace) => _buildErrorWidget(error),
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('사용자 정보를 찾을 수 없습니다.'),
            );
          }

          
          return _buildUserContent(user);
        },
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                '사용자 정보를 불러올 수 없습니다.',
                style: TextStyle(fontSize: 16.sp),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  error.toString(),
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadUserData,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserContent(UserModel user) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(), // RefreshIndicator용
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 불완전한 데이터 경고 표시
          if (user.families.isEmpty && user.animals.isEmpty) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.orange[300]!),
              ),
             
            ),
          ],
          
          // 프로필 섹션
          UserProfileSection(user: user),
          
          SizedBox(height: 24.h),
          
          // 동물 목록 섹션
          AnimalListSection(animals: user.animals),
          
          SizedBox(height: 24.h),
          
          // 로그아웃 버튼
          const Center(child: LogoutButton()),
        ],
      ),
    );
  }
}