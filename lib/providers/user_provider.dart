import 'package:demarcheur_app/models/user_model.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  List<UserModel> _allusers = [];
  bool _isLoading = false;
  List<UserModel> get allusers => _allusers;
  bool get isLoading => _isLoading;

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(Duration(seconds: 5));
    _allusers = [
      UserModel(
        name: "Alphonse Loua",
        speciality: "Developpeur",
        exp: "2 ans d'experience",
        postDate: "10 minutes",
        location: "Sonfonia",
        photo:
            "https://img.freepik.com/premium-photo/young-smart-indian-businessman-smiling-face-standing-blur-background-busy-office-generative-ai-aig20_31965-117857.jpg",
        document: "file:///C:/Users/alpho/Downloads/A4%20-%201.pdf",
        gender: "Masculin",
        status: "En cours",
      ),
      UserModel(
        name: "Jean Koulemou",
        speciality: "Developpeur",
        exp: "2 ans d'experience",
        postDate: "10 minutes",
        location: "Sonfonia",
        photo:
            "https://tse2.mm.bing.net/th/id/OIP.Kkjgf-sb7ikwxUs8qpeLkQHaHa?cb=12&rs=1&pid=ImgDetMain&o=7&rm=3",
        document: "file:///C:/Users/alpho/Downloads/A4%20-%201.pdf",
        gender: "Masculin",
        status: "Interview",
      ),
      UserModel(
        name: "Louis Kolie",
        speciality: "Developpeur frontend",
        exp: "5 ans d'experience",
        postDate: "10 jours",
        location: "Lansanah",
        photo:
            "https://tse2.mm.bing.net/th/id/OIP.so5s5QgNUgKSgouiR2R1zQHaHa?rs=1&pid=ImgDetMain&o=7&rm=3",
        document: "file:///C:/Users/alpho/Downloads/A4%20-%201.pdf",
        gender: "Masculin",
        status: "En cours",
      ),
      UserModel(
        name: "Alpha Oumar Diallo",
        speciality: "Developpeur fullstack",
        exp: "2 ans d'experience",
        postDate: "2 jours",
        location: "Landrea",
        photo:
            "https://tse3.mm.bing.net/th/id/OIP.tQ_A80JuC2lpaRDP9mJY2QHaHa?w=1536&h=1536&rs=1&pid=ImgDetMain&o=7&rm=3",
        document: "file:///C:/Users/alpho/Downloads/A4%20-%201.pdf",
        gender: "Masculin",
        status: "Accepte",
      ),
      UserModel(
        name: "Madeleine Thea",
        speciality: "Developpeur fullstack",
        exp: "2 ans d'experience",
        postDate: "2 jours",
        location: "Nongo",
        photo:
            "https://th.bing.com/th/id/OIP.GbXrupVNmGPefq-s5IGitwHaKo?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3",
        document: "file:///C:/Users/alpho/Downloads/A4%20-%201.pdf",
        gender: "Feminin",
        status: "En cours",
      ),
    ];
    _isLoading = false;
    notifyListeners();
  }
}
