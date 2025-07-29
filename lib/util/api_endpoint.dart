class ApiEndpoints {
  static ApiEndpoint apiEndpoint = ApiEndpoint();
}

class ApiEndpoint {
  static const String loginUser = 'user/login';
  static const String getCurrentUser = 'user/get/user_info';
  static const String getImages = "images/get/images";
  static const String getProfile = "user/get/profile";
  static const String getRefresh = "auth/refresh";
  static const String postImage = "images/upload";
}
