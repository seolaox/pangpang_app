import 'package:flutter/material.dart';

Widget myTextStyle(
  String text,
  double textSize, {
  TextAlign? textAlign,
  FontWeight? fontWeight,
  Color? color,
}) {
  return Text(
    text,
    style: TextStyle(fontSize: textSize, fontWeight: fontWeight, color: color),
    textAlign: textAlign,
  );
}
