import 'package:demarcheur_app/consts/color.dart';
import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
  const TitleWidget({
    super.key,
    required this.text,
    this.fontSize = 18,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    ConstColors colors = ConstColors();
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color ?? colors.primary,
      ),
    );
  }
}
