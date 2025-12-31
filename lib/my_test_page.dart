// import 'package:demarcheur_app/apps/donneurs/inner_screens/jobs/job_detail.dart';
// import 'package:demarcheur_app/consts/color.dart';
// import 'package:demarcheur_app/providers/dem_job_provider.dart';
// import 'package:demarcheur_app/providers/search_provider.dart';
// import 'package:demarcheur_app/widgets/sub_title.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:hugeicons/hugeicons.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
//   final TextEditingController _searchController = TextEditingController();
//   bool _showClear = false;
//   ConstColors color = ConstColors();
//   int currentIndex = 0;
//   // Animation controllers
//   late AnimationController _animationController;
//   late AnimationController _filterController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();

//     // Load data and start animations
//     Future.microtask(() {
//       final searchProvider = context.read<SearchProvider>();
//       searchProvider.loadJobs().then((_) {
//         searchProvider.setJobs(searchProvider.filteredJobs);
//         _animationController.forward();
//       });
//     });

//     _searchController.addListener(() {
//       setState(() {
//         _showClear = _searchController.text.isNotEmpty;
//       });
//     });
//   }

//   late Animation<Offset> _searchSlide;
// late Animation<Offset> _categorySlide;
// late Animation<Offset> _contentSlide;

// void _initializeAnimations() {
//   _animationController = AnimationController(
//     duration: const Duration(milliseconds: 1200),
//     vsync: this,
//   );

//   _searchSlide = Tween(begin: Offset(0, .3), end: Offset.zero).animate(
//     CurvedAnimation(
//       parent: _animationController,
//       curve: Interval(0.0, 0.4, curve: Curves.easeOut),
//     ),
//   );

//   _categorySlide = Tween(begin: Offset(0, .3), end: Offset.zero).animate(
//     CurvedAnimation(
//       parent: _animationController,
//       curve: Interval(0.3, 0.7, curve: Curves.easeOut),
//     ),
//   );

//   _contentSlide = Tween(begin: Offset(0, .3), end: Offset.zero).animate(
//     CurvedAnimation(
//       parent: _animationController,
//       curve: Interval(0.6, 1.0, curve: Curves.easeOut),
//     ),
//   );
// }


//   @override
//   void dispose() {
    
//     _animationController.dispose();
//     _filterController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   Widget _buildModernContentBox() {
//     final provider = context.watch<SearchProvider>();
//     final categories = provider.categories;
//     final houses = provider.filteredJobs;

//     if (houses.isEmpty) {
//       return _buildEmptyState('Aucune offre disponible pour le moment.');
//     }

//     final selectedCategory = currentIndex == 0
//         ? null
//         : categories[currentIndex];
//     final filteredHouses = selectedCategory == null
//         ? houses
//         : houses
//               .where(
//                 (h) =>
//                     h.category.toLowerCase() == selectedCategory.toLowerCase(),
//               )
//               .toList();

