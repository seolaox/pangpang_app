import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/presentation/provider/record_provider.dart';
import 'package:video_player/video_player.dart';

class RecordView extends ConsumerWidget {
  const RecordView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoState = ref.watch(videoProvider);
    final videoNotifier = ref.read(videoProvider.notifier);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                videoNotifier.selectVideo();
              },
              child: Text('비디오 선택'),
            ),
            
            const SizedBox(height: 20),
            
            // // 에러 메시지
            // if (videoState.errorMessage != null)
            //   Container(
            //     padding: const EdgeInsets.all(16),
            //     margin: const EdgeInsets.symmetric(horizontal: 16),
            //     decoration: BoxDecoration(
            //       color: Colors.red.shade100,
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     child: Text(
            //       videoState.errorMessage!,
            //       style: const TextStyle(color: Colors.red),
            //     ),
            //   ),
            
            // const SizedBox(height: 20),
            
            // 비디오 플레이어
            if (videoState.controller != null && 
                videoState.controller!.value.isInitialized)
              Container(
                margin: const EdgeInsets.all(16),
                height: 300,
                child: AspectRatio(
                  aspectRatio: videoState.controller!.value.aspectRatio,
                  child: GestureDetector(
                    onTap: () {
                      videoNotifier.toggleControls();
                    },
                    child: Stack(
                      children: [
                        VideoPlayer(videoState.controller!),
                        
                        // 컨트롤 버튼들
                        Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // 3초 뒤로
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: IconButton(
                                  onPressed: () => videoNotifier.seekBackward(),
                                  icon: const Icon(
                                    Icons.rotate_left,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                              
                              // 재생/일시정지
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: IconButton(
                                  onPressed: () => videoNotifier.togglePlayPause(),
                                  icon: Icon(
                                    videoState.isPlaying 
                                        ? Icons.pause 
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                              ),
                              
                              // 3초 앞으로
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: IconButton(
                                  onPressed: () => videoNotifier.seekForward(),
                                  icon: const Icon(
                                    Icons.rotate_right,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // 진행바와 시간 표시
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 슬라이더
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: Colors.red,
                                    inactiveTrackColor: Colors.white30,
                                    thumbColor: Colors.red,
                                    overlayColor: Colors.red.withOpacity(0.2),
                                    trackHeight: 3,
                                  ),
                                  child: Slider(
                                    value: videoState.position.inSeconds.toDouble(),
                                    max: videoState.duration.inSeconds.toDouble(),
                                    onChanged: (double value) {
                                      videoNotifier.seekToPosition(value);
                                    },
                                  ),
                                ),
                                
                                // 시간 표시
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(videoState.position),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(videoState.duration),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              const Text(
                '비디오를 선택해주세요',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  // Duration을 mm:ss 형태로 포맷
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}