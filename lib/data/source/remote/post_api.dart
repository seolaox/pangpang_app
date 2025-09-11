import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pangpang_app/data/model/post_model.dart';
import 'package:pangpang_app/data/source/remote/dio_client.dart';
import 'package:pangpang_app/util/api_endpoint.dart';
import 'package:dio/dio.dart';
import 'package:pangpang_app/util/token_manager.dart';

class PostApi {
  Dio get _dio => DioClient().dio;

  String? baseUrl = dotenv.env['baseurl'];

  Future<List<PostModel>> fetchPostsApi({int page = 1, int size = 10, FormData? formData}) async {
    final token = await TokenManager.getAccessToken();
    final url = '$baseUrl${ApiEndpoint.postList}?page=$page&size=$size';
    
    final response = await _dio.get(
      url,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        headers: {'Authorization': 'Bearer $token'},
        validateStatus: (status) => status != null && status >= 200 && status < 300,
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      
      // 서버 응답이 배열인지 객체인지 확인
      if (data is List) {
        // 직접 배열로 응답하는 경우
        return data.map((json) => PostModel.fromJson(json)).toList();
      } else if (data is Map<String, dynamic>) {
        // posts 키가 있는 객체로 응답하는 경우
        final postsJson = data['posts'] as List<dynamic>? ?? data['data'] as List<dynamic>? ?? [];
        return postsJson.map((json) => PostModel.fromJson(json)).toList();
      } else {
        throw Exception('예상하지 못한 응답 형식');
      }
    } else {
      throw Exception('게시글을 불러올 수 없습니다: ${response.statusCode}');
    }
  }

  Future<void> createPostApi(FormData formData) async {
    final token = await TokenManager.getAccessToken();
    final url = '$baseUrl${ApiEndpoint.postCreate}';

    final response = await _dio.post(
      url,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        headers: {'Authorization': 'Bearer $token'},
        validateStatus: (status) => status != null && status >= 200 && status < 300,
      ),
    );
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('게시글 생성 실패: ${response.statusCode} - ${response.data}');
    }
  }

  Future<void> updatePostApi(String postId, FormData formData) async {
    final token = await TokenManager.getAccessToken();
    final url = '$baseUrl${ApiEndpoint.postUpdate}/$postId';

    final response = await _dio.put(
      url,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        headers: {'Authorization': 'Bearer $token'},
        validateStatus: (status) => status != null && status >= 200 && status < 300,
      ),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('게시글 수정 실패: ${response.statusCode} - ${response.data}');
    }
  }

  Future<void> deletePostApi(String postId) async {
    final url = '$baseUrl${ApiEndpoint.postDelete}/$postId';
    final token = await TokenManager.getAccessToken();
    final response = await _dio.delete(
      url,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.statusCode != 200) {
      throw Exception('글 삭제 실패: ${response.statusCode} - ${response.data}');
    }
  }
}