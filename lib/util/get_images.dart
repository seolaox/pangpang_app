import 'package:pangpang_app/util/api_endpoint.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GetImages {
      String? baseUrl = dotenv.env['baseurl'];

  /// @@@ 서버의 이미지를 받아오는 함수
  /// @@Prams: int category: 0은 유저 프로필 이미지
  /// @@Prams: String fileName: db상에서 가져온 서버에 저장된 파일 이름
  getImg({required String category, required String fileName}) {
    String url = '$baseUrl${ApiEndpoint.getImages}/$category/$fileName';
    return url;
  }

}