//     if (filteredHouses.isEmpty) {
//       return _buildEmptyState('Aucune offre trouvée dans cette catégorie.');
//     }

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         children: List.generate(
//           filteredHouses.length,
//           (index) => Padding(
//             padding: const EdgeInsets.only(bottom: 16),
//             child: _buildModernJobCard(filteredHouses[index]),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState(String message) {
//     return SizedBox(
//       height: 300,
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.home_outlined, size: 80, color: Colors.grey.shade400),
//             const SizedBox(height: 16),
//             Text(
//               message,
//               style: TextStyle(
//                 color: color.secondary,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget _buldJobCard(JobModel house) {
//   //   return GestureDetector(
//   //     onTap: () {
//   //       Navigator.push(
//   //         context,
//   //         MaterialPageRoute(
//   //           builder: (_) => JobDetail(
//   //             job: house,
//   //           ),
//   //         ),
//   //       );
//   //     },
//   //     child: Container(
//   //       decoration: BoxDecoration(
//   //         color: Colors.white,
//   //         borderRadius: BorderRadius.circular(20),
//   //         boxShadow: [
//   //           BoxShadow(
//   //             color: Colors.black.withOpacity(0.08),
//   //             blurRadius: 8,
//   //             offset: const Offset(0, 8),
//   //           ),
//   //         ],
//   //       ),
//   //       child: Column(
//   //         crossAxisAlignment: CrossAxisAlignment.start,
//   //         children: [
//   //           // image section
//   //           Stack(
//   //             children: [
//   //               ClipRRect(
//   //                 borderRadius: const BorderRadius.only(
//   //                   topLeft: Radius.circular(20),
//   //                   topRight: Radius.circular(20),
//   //                 ),
//   //                 child: Image.network(
//   //                   house.imageUrl,
//   //                   height: 220,
//   //                   width: double.infinity,
//   //                   fit: BoxFit.cover,
//   //                   errorBuilder: (context, error, stackTrace) => Container(
//   //                     height: 200,
//   //                     width: double.infinity,
//   //                     color: Colors.grey[200],
//   //                     child: Icon(
//   //                       Icons.home,
//   //                       size: 50,
//   //                       color: Colors.grey[400],
//   //                     ),
//   //                   ),
//   //                 ),
//   //               ),
//   //               Positioned(
//   //                 top: 16,
//   //                 left: 16,
//   //                 child: Container(
//   //                   padding: const EdgeInsets.symmetric(
//   //                     horizontal: 12,
//   //                     vertical: 6,
//   //                   ),
//   //                   decoration: BoxDecoration(
//   //                     color: house.status == "Disponible"
//   //                         ? color.accepted
//   //                         : color.error,
//   //                     borderRadius: BorderRadius.circular(20),
//   //                   ),
//   //                   child: Text(
//   //                     house.status,
//   //                     style: const TextStyle(
//   //                       color: Colors.white,
//   //                       fontSize: 12,
//   //                       fontWeight: FontWeight.w600,
//   //                     ),
//   //                   ),
//   //                 ),
//   //               ),
//   //             ],
//   //           ),
//   //           Padding(
//   //             padding: const EdgeInsets.all(20),
//   //             child: Column(
//   //               crossAxisAlignment: CrossAxisAlignment.start,
//   //               children: [
//   //                 Text(
//   //                   house.companyName,
//   //                   style: TextStyle(
//   //                     color: color.primary,
//   //                     fontWeight: FontWeight.bold,
//   //                     fontSize: 16,
//   //                   ),
//   //                 ),
//   //                 const SizedBox(height: 6),
//   //                 Row(
//   //                   children: [
//   //                     HugeIcon(
//   //                       icon: HugeIcons.strokeRoundedLocation01,
//   //                       size: 16,
//   //                       color: color.primary,
//   //                     ),
//   //                     const SizedBox(width: 6),
//   //                     Expanded(
//   //                       child: Text(
//   //                         house.location,
//   //                         style: TextStyle(
//   //                           color: color.secondary,
//   //                           fontSize: 14,
//   //                         ),
//   //                       ),
//   //                     ),
//   //                   ],
//   //                 ),
//   //                 const SizedBox(height: 8),
//   //                 Row(
//   //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                   children: [
//   //                     Text(
//   //                       'Prix du loyer',
//   //                       style: TextStyle(
//   //                         color: color.secondary,
//   //                         fontWeight: FontWeight.w500,
//   //                       ),
//   //                     ),
//   //                     Text(
//   //                       "${NumberFormat().format(house.salary)} GNF/mois",
//   //                       style: TextStyle(
//   //                         color: color.primary,
//   //                         fontWeight: FontWeight.bold,
//   //                         fontSize: 16,
//   //                       ),
//   //                     ),
//   //                   ],
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     final search = Provider.of<SearchProvider>(context);

