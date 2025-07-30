import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/data/model/post_model.dart';
import 'package:pangpang_app/data/source/remote/auth/auth_api.dart';

final authApiProvider = Provider<AuthApi>((ref) => AuthApi());

final postListProvider = FutureProvider.autoDispose<List<PostModel>>((ref) async {
  final authApi = ref.watch(authApiProvider);
  return await authApi.fetchPosts(page: 1, size: 10);
});
