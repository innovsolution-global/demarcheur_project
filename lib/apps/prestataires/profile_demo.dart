// import 'package:flutter/material.dart';
// import 'presta_profile_page_redesigned.dart';

// class ProfileDemoPage extends StatelessWidget {
//   const ProfileDemoPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile Demo'),
//         backgroundColor: const Color(0xFF0C315A),
//         foregroundColor: Colors.white,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Profile Page Redesign Demo',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Features of the new design:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 16),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   FeatureItem(
//                     icon: Icons.animation,
//                     title: 'Smooth Animations',
//                     description:
//                         'Page transitions with fade, slide, and scale effects',
//                   ),
//                   FeatureItem(
//                     icon: Icons.palette,
//                     title: 'Modern UI Design',
//                     description:
//                         'Clean cards, gradients, and floating elements',
//                   ),
//                   FeatureItem(
//                     icon: Icons.touch_app,
//                     title: 'Interactive Elements',
//                     description: 'Pulse animations and haptic feedback',
//                   ),
//                   FeatureItem(
//                     icon: Icons.grid_view,
//                     title: 'Better Layout',
//                     description: 'Grid stats, horizontal scrolling portfolios',
//                   ),
//                   FeatureItem(
//                     icon: Icons.star,
//                     title: 'Achievements Section',
//                     description: 'Visual rewards and certifications display',
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   PageRouteBuilder(
//                     pageBuilder: (context, animation, secondaryAnimation) =>
//                         const PrestaProfilePageRedesigned(),
//                     transitionsBuilder:
//                         (context, animation, secondaryAnimation, child) {
//                           const begin = Offset(1.0, 0.0);
//                           const end = Offset.zero;
//                           const curve = Curves.easeInOutCubic;

//                           var tween = Tween(
//                             begin: begin,
//                             end: end,
//                           ).chain(CurveTween(curve: curve));

//                           return SlideTransition(
//                             position: animation.drive(tween),
//                             child: child,
//                           );
//                         },
//                     transitionDuration: const Duration(milliseconds: 600),
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF0C315A),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 32,
//                   vertical: 16,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 elevation: 8,
//               ),
//               child: const Text(
//                 'View Redesigned Profile',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class FeatureItem extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String description;

//   const FeatureItem({
//     super.key,
//     required this.icon,
//     required this.title,
//     required this.description,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: const Color(0xFF0C315A).withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: const Color(0xFF0C315A), size: 20),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   description,
//                   style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
