import 'dart:io';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

// 비디오 상태 클래스
class VideoState {
  final XFile? videoFile;
  final VideoPlayerController? controller;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isLoading;
  final String? errorMessage;
  final bool showControl;

  const VideoState({
    this.videoFile,
    this.controller,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isLoading = false,
    this.errorMessage,
    this.showControl = true, // 기본값을 true로 변경
  });

  VideoState copyWith({
    XFile? videoFile,
    VideoPlayerController? controller,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? isLoading,
    String? errorMessage,
    bool? showControl,
  }) {
    return VideoState(
      videoFile: videoFile ?? this.videoFile,
      controller: controller ?? this.controller,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      showControl: showControl ?? this.showControl,
    );
  }
}

// Provider 선언
final videoProvider = StateNotifierProvider<VideoNotifier, VideoState>((ref) {
  return VideoNotifier();
});

// 비디오 상태 관리 Notifier
class VideoNotifier extends StateNotifier<VideoState> {
  Timer? _hideControlsTimer; // 자동 숨김 타이머 추가

  VideoNotifier() : super(const VideoState());

  // 비디오 선택
  Future<void> selectVideo() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final selectedVideo = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
      );
      
      if (selectedVideo != null) {
        await _initializeController(selectedVideo);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '비디오 선택 중 오류 발생: $e',
      );
    }
  }

  // 비디오 컨트롤러 초기화
  Future<void> _initializeController(XFile videoFile) async {
    try {
      // 기존 컨트롤러 정리
      if (state.controller != null) {
        state.controller!.removeListener(_videoListener);
        await state.controller!.dispose();
      }

      final controller = VideoPlayerController.file(File(videoFile.path));
      await controller.initialize();
      
      // 리스너 추가 (실시간 위치 업데이트용)
      controller.addListener(_videoListener);

      state = state.copyWith(
        videoFile: videoFile,
        controller: controller,
        duration: controller.value.duration,
        position: controller.value.position,
        isPlaying: controller.value.isPlaying,
        isLoading: false,
        showControl: true, // 비디오 로드 후 컨트롤 표시
      );

      // 3초 후 자동으로 컨트롤 숨김
      _startHideControlsTimer();
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '비디오 초기화 실패: $e',
      );
    }
  }

  // 비디오 상태 리스너
  void _videoListener() {
    if (state.controller != null) {
      final controller = state.controller!;
      state = state.copyWith(
        position: controller.value.position,
        isPlaying: controller.value.isPlaying,
        duration: controller.value.duration,
      );
    }
  }

  // 재생/일시정지 토글
  void togglePlayPause() {
    if (state.controller != null) {
      if (state.controller!.value.isPlaying) {
        state.controller!.pause();
      } else {
        state.controller!.play();
      }
      
      // 버튼 누를 때마다 컨트롤 표시하고 3초 후 숨김
      _showControlsTemporarily();
    }
  }

  // 3초 뒤로 이동
  void seekBackward() {
    if (state.controller != null) {
      final newPosition = state.position - const Duration(seconds: 3);
      final targetPosition = newPosition.isNegative 
          ? Duration.zero 
          : newPosition;
      state.controller!.seekTo(targetPosition);
      _showControlsTemporarily();
    }
  }

  // 3초 앞으로 이동
  void seekForward() {
    if (state.controller != null) {
      final newPosition = state.position + const Duration(seconds: 3);
      final targetPosition = newPosition > state.duration 
          ? state.duration 
          : newPosition;
      state.controller!.seekTo(targetPosition);
      _showControlsTemporarily();
    }
  }

  // 슬라이더로 위치 변경
  void seekToPosition(double seconds) {
    if (state.controller != null) {
      final position = Duration(seconds: seconds.toInt());
      state.controller!.seekTo(position);
    }
  }

  // 컨트롤 표시/숨김 토글
  void toggleControls() {
    if (state.showControl) {
      hideControls();
    } else {
      _showControlsTemporarily();
    }
  }

  // 컨트롤 숨김
  void hideControls() {
    _hideControlsTimer?.cancel();
    state = state.copyWith(showControl: false);
  }

  // 컨트롤 표시
  void showControls() {
    state = state.copyWith(showControl: true);
  }

  // 컨트롤을 일시적으로 표시하고 3초 후 자동 숨김
  void _showControlsTemporarily() {
    state = state.copyWith(showControl: true);
    _startHideControlsTimer();
  }

  // 3초 후 컨트롤 숨김 타이머 시작
  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        hideControls();
      }
    });
  }

  // 리소스 정리
  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    if (state.controller != null) {
      state.controller!.removeListener(_videoListener);
      state.controller!.dispose();
    }
    super.dispose();
  }
}