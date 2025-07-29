import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ImageSlider extends StatefulWidget {
  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final List<String> imgList = [
    'https://img.freepik.com/premium-photo/adorable-white-pomeranian-puppy-spitz_463999-7.jpg?semt=ais_hybrid&w=740',
    'https://health.chosun.com/site/data/img_dir/2025/04/08/2025040803041_0.jpg',
    'https://m.segye.com/content/image/2022/05/23/20220523519355.jpg',
    'https://images.mypetlife.co.kr/content/uploads/2022/12/16162807/IMG_1666-edited-scaled.jpg',
    'https://image.dongascience.com/Photo/2020/03/5bddba7b6574b95d37b6079c199d7101.jpg',
  ];

  int _currentIndex = 0;
  bool _showIndicator = false;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _showIndicatorTemporarily() {
    setState(() {
      _showIndicator = true;
    });
    
    // 기존 타이머가 있다면 취소
    _hideTimer?.cancel();
    
    // 5초 후에 인디케이터 숨기기
    _hideTimer = Timer(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showIndicator = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          CarouselSlider.builder(
            itemCount: imgList.length,
            itemBuilder:
                (BuildContext context, int itemIndex, int pageViewIndex) => Container(
                  child: Image.network(
                    imgList[itemIndex],
                    fit: BoxFit.cover,
                    cacheHeight: 250,
                    cacheWidth: 300,
                  ),
                ),
            options: CarouselOptions(
              height: 250.0, // 슬라이더의 높이를 지정
              aspectRatio: 16 / 9, // 슬라이더의 종횡비를 지정
              initialPage: 0, // 처음에 표시될 슬라이드의 인덱스
              reverse: false, // 슬라이드 넘기는 방향 반전
              enlargeCenterPage: true, // 중앙 페이지를 크게 표시
              enlargeStrategy: CenterPageEnlargeStrategy.zoom,
              onPageChanged: (index, reason) {
                // 페이지가 변경될 때 실행할 함수
                setState(() {
                  _currentIndex = index;
                  _showIndicatorTemporarily();
                });
              },
              scrollDirection: Axis.horizontal, // 스크롤 방향을 가로로 설정
            ),
          ),
          
          // 오른쪽 상단에 현재 페이지 인디케이터 (조건부 표시)
          if (_showIndicator)
            Positioned(
              top: 10,
              right: 10,
              child: AnimatedOpacity(
                opacity: _showIndicator ? 1.0 : 0.0,
                duration: Duration(milliseconds: 300),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6), // 반투명 검은 배경
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${imgList.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
  }
}
