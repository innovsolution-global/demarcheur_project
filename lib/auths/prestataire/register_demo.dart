import 'package:flutter/material.dart';
import 'prestataire_register_page_redesigned.dart';

class RegisterDemoPage extends StatelessWidget {
  const RegisterDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Registration Demo'),
        backgroundColor: const Color(0xFF0C315A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0C315A), Color(0xFF2E6091)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.app_registration,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Registration Page Redesign',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Experience the new step-by-step registration process',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Features Section
            const Text(
              'Key Features:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3641),
              ),
            ),
            const SizedBox(height: 16),

            // Feature Cards
            const FeatureCard(
              icon: Icons.timeline,
              title: 'Step-by-Step Process',
              description:
                  'Guided registration with 4 clear steps and progress indicator',
              color: Color(0xFF4CAF50),
            ),

            const FeatureCard(
              icon: Icons.animation,
              title: 'Smooth Animations',
              description:
                  'Elegant transitions between steps with scale and fade effects',
              color: Color(0xFF2196F3),
            ),

            const FeatureCard(
              icon: Icons.verified_user,
              title: 'Form Validation',
              description: 'Real-time validation with helpful error messages',
              color: Color(0xFFFF9800),
            ),

            const FeatureCard(
              icon: Icons.photo_camera,
              title: 'Enhanced Image Picker',
              description:
                  'Professional image selection with camera and gallery options',
              color: Color(0xFF9C27B0),
            ),

            const FeatureCard(
              icon: Icons.design_services,
              title: 'Modern UI Design',
              description:
                  'Clean cards, gradients, and floating elements for premium feel',
              color: Color(0xFFE91E63),
            ),

            const FeatureCard(
              icon: Icons.touch_app,
              title: 'Interactive Feedback',
              description:
                  'Haptic feedback, animated buttons, and visual confirmations',
              color: Color(0xFF795548),
            ),

            const SizedBox(height: 30),

            // Comparison Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Improvements Over Original:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3641),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const ComparisonItem(
                    before: 'Single long form',
                    after: '4-step guided process',
                    icon: Icons.timeline,
                  ),

                  const ComparisonItem(
                    before: 'Basic image picker dialog',
                    after: 'Modern bottom sheet with preview',
                    icon: Icons.photo_library,
                  ),

                  const ComparisonItem(
                    before: 'Minimal form validation',
                    after: 'Comprehensive validation with feedback',
                    icon: Icons.check_circle,
                  ),

                  const ComparisonItem(
                    before: 'Static UI elements',
                    after: 'Animated transitions and interactions',
                    icon: Icons.animation,
                  ),

                  const ComparisonItem(
                    before: 'Fixed 5-second loading',
                    after: 'Smart loading states and progress',
                    icon: Icons.speed,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // CTA Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const PrestataireRegisterPageRedesigned(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOutCubic;

                            var tween = Tween(
                              begin: begin,
                              end: end,
                            ).chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                      transitionDuration: const Duration(milliseconds: 800),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C315A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.rocket_launch, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Try New Registration Process',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3641),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ComparisonItem extends StatelessWidget {
  final String before;
  final String after;
  final IconData icon;

  const ComparisonItem({
    super.key,
    required this.before,
    required this.after,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF4CAF50), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.close, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        before,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.check, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        after,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E3641),
                        ),
                      ),
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
