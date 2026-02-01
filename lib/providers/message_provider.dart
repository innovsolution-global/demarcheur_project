import 'package:demarcheur_app/models/send_message_model.dart';
import 'package:flutter/material.dart';

class MessageProvider with ChangeNotifier {
  List<SendMessageModel> _message = [];
  List<SendMessageModel> get listMessag => _message;
  bool _isloading = false;
  bool get isloading => _isloading;
  void loadMessage(List<SendMessageModel> messages) {
    _isloading = true;
    notifyListeners();
    _message = messages;
    _isloading = false;
    notifyListeners();
  }

  Future<void> setMessages() async {
    _isloading = true;
    notifyListeners();
    _message = [
      SendMessageModel(
        id: '1',
        content: 'Bonjour, j\'ai une question concernant votre offre',
        senderId: 'user1',
        receiverId: 'currentUser',
        userName: 'Marie Dupont',
        timestamp: DateTime.now().subtract(Duration(minutes: 5)),
      ),
      SendMessageModel(
        id: '2',
        content: 'Merci pour votre réponse rapide!',
        senderId: 'user2',
        receiverId: 'currentUser',
        userName: 'Jean Martin',
        timestamp: DateTime.now().subtract(Duration(hours: 1)),
      ),
      SendMessageModel(
        id: '3',
        content: 'Est-ce que le poste est toujours disponible?',
        senderId: 'user3',
        receiverId: 'currentUser',
        userName: 'Sophie Bernard',
        timestamp: DateTime.now().subtract(Duration(hours: 3)),
      ),
      SendMessageModel(
        id: '4',
        content: 'Je suis intéressé par votre profil',
        senderId: 'user4',
        receiverId: 'currentUser',
        userName: 'Pierre Dubois',
        timestamp: DateTime.now().subtract(Duration(days: 1)),
      ),
      SendMessageModel(
        id: '5',
        content: 'Pouvons-nous planifier un entretien?',
        senderId: 'user5',
        receiverId: 'currentUser',
        userName: 'Alphonse Laurent',
        timestamp: DateTime.now().subtract(Duration(days: 1)),
      ),
      SendMessageModel(
        id: '5',
        content: 'Pouvons-nous planifier un entretien?',
        senderId: 'user5',
        receiverId: 'currentUser',
        userName: 'Alphonse Laurent',
        timestamp: DateTime.now().subtract(Duration(days: 1)),
      ),
      SendMessageModel(
        id: '5',
        content: 'Pouvons-nous planifier un entretien?',
        senderId: 'user5',
        receiverId: 'currentUser',
        userName: 'Alphonse Laurent',
        timestamp: DateTime.now().subtract(Duration(days: 1)),
      ),
      SendMessageModel(
        id: '5',
        content: 'Pouvons-nous planifier un entretien?',
        senderId: 'user5',
        receiverId: 'currentUser',
        userName: 'Alphonse Laurent',
        timestamp: DateTime.now().subtract(Duration(days: 1)),
      ),
      SendMessageModel(
        id: '5',
        content: 'Pouvons-nous planifier un entretien?',
        senderId: 'user5',
        receiverId: 'currentUser',
        userName: 'Alphonse Laurent',
        timestamp: DateTime.now().subtract(Duration(days: 1)),
      ),
    ];
    _isloading = false;
    notifyListeners();
  }
}
