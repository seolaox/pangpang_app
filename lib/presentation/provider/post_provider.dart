import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/domain/use_case/post_use_case.dart';
import 'package:pangpang_app/presentation/vm/post_vm.dart';


final imageListProvider = StateNotifierProvider<ImageListNotifier, List<dynamic>>(
  (ref) => ImageListNotifier(),
);

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

class PostCrudNotifier extends StateNotifier<AsyncValue<void>> {
  final PostUseCase _postUseCase;
  final Ref _ref;

  PostCrudNotifier(this._postUseCase, this._ref) : super(const AsyncValue.data(null));

  Future<void> createPost(FormData formData) async {
    state = const AsyncValue.loading();
    
    final result = await _postUseCase.createPost(formData);
    
    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (_) {
        _ref.invalidate(postListProvider);
        state = const AsyncValue.data(null);
      },
    );
  }

  Future<void> updatePost(String postId, FormData formData) async {
    state = const AsyncValue.loading();
    
    final result = await _postUseCase.updatePost(postId, formData);
    
    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (_) {
        _ref.invalidate(postListProvider);
        state = const AsyncValue.data(null);
      },
    );
  }

  Future<void> deletePost(String postId) async {
    state = const AsyncValue.loading();
    
    final result = await _postUseCase.deletePost(postId);
    
    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (_) {
        _ref.invalidate(postListProvider);
        state = const AsyncValue.data(null);
      },
    );
  }
}
