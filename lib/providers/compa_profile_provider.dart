// lib/providers/job_provider.dart
import 'package:demarcheur_app/models/compa_model.dart';
import 'package:flutter/foundation.dart';

class CompaProfileProvider extends ChangeNotifier {
  List<CompaModel> _info = [];
  bool _isLoading = false;

  List<CompaModel> get info => _info;
  bool get isLoading => _isLoading;

  /// Load local (mock) data for now
  Future<void> loadVancies() async {
    _isLoading = true;
    notifyListeners();

    // 🧩 You can later replace this section with an API call
    await Future.delayed(const Duration(seconds: 1)); // simulate network delay

    _info = [
      CompaModel(
        id: '1',
        title: "Flutter developer",
        postDate: "10 minutes",
        status: "Disponible",
        companyName: 'CodeHub',
        imageUrl:
            "https://th.bing.com/th/id/OIP.vmSybHNKgxBc1uunktEFOgHaHa?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3",
      ),
      CompaModel(
        id: '1',
        title: "Flutter developer",
        postDate: "10 minutes",
        status: "Disponible",
        companyName: 'CodeHub',
        imageUrl:
            "https://th.bing.com/th/id/OIP.vmSybHNKgxBc1uunktEFOgHaHa?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3",
      ),
      CompaModel(
        id: '1',
        title: "Flutter developer",
        postDate: "10 minutes",
        status: "Disponible",
        companyName: 'CodeHub',
        imageUrl:
            "https://th.bing.com/th/id/OIP.vmSybHNKgxBc1uunktEFOgHaHa?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3",
      ),
      CompaModel(
        id: '1',
        title: "Flutter developer",
        postDate: "10 minutes",
        status: "Disponible",
        companyName: 'CodeHub',
        imageUrl:
            "https://th.bing.com/th/id/OIP.vmSybHNKgxBc1uunktEFOgHaHa?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3",
      ),
      CompaModel(
        id: '1',
        title: "Flutter developer",
        postDate: "10 minutes",
        status: "Disponible",
        companyName: 'CodeHub',
        imageUrl:
            "https://th.bing.com/th/id/OIP.vmSybHNKgxBc1uunktEFOgHaHa?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3",
      ),
      CompaModel(
        id: '1',
        title: "UI/UX designer",
        postDate: "10 minutes",
        status: "Disponible",
        companyName: 'CodeHub',
        imageUrl:
            "https://th.bing.com/th/id/OIP.vmSybHNKgxBc1uunktEFOgHaHa?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3",
      ),
      CompaModel(
        id: '2',
        title: "Backend Engeneer",
        postDate: "20 minutes",
        status: "Plus disponible",
        companyName: 'CodeHub',
        imageUrl:
            "https://th.bing.com/th/id/OIP.vmSybHNKgxBc1uunktEFOgHaHa?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3",
      ),
    ];
    _isLoading = false;
    notifyListeners();
  }
}
