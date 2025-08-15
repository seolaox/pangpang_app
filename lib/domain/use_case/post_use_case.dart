import 'package:dio/dio.dart';
import 'package:pangpang_app/data/model/post_model.dart';
import 'package:pangpang_app/domain/repository/post_repo_abst.dart';

class PostUseCase {
  final PostRepoAbst _postRepoAbst;

  PostUseCase(this._postRepoAbst);

  Future<List<PostModel>> fetchPosts({int page = 1, int size = 10, FormData? formData}) async {
    return await _postRepoAbst.fetchPosts(page: page, size: size, formData: formData);
  }

  Future<void> createPost(FormData formData) async {
    return await _postRepoAbst.createPost(formData);
  }

  Future<void> updatePost(String postId, FormData formData) async {
    return await _postRepoAbst.updatePost(postId, formData);
  }

  Future<void> deletePost(String postId) async {
    return await _postRepoAbst.deletePost(postId);
  }
}