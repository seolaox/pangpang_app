import 'package:flutter/material.dart';

Widget imageToIcon(
  BuildContext context,
  String imagePath,
  double size,
  Color color,
) {
  return Image.asset(
    imagePath,
    width: size,
    height: size,
    fit: BoxFit.cover,
    color: color,
  );
}
