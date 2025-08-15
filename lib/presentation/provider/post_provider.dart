import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pangpang_app/data/model/post_model.dart';
import 'package:pangpang_app/data/repository/post_repo_impl.dart';

import 'package:pangpang_app/data/source/remote/auth/auth_api.dart';
import 'package:pangpang_app/data/source/remote/post_api.dart';
import 'package:pangpang_app/domain/use_case/post_use_case.dart';

// final authApiProvider = Provider((ref) => AuthApi());

// Use Case Provider
final postUseCaseProvider = Provider<PostUseCase>((ref) {
  return PostUseCase(PostRepoImpl(PostApi()));
});

// Post List Provider
final postListProvider = FutureProvider.autoDispose<List<PostModel>>((ref) async {
  final postUseCase = ref.watch(postUseCaseProvider);
  return await postUseCase.fetchPosts(page: 1, size: 10);
});

// Thumbnail Index Provider
final thumbnailIndexProvider = StateProvider<int>((ref) => 0);

// Image List Notifier
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