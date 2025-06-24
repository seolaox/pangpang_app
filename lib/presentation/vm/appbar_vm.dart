import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

// 상태를 관리할 클래스
class AppBarState {
  final bool isWalking; // swtich 상태
  final int elapsedSeconds; // 산책 시간 상태
  
  AppBarState({
    required this.isWalking,
    required this.elapsedSeconds,
  });
  
  AppBarState copyWith({
    bool? isWalking,
    int? elapsedSeconds,
  }) {
    return AppBarState(
      isWalking: isWalking ?? this.isWalking,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}

class AppBarVM extends Notifier<AppBarState> {
  Timer? _timer;
  
  @override
  AppBarState build() {
    return AppBarState(isWalking: false, elapsedSeconds: 0);
  }

  void toggleSwitch(bool value) {
    state = state.copyWith(isWalking: value);
    
    if (value) {
      // Switch가 켜지면 타이머 시작
      _startTimer();
    } else {
      // Switch가 꺼지면 타이머 정지
      _stopTimer();
    }
  }
  
  void _startTimer() {
    _stopTimer(); // 기존 타이머가 있다면 정지
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      // print('애니메이션 실행 시간: ${state.elapsedSeconds}초');
    });
  }
  
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
  
  // 현재 경과 시간 반환 (초 단위)
  int get elapsedSeconds => state.elapsedSeconds;
  
  // 시간을 시:분:초 형식으로 반환
  String get formattedTime {
    int hours = state.elapsedSeconds ~/ 3600;
    int minutes = (state.elapsedSeconds % 3600) ~/ 60;
    int seconds = state.elapsedSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')} : ${minutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2, '0')}';
    }
  }
  
  // 타이머 리셋
  void resetTimer() {
    state = state.copyWith(elapsedSeconds: 0);
  }
}

class IsWalkingVM extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void toggleIsWalking(bool value) {
    state = value;
  }
}