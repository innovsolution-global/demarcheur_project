import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';

class ListitleWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Function ontap;
  final IconData leading;
  const ListitleWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.ontap,
    required this.leading,
  });

  @override
  Widget build(BuildContext context) {
    ConstColors colors = ConstColors();
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 70,
      decoration: BoxDecoration(
        color: colors.bgSubmit,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: ListTile(
          horizontalTitleGap: 8,
          title: TitleWidget(text: title),
          subtitle: SubTitle(text: subtitle),
          leading: Icon(leading, color: colors.primary),
          trailing: Icon(Icons.arrow_forward_ios, color: colors.secondary),
          onTap: () {
            ontap();
          },
        ),
      ),
    );
  }
}
