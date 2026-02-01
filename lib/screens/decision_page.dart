import 'package:demarcheur_app/apps/demandeurs/main_screens/register_page.dart';
import 'package:demarcheur_app/apps/immo/immo_registration_page.dart';
import 'package:demarcheur_app/auths/donneurs/donnor_register.dart';
import 'package:demarcheur_app/auths/prestataire/prestataire_register.dart';
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
  int? selectedIndex;
  bool _isLoading = false;

  final List<Map<String, dynamic>> options = [
    {
      "title": "Je cherche une opportunité",
      "subtitle":
          "Trouvez un emploi, un logement ou un service adapté à vos besoins.",
      "icon": Icons.search_rounded,
      "role": "SEARCHER",
    },
    {
      "title": "Je suis une entreprise",
      "subtitle":
          "Publiez vos offres d'emploi et trouvez les meilleurs talents.",
      "icon": Icons.business_rounded,
      "role": "GIVER",
    },
    {
      "title": "Agence immobilière",
      "subtitle": "Mettez en avant vos biens immobiliers et terrains.",
      "icon": Icons.apartment_rounded,
      "role": "IMMO",
    },
    {
      "title": "Prestataire de service",
      "subtitle": "Proposez vos services et développez votre clientèle.",
      "icon": Icons.handyman_rounded,
      "role": "SERVICE",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          const Header(auto: true),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Bienvenue !",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color.primary,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Quel est votre objectif principal ?",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ...List.generate(options.length, (index) {
                    final isSelected = selectedIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildOptionCard(index, isSelected),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: const Color(0xFFF8F9FA),
        padding: const EdgeInsets.all(24.0),
        child: Btn(
          texte: "Continuer",
          isLoading: _isLoading,
          color: selectedIndex == null
              ? color.primary.withValues(alpha: 0.3)
              : color.primary,
          function: () => _handleNavigation(),
        ),
      ),
    );
  }

  Widget _buildOptionCard(int index, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.primary.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              //height: 65,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.primary
                    : color.secondary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                options[index]["icon"],
                color: isSelected ? Colors.white : color.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    options[index]["title"],
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    options[index]["subtitle"],
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color.primary, size: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _handleNavigation() async {
    if (selectedIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Veuillez sélectionner une option"),
          backgroundColor: color.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate a small delay for better UX (optional, but good for "feeling" the loading)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final selectedRole = options[selectedIndex!]['role'];
    print("DEBUG: Selected role for registration: $selectedRole");

    final routes = [
      const DonnorRegister(),
      const RegisterPage(),
      const ImmoRegistrationPage(),
      const PrestataireRegister(),
    ];

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => routes[selectedIndex!]),
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  } 
  Future<void> sendMessage(
    
  ) async {
  }
}
