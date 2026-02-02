import 'package:demarcheur_app/consts/color.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class ImmoHeader extends StatelessWidget {
  final bool isLeading;
  final bool auto;
  //final String titlteText;
  const ImmoHeader({super.key, this.isLeading = true, this.auto = false});

  @override
  Widget build(BuildContext context) {
    ConstColors color = ConstColors();
    return SliverAppBar.large(
      iconTheme: IconThemeData(color: color.bg),
      automaticallyImplyLeading: auto,
      actionsIconTheme: IconThemeData(color: color.bg),
      actions: isLeading
          ? []
          : [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.tertiary,
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.person, color: color.primary),
                ),
              ),
              IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
            ],
      leading: auto
          ? IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowTurnBackward),
            )
          : null,
      backgroundColor: Colors.transparent,
      // title: Text(
      //   titlteText,
      //   style: TextStyle(
      //     color: color.bg,
      //     fontSize: 16,
      //     fontWeight: FontWeight.bold,
      //   ),
      // ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: color.primary,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage("assets/backround.png"),
          ),
        ),
      ),
    );
  }
}
