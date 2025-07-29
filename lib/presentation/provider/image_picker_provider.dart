import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final selectedImagesProvider = StateNotifierProvider<SelectedImagesNotifier, List<XFile>>(
  (ref) => SelectedImagesNotifier(),
);

class SelectedImagesNotifier extends StateNotifier<List<XFile>> {
  SelectedImagesNotifier() : super([]);
  void addImages(List<XFile> images) => state = [...state, ...images];
  void clear() => state = [];
  void removeAt(int idx) {
    if (idx >= 0 && idx < state.length) {
      final newList = [...state];
      newList.removeAt(idx);
      state = newList;
    }
  }
}

