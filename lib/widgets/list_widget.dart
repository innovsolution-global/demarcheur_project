import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';

class ListWidget extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Function function;

  const ListWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.function,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final color = ConstColors();
    return GestureDetector(
      onTap: () {
        function();
      },
      child: Container(
        width: size.width,
        height: 50,
        decoration: BoxDecoration(
          color: color.bg,
          //border: Border.all(color: color.bgSubmit, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 5),
                Icon(icon, size: 30, color: color.primary),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleWidget(text: title, color: color.primary,),
                    SubTitle(text: subtitle, fontsize: 14),
                  ],
                ),
              ],
            ),
            Icon(Icons.arrow_forward, color: color.primary),
          ],
        ),
      ),
    );
  }
}
