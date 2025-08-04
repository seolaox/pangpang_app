import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pangpang_app/data/model/post_model.dart';

import 'package:pangpang_app/data/source/remote/auth/auth_api.dart';

final authApiProvider = Provider((ref) => AuthApi());

final postListProvider = FutureProvider.autoDispose<List<PostModel>>((ref) async {
  final authApi = ref.watch(authApiProvider);
  return await authApi.fetchPosts(page: 1, size: 10);
});

final thumbnailIndexProvider = StateProvider<int>((ref) => 0);

class ImageListNotifier extends StateNotifier<List<dynamic>> {
  ImageListNotifier() : super([]);

  void setImages(List<dynamic> imgs) {
    state = imgs;
  }

  void addImage(dynamic img) {
    if (state.length < 5) state = [...state, img];
  }

  void removeImage(int idx) {
    state = [...state]..removeAt(idx);
  }

  void clear() => state = [];
}

final imageListProvider = StateNotifierProvider<ImageListNotifier, List<dynamic>>(
  (ref) => ImageListNotifier(),
);
