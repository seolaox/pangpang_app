import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppBarVM extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void toggleSwitch(bool value) {
    state = value;
  }
}