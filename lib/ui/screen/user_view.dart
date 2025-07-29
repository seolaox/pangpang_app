import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pangpang_app/data/model/user/user_model.dart';
import 'package:pangpang_app/presentation/provider/auth_provider/auth_provider.dart';
import 'package:pangpang_app/presentation/vm/auth_vm/auth_vm.dart';
import 'package:pangpang_app/ui/widget/image_widget/profile_image_widget.dart';
import 'package:pangpang_app/util/style/my_text_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pangpang_app/util/token_manager.dart';
import 'package:go_router/go_router.dart';

class UserView extends ConsumerWidget {
  final UserModel user;
  const UserView({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: myTextStyle('내 정보', 24.sp, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    profileImageWidget(
                      context: context,
                      size: 100.w,
                      profileImg: user.uimage,
                      category: 'user',
                    ),
                    myTextStyle(user.uname, 20.sp, fontWeight: FontWeight.bold),
                    Text(
                      '아이디: ${user.uid}',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(width: 24.w),
                Expanded(
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '가족 정보',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          if (user.families != null && user.families.isNotEmpty)
                            ...user.families
                                .map(
                                  (fam) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('이름: ${fam.family.fname}'),
                                      Text('리더: ${fam.family.leader_uid}'),
                                      Text('상태: ${fam.status}'),
                                      Divider(),
                                    ],
                                  ),
                                )
                                .toList()
                          else
                            Text(
                              '가족 정보 없음',
                              style: TextStyle(color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 28.h),
            Text(
              '동물 목록',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10.h),
            user.animals != null && user.animals.isNotEmpty
                ? Column(
                  children:
                      user.animals
                          .map(
                            (animal) => Card(
                              elevation: 2,
                              margin: EdgeInsets.symmetric(vertical: 8.h),
                              child: ListTile(
                                leading:
                                    animal.aimage != null &&
                                            animal.aimage!.isNotEmpty
                                        ? profileImageWidget(
                                          context: context,
                                          size: 56.w,
                                          profileImg: animal.aimage,
                                          category: 'animal',
                                        )
                                        : Icon(Icons.pets, size: 56.w),
                                title: Text(animal.aname),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('소개: ${animal.aintroduction ?? ''}'),
                                    Text(
                                      '생일: ${animal.abirthday != null ? animal.abirthday!.split('T')[0] : ''}',
                                    ),
                                    Text('품종: ${animal.abreed ?? ''}'),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                )
                : Center(
                  child: Text('동물 정보 없음', style: TextStyle(color: Colors.grey)),
                ),
            SizedBox(height: 24.h),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await TokenManager.clearTokens();
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('autoLogin', false);
                  await prefs.setBool('isLoggedIn', false);

                  ref.read(loginVmProvider.notifier).resetState();
                  ref.read(idTextProvider).clear();
                  ref.read(pwTextProvider).clear();

                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                child: Text('로그아웃'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
