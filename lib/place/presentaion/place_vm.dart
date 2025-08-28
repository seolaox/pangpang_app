import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/data/source/remote/dio_client.dart';
import 'package:pangpang_app/place/data/datasource/place_datasource.dart';
import 'package:pangpang_app/place/data/repository/place_repo_impl.dart';
import 'package:pangpang_app/place/domain/usecase/add_favorite.dart';
import 'package:pangpang_app/place/domain/usecase/delete_favorite.dart';
import 'package:pangpang_app/place/domain/usecase/get_my_place.dart';
import 'package:pangpang_app/place/domain/usecase/hospital_usecase.dart';
import 'package:pangpang_app/place/domain/usecase/search_hospital.dart';

final dioProvider = Provider<Dio>((ref) => DioClient().dio);

final placeRemoteDataSourceProvider = Provider<PlaceRemoteDataSource>((ref) {
  return PlaceRemoteDataSourceImpl(ref.watch(dioProvider));
});

final placeRepositoryProvider = Provider((ref) {
  return PlaceRepositoryImpl(ref.watch(placeRemoteDataSourceProvider));
});


//동물병원 목록 조회
final getAnimalHospitalsUseCaseProvider = Provider((ref) {
  return GetAnimalHospitalsUseCase(ref.watch(placeRepositoryProvider));
});


// 즐겨찾기 추가
final addFavoritePlaceUseCaseProvider = Provider((ref) {
  return AddFavoritePlaceUseCase(ref.watch(placeRepositoryProvider));
});


//즐겨찾기 삭제
final deleteFavoritePlaceUseCaseProvider = Provider((ref) {
  return DeleteFavoritePlaceUseCase(ref.watch(placeRepositoryProvider));
});


//내 장소 목록 조회
final getMyPlacesUseCaseProvider = Provider((ref) {
  return GetMyPlacesUseCase(ref.watch(placeRepositoryProvider));
});


//병원 검색
final searchHospitalsUseCaseProvider = Provider((ref) {
  return SearchHospitalsUseCase(ref.watch(placeRepositoryProvider));
});


