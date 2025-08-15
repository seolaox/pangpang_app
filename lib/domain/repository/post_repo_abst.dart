import 'package:dio/dio.dart';
import 'package:pangpang_app/data/model/post_model.dart';

abstract class PostRepoAbst {
  Future<List<PostModel>> fetchPosts({int page = 1, int size = 10, FormData? formData});
  Future<void> createPost(FormData formData);
  Future<void> updatePost(String postId, FormData formData);
  Future<void> deletePost(String postId);
}