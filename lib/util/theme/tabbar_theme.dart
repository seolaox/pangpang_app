import 'package:flutter/material.dart';

class AppTabBarTheme {
  // 탭바 아이콘 크기
  static double get iconSize => 20;

  // 탭바 텍스트 스타일
  static TextStyle get labelStyle => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );

  // 탭바 높이
  static double get height => 80;

  // 탭바 상단 보더
  static BoxDecoration get decoration => BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 1.0,
          ),
        ),
      );

  // 탭바 색상
  static Color get selectedColor => Colors.blue;
  static Color get unselectedColor => Colors.grey;

  // 탭바 인디케이터
  static double get indicatorWeight => 2.0;
} 