//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF8FAFC),
//         body: search.isLoading
//             ? _buildLoadingState()
//             : CustomScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 slivers: [
//                   _buildModernAppBar(),
//                   SliverToBoxAdapter(
//                     child: AnimatedBuilder(
//                       animation: _animationController,
//                       builder: (context, child) {
//                         return FadeTransition(
//                           opacity: _fadeAnimation,
//                           child: SlideTransition(
//                             position: _slideAnimation,
//                             child: _buildSearchSection(search),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   SliverToBoxAdapter(
//                     child: AnimatedBuilder(
//                       animation: _animationController,
//                       builder: (context, _) {
//                         return FadeTransition(
//                           opacity: _fadeAnimation,
//                           child: SlideTransition(
//                             position: _slideAnimation,
//                             child: _buildHeaderSection(search.categories),
//                           ),
//                         );
//                       },
//                     ),
//                   ),

//                   SliverToBoxAdapter(
//                     child: AnimatedBuilder(
//                       animation: _animationController,
//                       builder: (context, _) {
//                         return FadeTransition(
//                           opacity: _fadeAnimation,
//                           child: SlideTransition(
//                             position: _slideAnimation,
//                             child: _buildModernContentBox(), // ✅ fixed
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }

//   Widget _buildHeaderSection(List<String> categories) {
//     final search = Provider.of<SearchProvider>(context);
//     return Padding(
//       padding: const EdgeInsets.all(10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Catégories',
//             style: TextStyle(
//               color: color.primary,
//               fontSize: 24,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             height: 50,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: categories.length,
//               itemBuilder: (context, index) => Padding(
//                 padding: EdgeInsets.only(
//                   right: index == categories.length - 1 ? 0 : 12,
//                 ),
//                 child: _buildModernCategoryButton(categories[index], index),
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Recommandé pour vous',
//                 style: TextStyle(
//                   color: color.primary,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               TextButton.icon(
//                 style: TextButton.styleFrom(
//                   backgroundColor: color.primary.withOpacity(0.1),
//                   foregroundColor: color.primary,
//                 ),
//                 onPressed: () => search.toggleView(),

//                 icon: Icon(Icons.arrow_forward_rounded, color: color.primary),
//                 label: Text(
//                   search.viewAll ? "Voir moins" : "Tout voir",
//                   style: TextStyle(color: color.primary),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildModernCategoryButton(String title, int index) {
//     final bool isSelected = currentIndex == index;
//     return GestureDetector(
//       onTap: () => setState(() => currentIndex = index),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//         decoration: BoxDecoration(
//           color: isSelected ? color.primary : Colors.white,
//           borderRadius: BorderRadius.circular(25),
//           border: Border.all(
//             color: isSelected ? color.primary : Colors.grey.shade300,
//             width: isSelected ? 2 : 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: (isSelected ? color.primary : Colors.black).withOpacity(
//                 isSelected ? 0.3 : 0.05,
//               ),
//               blurRadius: isSelected ? 12 : 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Text(
//           title,
//           style: TextStyle(
//             color: isSelected ? Colors.white : color.primary,
//             fontWeight: FontWeight.w600,
//             fontSize: 14,
//           ),
//         ),
//       ),
//     );
//   }

