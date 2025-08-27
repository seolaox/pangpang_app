import 'package:dio/dio.dart';
import 'package:pangpang_app/data/model/post_model.dart';
import 'package:pangpang_app/core/result.dart';

abstract class PostRepoAbst {
  Future<Result<List<PostModel>>> fetchPosts({int page = 1, int size = 10, FormData? formData});
  Future<Result<void>> createPost(FormData formData);
  Future<Result<void>> updatePost(String postId, FormData formData);
  Future<Result<void>> deletePost(String postId);
}