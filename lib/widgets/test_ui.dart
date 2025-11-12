// // lib/screens/job_list_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/search_provider.dart';

// class JobListScreen extends StatefulWidget {
//   const JobListScreen({super.key});

//   @override
//   State<JobListScreen> createState() => _JobListScreenState();
// }

// class _JobListScreenState extends State<JobListScreen> {
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     // Load local mock data when screen starts
//     Future.microtask(() {
//       context.read<SearchProvider>().loadJobs();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<SearchProvider>();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Job Listings'),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               context.read<SearchProvider>().loadJobs(); // refresh mock data
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // 🔍 Search bar
//           Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: TextField(
//               controller: _searchController,
//               onChanged: provider.searchJobs,
//               decoration: InputDecoration(
//                 prefixIcon: const Icon(Icons.search),
//                 hintText: 'Search by title, company, or location',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//           ),

//           // 📋 Job list
//           Expanded(
//             child: provider.isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : ListView.builder(
//                     itemCount: provider.filteredJobs.length,
//                     itemBuilder: (context, index) {
//                       final job = provider.filteredJobs[index];
//                       return Card(
//                         margin: const EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 6,
//                         ),
//                         elevation: 2,
//                         child: ListTile(
//                           leading: ClipRRect(
//                             borderRadius: BorderRadius.circular(8),
//                             child: Image.network(
//                               job.imageUrl,
//                               width: 50,
//                               height: 50,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) =>
//                                   const Icon(Icons.work, size: 40),
//                             ),
//                           ),
//                           title: Text(job.title),
//                           subtitle: Text(
//                             '${job.companyName} • ${job.location}',
//                           ),
//                           trailing: Text(
//                             '\$${job.salary.toStringAsFixed(0)}',
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
