import 'package:demarcheur_app/consts/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroOnboardingPage extends StatefulWidget {
  const IntroOnboardingPage({super.key});

  @override
  State<IntroOnboardingPage> createState() => _IntroOnboardingPageState();
}

class _IntroOnboardingPageState extends State<IntroOnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/demalogo.png",
      "title": "Bienvenue sur Démarcheur",
      "description":
          "La plateforme tout-en-un pour vos besoins professionnels et immobiliers.",
    },
    {
      "image": "assets/job.png",
      "title": "Trouvez les meilleurs talents",
      "description":
          "Recrutez des professionnels qualifiés pour vos projets en toute simplicité.",
    },
    {
      "image": "assets/opportinuity.png",
      "title": "Décrochez le job idéal",
      "description":
          "Mettez en avant vos compétences et trouvez des opportunités qui vous correspondent.",
    },
    {
      "image": "assets/real.png",
      "title": "Gérez vos bien en toute confiance",
      "description":
          "Suivez, organisez et valorisez vos biens au même endroit grâce à des outils clairs et sécurisés.",
    },
  ];
  final colors = ConstColors();
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.primary,
      body: Stack(
        children: [
          // Full Screen PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Background Image
                  if (_onboardingData[index]['image'] == 'assets/demalogo.png')
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            //color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(30),
                          child: Image.asset(
                            _onboardingData[index]['image']!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    )
                  else
                    Image.asset(
                      _onboardingData[index]['image']!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),

                  // 2. Gradient Overlay for readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.8),
                        ],
                        stops: const [0.4, 0.6, 1.0],
                      ),
                    ),
                  ),

                  // 3. Text Content
                  Positioned(
                    bottom: 160, // Space for buttons
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _onboardingData[index]['title']!,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ).animate().fadeIn().slideY(
                          begin: 0.3,
                          end: 0,
                          duration: 800.ms,
                          curve: Curves.easeOutQuad,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _onboardingData[index]['description']!,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.5,
                          ),
                        ).animate().fadeIn().slideY(
                          begin: 0.3,
                          end: 0,
                          delay: 200.ms,
                          duration: 800.ms,
                          curve: Curves.easeOutQuad,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // Bottom Controls (Indicators + Buttons)
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                // Page Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      height: 8,
                      width: _currentPage == index ? 32 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? ConstColors().primary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage < _onboardingData.length - 1)
                      TextButton(
                        onPressed: () {
                          _pageController.animateToPage(
                            _onboardingData.length - 1,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: colors.primary.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        child: Text(
                          "Passer",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 16,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 80),

                    ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _onboardingData.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Navigator.of(context).pushReplacementNamed("/login");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ConstColors().bg,
                        foregroundColor: ConstColors().primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _onboardingData.length - 1
                            ? "Commencer"
                            : "Suivant",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ).animate().scale(
                      duration: 300.ms,
                      curve: Curves.easeOutBack,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
