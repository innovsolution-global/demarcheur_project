import 'package:demarcheur_app/consts/color.dart';
import 'package:flutter/material.dart';

class SubTitle extends StatelessWidget {
  final String text;
  final FontWeight? fontWeight;
  final double? fontsize;
  final Color? color;
  const SubTitle({
    super.key,
    required this.text,
    this.fontWeight,
    this.fontsize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    ConstColors colors = ConstColors();
    return Text(
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      text,
      style: TextStyle(
        fontSize: fontsize,
        fontWeight: fontWeight,
        color: color ?? colors.primary,
      ),
    );
  }
}
