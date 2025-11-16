import 'package:demarcheur_app/apps/demandeurs/main_screens/register_page.dart';
import 'package:demarcheur_app/apps/immo/immo_registration_page.dart';
import 'package:demarcheur_app/auths/donneurs/donnor_register.dart';
import 'package:demarcheur_app/auths/prestataire/prestataire_register_page.dart';
import 'package:demarcheur_app/auths/prestataire/prestataire_register_page_redesigned.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/widgets/btn.dart';
import 'package:demarcheur_app/widgets/header_page.dart';
import 'package:flutter/material.dart';

class DecisionPage extends StatefulWidget {
  const DecisionPage({super.key});

  @override
  State<DecisionPage> createState() => _DecisionPageState();
}

class _DecisionPageState extends State<DecisionPage> {
  final ConstColors color = ConstColors();

  // on garde la valeur sélectionnée ici
  int? selectedIndex;

  final List<Map<String, String>> options = [
    {
      "title": "Je cherche une opportunité",
      "subtitle": "Vous pourrez chercher un emploi, une maison ou un service",
    },
    {
      "title": "Je suis une entreprise",
      "subtitle": "Vous pourrez publier des offres d'emploi",
    },
    {
      "title": "Je suis une agence immobilieres",
      "subtitle":
          "Vous pourrez publier des offres de logements, ou de terrains",
    },
    {
      "title": "Je suis un prestataire de service",
      "subtitle": "Vous pourrez publier des offres de service",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color.bg,
      body: CustomScrollView(
        slivers: [
          Header(auto: true),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Que souhaitez-vous faire principalement sur cette application ?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: color.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Génération dynamique des options
                  ...List.generate(options.length, (index) {
                    return RadioListTile<int>(
                      activeColor: color.primary,
                      groupValue: selectedIndex,
                      value: index,
                      onChanged: (value) {
                        setState(() => selectedIndex = value);
                      },
                      title: Text(
                        options[index]["title"]!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: color.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        options[index]["subtitle"]!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: color.secondary, fontSize: 14),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Btn(
                texte: "Suivant",
                function: () {
                  if (selectedIndex == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Veuillez sélectionner une option",
                          style: TextStyle(color: color.bg),
                        ),
                        backgroundColor: color.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    return;
                  }

                  if (selectedIndex == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DonnorRegister(),
                      ),
                    );
                  } else if (selectedIndex == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  } else if (selectedIndex == 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ImmoRegistrationPage(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const PrestataireRegisterPageRedesigned(),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
