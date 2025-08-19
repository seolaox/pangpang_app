class ApiEndpoints {
  static ApiEndpoint apiEndpoint = ApiEndpoint();
}

class ApiEndpoint {
  static const String loginUser = 'user/login';
  static const String getCurrentUser = 'user/get/user_info';
  static const String getImages = "images/get/images";
  static const String getProfile = "user/get/profile";
  static const String getRefresh = "auth/refresh";
  static const String postList = "post/list";
  static const String postCreate = "post/create";
  static const String postUpdate = "post/update";
  static const String postDelete = "post/delete";

  static const String getPlaces = "place/my_places";
  static const String getAnimalHospitals = "place/animal_hospitals";

}
