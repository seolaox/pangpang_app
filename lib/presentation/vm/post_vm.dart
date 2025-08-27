import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/data/model/post_model.dart';
import 'package:pangpang_app/data/repository/post_repo_impl.dart';
import 'package:pangpang_app/data/source/remote/post_api.dart';
import 'package:pangpang_app/domain/repository/post_repo_abst.dart';
import 'package:pangpang_app/domain/use_case/post_use_case.dart';
import 'package:pangpang_app/presentation/provider/post_provider.dart';

final postApiProvider = Provider<PostApi>((ref) {
  return PostApi();
});

final postRepositoryProvider = Provider<PostRepoAbst>((ref) {
  return PostRepoImpl(ref.watch(postApiProvider));
});

final postUseCaseProvider = Provider<PostUseCase>((ref) {
  return PostUseCase(ref.watch(postRepositoryProvider));
});

final postListProvider = FutureProvider.autoDispose<List<PostModel>>((ref) async {
  final postUseCase = ref.watch(postUseCaseProvider);
  final result = await postUseCase.fetchPosts(page: 1, size: 10);
  
  return result.fold(
    (error) => throw Exception(error),
    (posts) => posts,
  );
});

final thumbnailIndexProvider = StateProvider<int>((ref) => 0);

final postCrudProvider = StateNotifierProvider<PostCrudNotifier, AsyncValue<void>>((ref) {
  final postUseCase = ref.watch(postUseCaseProvider);
  return PostCrudNotifier(postUseCase, ref);
});
