import 'package:dio/dio.dart';
import 'package:pangpang_app/data/model/post_model.dart';
import 'package:pangpang_app/domain/repository/post_repo_abst.dart';
import 'package:pangpang_app/core/result.dart';

class PostUseCase {
  final PostRepoAbst _postRepoAbst;

  PostUseCase(this._postRepoAbst);

  Future<Result<List<PostModel>>> fetchPosts({int page = 1, int size = 10, FormData? formData}) async {
    return await _postRepoAbst.fetchPosts(page: page, size: size, formData: formData);
  }

  Future<Result<void>> createPost(FormData formData) async {
    if (formData.files.isEmpty) {
      return Result.failure('이미지를 1개 이상 선택해주세요');
    }
    
    return await _postRepoAbst.createPost(formData);
  }

  Future<Result<void>> updatePost(String postId, FormData formData) async {
    if (postId.isEmpty) {
      return Result.failure('유효하지 않은 게시글입니다');
    }
    
    return await _postRepoAbst.updatePost(postId, formData);
  }

  Future<Result<void>> deletePost(String postId) async {
    if (postId.isEmpty) {
      return Result.failure('유효하지 않은 게시글입니다');
    }
    
    return await _postRepoAbst.deletePost(postId);
  }
}