//   // --- ✅ FIXED CONTENT (non-sliver) -------------------
//   Widget _buildLoadingState() {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SpinKitPulse(color: color.primary, size: 60.0),
//             const SizedBox(height: 16),
//             Text(
//               'Recherche des offres...',
//               style: TextStyle(
//                 color: color.secondary,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildModernAppBar() {
//     return SliverAppBar(
//       expandedHeight: 200,
//       automaticallyImplyLeading: false,
//       floating: false,
//       pinned: true,
//       actions: [
//         IconButton(
//           onPressed: () {
//             // Action for notifications
//           },
//           icon: HugeIcon(
//             icon: HugeIcons.strokeRoundedNotification01,
//             color: Colors.white,
//           ),
//         ),
//         IconButton(
//           onPressed: () {
//             // Action for notifications
//           },
//           icon: HugeIcon(
//             icon: HugeIcons.strokeRoundedMoreVertical,
//             size: 30,
//             color: Colors.white,
//           ),
//         ),
//       ],
//       backgroundColor: color.primary,
//       flexibleSpace: FlexibleSpaceBar(
//         background: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [color.primary, color.primary.withOpacity(0.8)],
//             ),
//           ),
//           child: Stack(
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     fit: BoxFit.cover,
//                     image: const NetworkImage(
//                       "https://www.shutterstock.com/image-photo/job-search-human-resources-recruitment-260nw-1292578582.jpg",
//                     ),
//                     colorFilter: ColorFilter.mode(
//                       Colors.black.withOpacity(0.4),
//                       BlendMode.darken,
//                     ),
//                   ),
//                 ),
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.transparent,
//                       color.primary.withOpacity(0.8),
//                     ],
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: 40,
//                 left: 20,
//                 right: 20,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Recherche d\'emploi',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 28,
//                         fontWeight: FontWeight.w800,
//                         letterSpacing: -0.5,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Trouvez l\'opportunité parfaite',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.9),
//                         fontSize: 16,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchSection(SearchProvider search) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Search bar with filter button
//           Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.08),
//                         blurRadius: 15,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: TextField(
//                     controller: _searchController,
//                     onChanged: search.searchJobs,
//                     decoration: InputDecoration(
//                       hintText: 'Rechercher un emploi...',
//                       hintStyle: TextStyle(color: color.secondary),
//                       prefixIcon: Icon(
//                         Icons.search_rounded,
//                         color: color.primary,
//                         size: 24,
//                       ),
//                       suffixIcon: _showClear
//                           ? IconButton(
//                               onPressed: () {
//                                 _searchController.clear();
//                                 search.clearSearch();
//                                 FocusScope.of(context).unfocus();
//                               },
//                               icon: Icon(
//                                 Icons.clear_rounded,
//                                 color: color.secondary,
//                               ),
//                             )
//                           : null,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16),
//                         borderSide: BorderSide.none,
//                       ),
//                       filled: true,
//                       fillColor: Colors.white,
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Container(
//                 decoration: BoxDecoration(
//                   color: color.primary,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: color.primary.withOpacity(0.3),
//                       blurRadius: 15,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: IconButton(
//                   onPressed: () => _showFilterBottomSheet(search),
//                   icon: const HugeIcon(
//                     icon: HugeIcons.strokeRoundedFilterHorizontal,
//                     color: Colors.white,
//                     size: 24,
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 24),

//           // Results header
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Résultats',
//                       style: TextStyle(
//                         color: color.primary,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Emplois disponibles',
//                       style: TextStyle(color: color.secondary, fontSize: 12),
//                     ),
//                   ],
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     color: color.primary.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     '${search.filteredJobs.length} trouvé${search.filteredJobs.length > 1 ? 's' : ''}',
//                     style: TextStyle(
//                       color: color.primary,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildJobResults(SearchProvider search) {
//     if (search.filteredJobs.isEmpty) {
//       return SliverToBoxAdapter(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.work_off_rounded,
//                 size: 80,
//                 color: Colors.grey.shade400,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Aucun emploi trouvé',
//                 style: TextStyle(
//                   color: color.primary,
//                   fontSize: 20,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Essayez de modifier vos critères de recherche',
//                 style: TextStyle(color: color.secondary, fontSize: 14),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return SliverPadding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       sliver: SliverList(
//         delegate: SliverChildBuilderDelegate((context, index) {
//           final job = search.filteredJobs[index];
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 16),
//             child: _buildModernJobCard(job),
//           );
//         }, childCount: search.filteredJobs.length),
//       ),
//     );
//   }

