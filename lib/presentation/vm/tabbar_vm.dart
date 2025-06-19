import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabbarVM extends Notifier<int> {
  @override
  int build() {
    return 0; // 기본값은 첫 번째 탭
  }

  // 탭 변경 메서드
  void changeTab(int index) {
    state = index;
  }

  // Future<void> moveToChat() async {
  //   state = 1;
  //   await Future.delayed(const Duration(milliseconds: 100));
  // }
}
