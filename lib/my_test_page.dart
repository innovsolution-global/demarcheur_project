// // lib/screens/doctor_list_screen.dart
// import 'package:demarcheur_app/consts/color.dart';
// import 'package:demarcheur_app/providers/job_provider.dart';
// import 'package:demarcheur_app/widgets/sub_title.dart';
// import 'package:demarcheur_app/widgets/title_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:provider/provider.dart';

// class MyTestPage extends StatelessWidget {
//   const MyTestPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     ConstColors colors = ConstColors();
//     return Scaffold(
//       backgroundColor: colors.bg,
//       appBar: AppBar(
//         title: TitleWidget(text: "Doctors", color: colors.bg, fontSize: 20),
//         backgroundColor: colors.primary,
//       ),
//       body: Consumer<JobProvider>(
//         builder: (context, provider, _) {
//           if (provider.isLoading) {
//             return Center(
//               child: SpinKitFadingCircle(color: colors.primary, size: 100.0),
//             );
//           }
//           if (provider.jobs.isEmpty) {
//             return Center(
//               child: Padding(
//                 padding: EdgeInsets.all(20),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: double.infinity,
//                       height: 200,
//                       decoration: BoxDecoration(
//                         image: DecorationImage(
//                           fit: BoxFit.cover,
//                           image: AssetImage('assets/reservation.png'),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     TitleWidget(
//                       text:
//                           "Oops il semble que vous n'avez pas encore de favoris",
//                       fontSize: 20,
//                       color: colors.primary,
//                     ),
//                     SizedBox(height: 20),
//                     TitleWidget(
//                       text: "Qui voulez-vous besoin?",
//                       color: colors.primary,
//                       fontSize: 16,
//                     ),
//                     SizedBox(height: 20),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pushNamed(context, "/doctors");
//                       },
//                       child: Container(
//                         width: double.infinity,
//                         height: 70,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(16),
//                           color: colors.bg,
//                           border: Border.all(color: colors.primary),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             children: [
//                               Container(
//                                 width: 50,
//                                 height: 50,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: colors.primary,
//                                 ),
//                                 child: Center(
//                                   child: Icon(Icons.person, color: colors.bg),
//                                 ),
//                               ),
//                               SizedBox(width: 8),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   TitleWidget(
//                                     text: "Un medecin",
//                                     fontSize: 20,
//                                     color: colors.primary,
//                                   ),
//                                   SubTitle(
//                                     text: "Cliquez ici pour voir les medecins",
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pushNamed(context, "/pharmaciens");
//                       },
//                       child: Container(
//                         width: double.infinity,
//                         height: 70,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(16),
//                           color: colors.bg,
//                           border: Border.all(color: colors.primary),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             children: [
//                               Container(
//                                 width: 50,
//                                 height: 50,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: colors.primary,
//                                 ),
//                                 child: Center(
//                                   child: Icon(Icons.person, color: colors.bg),
//                                 ),
//                               ),
//                               SizedBox(width: 8),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   TitleWidget(
//                                     text: "Un pharmacien",
//                                     fontSize: 20,
//                                     color: colors.primary,
//                                   ),
//                                   SubTitle(
//                                     text:
//                                         "Cliquez ici pour voir les pharmaciens",
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }

//           return ListView.builder(
//             itemCount: provider.jobs.length,
//             itemBuilder: (context, index) {
//               final jobs = provider.jobs[index];
//               return ListTile(
//                 title: Text(jobs.title),
//                 subtitle: Text(jobs.companyName),
//                 trailing: Text("⭐ ${jobs.salary.toStringAsFixed(1)}"),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           context.read<JobProvider>().loadJobs();
//         },
//         child: const Icon(Icons.refresh),
//       ),
//     );
//   }
// }
