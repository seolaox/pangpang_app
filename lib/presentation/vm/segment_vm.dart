import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/data/model/segment_model.dart';

class SegmentVM extends Notifier<Settings> {
  @override
  Settings build() {
    return Settings.all;
  }

  void changeSegment(Settings segment) {
    state = segment;
  }
}
