import 'package:dio/dio.dart';
import 'package:pangpang_app/data/model/post_model.dart';
import 'package:pangpang_app/data/source/remote/post_api.dart';
import 'package:pangpang_app/domain/repository/post_repo_abst.dart';

class PostRepoImpl implements PostRepoAbst {
  final PostApi _postApi;

  PostRepoImpl(this._postApi);

  @override
  Future<List<PostModel>> fetchPosts({int page = 1, int size = 10, FormData? formData}) async {
    return await _postApi.fetchPostsApi(page: page, size: size, formData: formData);
  }

  @override
  Future<void> createPost(FormData formData) async {
    return await _postApi.createPostApi(formData);
  }

  @override
  Future<void> updatePost(String postId, FormData formData) async {
    return await _postApi.updatePostApi(postId, formData);
  }

  @override
  Future<void> deletePost(String postId) async {
    return await _postApi.deletePostApi(postId);
  }
}