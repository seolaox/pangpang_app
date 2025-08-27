import 'package:dio/dio.dart';
import 'package:pangpang_app/data/model/post_model.dart';
import 'package:pangpang_app/data/source/remote/post_api.dart';
import 'package:pangpang_app/domain/repository/post_repo_abst.dart';
import 'package:pangpang_app/core/result.dart';

class PostRepoImpl implements PostRepoAbst {
  final PostApi _postApi;

  PostRepoImpl(this._postApi);

  @override
  Future<Result<List<PostModel>>> fetchPosts({int page = 1, int size = 10, FormData? formData}) async {
    try {
      final posts = await _postApi.fetchPostsApi(page: page, size: size, formData: formData);
      return Result.success(posts);
    } catch (e) {
      return Result.failure('게시글을 불러올 수 없습니다: $e');
    }
  }

  @override
  Future<Result<void>> createPost(FormData formData) async {
    try {
      await _postApi.createPostApi(formData);
      return Result.success(null);
    } catch (e) {
      return Result.failure('게시글 작성에 실패했습니다: $e');
    }
  }

  @override
  Future<Result<void>> updatePost(String postId, FormData formData) async {
    try {
      await _postApi.updatePostApi(postId, formData);
      return Result.success(null);
    } catch (e) {
      return Result.failure('게시글 수정에 실패했습니다: $e');
    }
  }

  @override
  Future<Result<void>> deletePost(String postId) async {
    try {
      await _postApi.deletePostApi(postId);
      return Result.success(null);
    } catch (e) {
      return Result.failure('게시글 삭제에 실패했습니다: $e');
    }
  }
}
