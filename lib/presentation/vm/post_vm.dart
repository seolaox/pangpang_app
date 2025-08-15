import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/domain/use_case/post_use_case.dart';
import 'package:pangpang_app/presentation/provider/post_provider.dart';

class PostVm extends StateNotifier<AsyncValue<void>> {
  final PostUseCase _postUseCase;
  final Ref _ref;

  PostVm(this._postUseCase, this._ref) : super(const AsyncValue.data(null));

  Future<void> createPost(FormData formData) async {
    state = const AsyncValue.loading();
    try {
      await _postUseCase.createPost(formData);
      _ref.invalidate(postListProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updatePost(String postId, FormData formData) async {
    state = const AsyncValue.loading();
    try {
      await _postUseCase.updatePost(postId, formData);
      _ref.invalidate(postListProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deletePost(String postId) async {
    state = const AsyncValue.loading();
    try {
      await _postUseCase.deletePost(postId);
      _ref.invalidate(postListProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Post VM Provider
final postVmProvider = StateNotifierProvider<PostVm, AsyncValue<void>>((ref) {
  final postUseCase = ref.watch(postUseCaseProvider);
  return PostVm(postUseCase, ref);
});