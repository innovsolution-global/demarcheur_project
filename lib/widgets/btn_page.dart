import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';

class BtnPage extends StatelessWidget {
  final String texte;
  final String route;
  const BtnPage({super.key, required this.texte, required this.route});

  @override
  Widget build(BuildContext context) {
    ConstColors color = ConstColors();
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, route);
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide.none,
          backgroundColor: color.primary,
        ),
        child: TitleWidget(text: texte, color: color.bg, fontSize: 20),
      ),
    );
  }
}
