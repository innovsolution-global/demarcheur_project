// import 'package:demarcheur_app/apps/demandeurs/main_screens/register_page.dart';
// import 'package:demarcheur_app/apps/donneurs/main_screens/dashboard_page.dart';
// import 'package:demarcheur_app/consts/color.dart';
// import 'package:demarcheur_app/models/services/service_model.dart';
// import 'package:demarcheur_app/providers/domain_pref_provider.dart';
// import 'package:demarcheur_app/services/auth_provider.dart';
// import 'package:demarcheur_app/widgets/header_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:provider/provider.dart';

// class DomainPrefPage extends StatefulWidget {
//   const DomainPrefPage({super.key});

//   @override
//   State<DomainPrefPage> createState() => _DomainPrefPageState();
// }

// class _DomainPrefPageState extends State<DomainPrefPage> {
//   final ConstColors colors = ConstColors();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<DomainPrefProvider>().initialize();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<DomainPrefProvider>(
//       builder: (context, provider, child) {
//         if (provider.isInitialLoading) {
//           return Scaffold(
//             backgroundColor: const Color(0xFFF5F7FA),
//             body: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SpinKitPulse(color: colors.primary, size: 60.0),
//                   const SizedBox(height: 16),
//                   Text(
//                     "Chargement des domaines...",
//                     style: TextStyle(
//                       color: colors.secondary,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         return Scaffold(
//           backgroundColor: const Color(0xFFF5F7FA),
//           body: Stack(
//             children: [
//               CustomScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 slivers: [
//                   Header(auto: true),
//                   SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(height: 8),
//                           Text(
//                             "Quel poste vous intéresse ?",
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: colors.secondary,
//                               height: 1.2,
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           Text(
//                             "Sélectionnez un ou plusieurs domaines pour personnaliser votre expérience.",
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: colors.secondary.withOpacity(0.7),
//                               height: 1.5,
//                             ),
//                           ),
//                           const SizedBox(height: 32),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SliverPadding(
//                     padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
//                     sliver: SliverList(
//                       delegate: SliverChildBuilderDelegate((context, index) {
//                         final category = provider.categories[index];
//                         return _buildCategorySection(
//                           categoryName: category['name'] as String,
//                           domains: category['domains'] as List<DomainModel>,
//                           provider: provider,
//                         );
//                       }, childCount: provider.categories.length),
//                     ),
//                   ),
//                 ],
//               ),
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: _buildBottomBar(provider),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildCategorySection({
//     required String categoryName,
//     required List<DomainModel> domains,
//     required DomainPrefProvider provider,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(bottom: 12, left: 4),
//           child: Row(
//             children: [
//               Container(
//                 width: 4,
//                 height: 24,
//                 decoration: BoxDecoration(
//                   color: colors.primary,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 categoryName,
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: colors.secondary,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Wrap(
//           spacing: 12,
//           runSpacing: 12,
//           children: domains.map((domain) {
//             return _buildDomainChip(
//               domain: domain,
//               isSelected: provider.isSelected(domain.id),
//               onTap: () => provider.toggleDomain(domain.id),
//             );
//           }).toList(),
//         ),
//         const SizedBox(height: 32),
//       ],
//     );
//   }

//   Widget _buildDomainChip({
//     required DomainModel domain,
//     required bool isSelected,
//     required VoidCallback onTap,
//   }) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       curve: Curves.easeInOut,
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(30),
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             decoration: BoxDecoration(
//               color: isSelected ? colors.primary : Colors.white,
//               borderRadius: BorderRadius.circular(30),
//               border: Border.all(
//                 color: isSelected ? colors.primary : Colors.grey.shade300,
//                 width: 1.5,
//               ),
//               boxShadow: isSelected
//                   ? [
//                       BoxShadow(
//                         color: colors.primary.withOpacity(0.3),
//                         blurRadius: 8,
//                         offset: const Offset(0, 4),
//                       ),
//                     ]
//                   : [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.02),
//                         blurRadius: 4,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 if (isSelected) ...[
//                   Icon(
//                     Icons.check_circle_rounded,
//                     color: Colors.white,
//                     size: 18,
//                   ),
//                   const SizedBox(width: 8),
//                 ],
//                 Text(
//                   domain.name,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: isSelected ? Colors.white : colors.secondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomBar(DomainPrefProvider provider) {
//     final hasSelection = provider.hasSelection;

//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 20,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             if (hasSelection)
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//                 decoration: BoxDecoration(
//                   color: colors.tertiary,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   "${provider.selectedDomains.length} sélectionné(s)",
//                   style: TextStyle(
//                     color: colors.primary,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             if (hasSelection) const SizedBox(width: 16),
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: hasSelection
//                     ? () {
//                         _isLoading ? null : _submit();
//                       }
//                     : null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: colors.primary,
//                   disabledBackgroundColor: Colors.grey.shade300,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   elevation: hasSelection ? 4 : 0,
//                   shadowColor: colors.primary.withOpacity(0.4),
//                 ),
//                 child: _isLoading
//                     ? Center(
//                         child: SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(color: colors.bg),
//                         ),
//                       )
//                     : Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             "Continuer",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: hasSelection
//                                   ? Colors.white
//                                   : Colors.grey.shade500,
//                             ),
//                           ),
//                           if (hasSelection) ...[
//                             const SizedBox(width: 8),
//                             const Icon(
//                               Icons.arrow_forward_rounded,
//                               color: Colors.white,
//                               size: 20,
//                             ),
//                           ],
//                         ],
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   bool _isLoading = false;
//   void _submit() async {
//     final provider = context.watch<DomainPrefProvider>();
//     final selectedNames = provider.getSelectedDomainNames();
//     final authProvider = context.read<AuthProvider>();

//     // Show loading indicator or disable button could be good here

//     for (final name in selectedNames) {
//       final service = ServiceModel(service_name: name);
//       await authProvider.services(service);
//     }

//     if (context.mounted) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
// }
