import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';

class Btn extends StatelessWidget {
  final String texte;
  final double? size;
  final Function function;
  final Color? color;
  final bool isLoading;

  const Btn({
    super.key,
    required this.texte,
    required this.function,
    this.color,
    this.size,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    ConstColors colors = ConstColors();
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
        onPressed: isLoading
            ? null
            : () {
                function();
              },
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide.none,
          backgroundColor: color ?? colors.primary,
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: colors.bg,
                  strokeWidth: 2.5,
                ),
              )
            : TitleWidget(text: texte, color: colors.bg, fontSize: size ?? 20),
      ),
    );
  }
}