//   Widget _buildModernJobCard(dynamic job) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) {
//               return JobDetail(job: job);
//             },
//           ),
//         );
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.08),
//               blurRadius: 20,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     width: 60,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: color.tertiary),
//                       borderRadius: BorderRadius.circular(12),
//                       image: DecorationImage(
//                         fit: BoxFit.cover,
//                         onError: (exception, stackTrace) => Icon(Icons.work),
//                         image: NetworkImage(job.imageUrl),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           job.title,
//                           style: TextStyle(
//                             color: color.primary,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w700,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           job.companyName,
//                           style: TextStyle(
//                             color: color.secondary,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: job.status == 'Disponible'
//                           ? color.accepted.withOpacity(0.1)
//                           : color.error.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       job.status,
//                       style: TextStyle(
//                         color: job.status == 'Disponible'
//                             ? color.accepted
//                             : color.error,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               Row(
//                 children: [
//                   _buildInfoChip(Icons.location_on_outlined, job.location),
//                   const SizedBox(width: 12),
//                   _buildInfoChip(Icons.work_outline, job.type),
//                 ],
//               ),

//               const SizedBox(height: 12),

//               Row(
//                 children: [
//                   Icon(
//                     Icons.schedule_outlined,
//                     color: color.secondary,
//                     size: 16,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     job.postDate,
//                     style: TextStyle(color: color.secondary, fontSize: 12),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: color.primary.withOpacity(0.05),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: color.primary.withOpacity(0.1)),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Salaire',
//                       style: TextStyle(
//                         color: color.secondary,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     Text(
//                       "${NumberFormat('#,###').format(job.salary)} GNF",
//                       style: TextStyle(
//                         color: color.primary,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoChip(IconData icon, String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, color: color.primary, size: 14),
//           const SizedBox(width: 4),
//           Text(
//             text,
//             style: TextStyle(
//               color: color.primary,
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showFilterBottomSheet(SearchProvider search) {
//     _filterController.forward();

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         String? selectedType;
//         String? selectedLocation;

//         return StatefulBuilder(
//           builder: (context, setState) {
//             return ScaleTransition(
//               scale: _scaleAnimation,
//               child: Container(
//                 height: MediaQuery.of(context).size.height * 0.6,
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(24),
//                     topRight: Radius.circular(24),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     // Handle bar
//                     Container(
//                       margin: const EdgeInsets.only(top: 12),
//                       width: 40,
//                       height: 4,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade300,
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                     ),

//                     // Header
//                     Padding(
//                       padding: const EdgeInsets.all(20),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Filtres de recherche',
//                             style: TextStyle(
//                               color: color.primary,
//                               fontSize: 20,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               setState(() {
//                                 selectedType = null;
//                                 selectedLocation = null;
//                               });
//                               search.clearSearch();
//                             },
//                             child: Text(
//                               'Effacer',
//                               style: TextStyle(color: color.error),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _buildFilterSection(
//                               'Type d\'emploi',
//                               [
//                                 'Tout',
//                                 'Temps-plein',
//                                 'Temps-partiel',
//                                 'En ligne',
//                               ],
//                               selectedType,
//                               (value) {
//                                 setState(() => selectedType = value);
//                                 search.filterByType(value ?? 'Tout');
//                               },
//                             ),
//                             const SizedBox(height: 20),
//                             _buildFilterSection(
//                               'Localisation',
//                               ['Tout', 'Conakry', 'Kindia', 'Labé'],
//                               selectedLocation,
//                               (value) {
//                                 setState(() => selectedLocation = value);
//                                 search.filterByLocation(value ?? 'Tout');
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),

//                     // Apply button
//                     Padding(
//                       padding: const EdgeInsets.all(20),
//                       child: SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                             _filterController.reset();
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: color.primary,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             elevation: 0,
//                           ),
//                           child: const Text(
//                             'Appliquer les filtres',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildFilterSection(
//     String title,
//     List<String> options,
//     String? selectedValue,
//     Function(String?) onChanged,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             color: color.primary,
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: selectedValue,
//               hint: Text('Sélectionner $title'),
//               isExpanded: true,
//               items: options.map((option) {
//                 return DropdownMenuItem<String>(
//                   value: option,
//                   child: Text(option),
//                 );
//               }).toList(),
//               onChanged: onChanged,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
