import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/user_model.dart';
import 'package:demarcheur_app/widgets/btn.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class ApplicantDetail extends StatefulWidget {
  final UserModel details;
  const ApplicantDetail({super.key, required this.details});

  @override
  State<ApplicantDetail> createState() => _ApplicantDetailState();
}

class _ApplicantDetailState extends State<ApplicantDetail> {
  ConstColors color = ConstColors();
  @override
  Widget build(BuildContext context) {
    final user = widget.details;

    return Scaffold(
      backgroundColor: color.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowTurnBackward,
                color: color.bg,
              ),
            ),
            iconTheme: IconThemeData(color: color.bg),
            actionsIconTheme: IconThemeData(color: color.bg),
            backgroundColor: Colors.transparent,

            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: color.primary,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    "https://www.shutterstock.com/image-photo/job-search-human-resources-recruitment-260nw-1292578582.jpg",
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleWidget(
                    text: user.gender == "Masculin"
                        ? "Les details du dossier de Mr ${user.name}"
                        : "Les details du dossier de Mme ${user.name}",
                    fontSize: 18,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: Column(children: [])),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Btn(
                texte: "Retour",
                function: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
