// // lib/providers/doctor_provider.dart
// import 'package:demarcheur_app/models/job_model.dart';
// import 'package:flutter/foundation.dart';

// class JobProvider extends ChangeNotifier {
//   //final DoctorRepository _repository = DoctorRepository();
//   List<JobModel> _joblist = [];
//   bool _isLoading = false;

//   List<JobModel> get jobs => _joblist;
//   bool get isLoading => _isLoading;

//   Future<void> loadJobs() async {
//     _isLoading = true;
//     notifyListeners();

//     // Example of loading from API or mock data directly
//     await Future.delayed(const Duration(seconds: 1)); // simulate loading
//     _joblist = [
//       JobModel(
//         id: '1',
//         title: 'Flutter Developer',
//         companyName: 'TechCorp',
//         imageUrl: 'https://example.com/flutter.png',
//         postDate: '2025-10-01',
//         salary: 5000.0,
//         location: 'Remote',
//         type: 'Full-time',
//         status: 'Disponible',
//       ),
//       JobModel(
//         id: '2',
//         title: 'Backend Engineer',
//         companyName: 'CodeHub',
//         imageUrl: 'https://example.com/backend.png',
//         postDate: '2025-09-28',
//         salary: 6000.0,
//         location: 'New York',
//         type: 'Contract',
//         status: 'Disponible',
//       ),
//     ];
//     //_filteredJobs = _allJobs;

//     _isLoading = false;
//     notifyListeners();
//   }
// }
