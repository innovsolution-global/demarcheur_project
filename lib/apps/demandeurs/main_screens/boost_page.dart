import 'package:demarcheur_app/consts/color.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class BoostPage extends StatelessWidget {
  const BoostPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ConstColors colors = ConstColors();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Booster l'annonce",
          style: TextStyle(
            color: colors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(colors),
            const SizedBox(height: 32),
            _buildPlanCard(
              colors: colors,
              title: "Standard",
              price: "50,000 GNF",
              duration: "3 jours",
              features: [
                "Visibilité accrue",
                "Badge 'Sponsorisé'",
                "Support standard",
              ],
              isPopular: false,
            ),
            const SizedBox(height: 20),
            _buildPlanCard(
              colors: colors,
              title: "Premium",
              price: "100,000 GNF",
              duration: "7 jours",
              features: [
                "Top des résultats",
                "Badge 'Premium'",
                "Support prioritaire",
                "Statistiques détaillées",
              ],
              isPopular: true,
            ),
            const SizedBox(height: 20),
            _buildPlanCard(
              colors: colors,
              title: "Business",
              price: "250,000 GNF",
              duration: "30 jours",
              features: [
                "Visibilité maximale",
                "Badge 'Business'",
                "Support dédié 24/7",
                "Statistiques avancées",
                "Emailing ciblé",
              ],
              isPopular: false,
            ),
            const SizedBox(height: 32),
            Text(
              "Besoin d'une offre personnalisée ?",
              style: TextStyle(
                color: colors.secondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "Contactez-nous",
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ConstColors colors) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedRocket,
            color: colors.primary,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Accélérez vos recrutements",
          style: TextStyle(
            color: colors.primary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Choisissez le plan qui correspond à vos besoins et touchez plus de candidats qualifiés.",
            style: TextStyle(
              color: colors.secondary,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required ConstColors colors,
    required String title,
    required String price,
    required String duration,
    required List<String> features,
    required bool isPopular,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: isPopular
                ? Border.all(color: colors.primary, width: 2)
                : Border.all(color: Colors.transparent),
            boxShadow: [
              BoxShadow(
                color: isPopular
                    ? colors.primary.withOpacity(0.15)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (isPopular)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Populaire",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      "/ $duration",
                      style: TextStyle(
                        color: colors.secondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ...features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: colors.accepted,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        feature,
                        style: TextStyle(
                          color: colors.secondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPopular ? colors.primary : colors.bg,
                    foregroundColor: isPopular ? Colors.white : colors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: isPopular
                        ? BorderSide.none
                        : BorderSide(color: colors.primary),
                  ),
                  child: const Text(
                    "Choisir ce plan",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isPopular)
          Positioned(
            top: -12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.black,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "Recommandé",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
