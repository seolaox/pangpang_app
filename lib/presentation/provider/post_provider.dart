import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/data/model/post_model.dart';
import 'package:pangpang_app/data/source/remote/auth/auth_api.dart';

final authApiProvider = Provider<AuthApi>((ref) => AuthApi());

final postListProvider = FutureProvider.autoDispose<List<PostModel>>((ref) async {
  final authApi = ref.watch(authApiProvider);
  return await authApi.fetchPosts(page: 1, size: 10);
});


final imageListProvider = StateNotifierProvider<ImageListNotifier, List<File>>(
  (ref) => ImageListNotifier(),
);

final thumbnailIndexProvider = StateProvider<int>((ref) => 0);

class ImageListNotifier extends StateNotifier<List<File>> {
  ImageListNotifier() : super([]);
  void addImage(File file) {
    if (state.length < 5) state = [...state, file];
  }
  void removeImage(int idx) {
    state = [
      ...state.sublist(0, idx),
      ...state.sublist(idx + 1),
    ];
  }
  // void moveToThumbnail(int idx) {
  //   if (idx == 0) return; // already
  //   final list = [...state];
  //   final img = list.removeAt(idx);
  //   state = [img, ...list]; // 썸네일 맨 위
  // }
  void clear() => state = [];
}