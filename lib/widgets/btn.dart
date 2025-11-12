import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';

class Btn extends StatelessWidget {
  final String texte;
  final double? size;
  final Function function;
  const Btn({
    super.key,
    required this.texte,
    required this.function,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    ConstColors color = ConstColors();
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () {
          function();
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide.none,
          backgroundColor: color.primary,
        ),
        child: TitleWidget(text: texte, color: color.bg, fontSize: size ?? 20),
      ),
    );
  }
}
