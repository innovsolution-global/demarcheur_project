import 'package:demarcheur_app/models/presta/presta_model.dart';
import 'package:flutter/foundation.dart';

class Conversation {
  final PrestaModel presta;
  String lastMessage;
  String timeLabel;
  int unreadCount;
  Conversation({
    required this.presta,
    required this.lastMessage,
    required this.timeLabel,
    required this.unreadCount,
  });
}

class ChatProvider extends ChangeNotifier {
  final List<Conversation> _conversations = [];

  List<Conversation> get conversations => List.unmodifiable(_conversations);

  void seedFromJobs(List<PrestaModel> jobs) {
    if (_conversations.isNotEmpty) return;
    final samples = [
      "Bonjour, êtes-vous disponible cette semaine ?",
      "Merci pour votre retour.",
      "Pouvez-vous partager un devis ?",
      "Nous pouvons intervenir demain.",
      "Je vous appelle dans 10 minutes.",
    ];
    final times = ["09:41", "Hier", "09 Nov", "08 Nov", "07 Nov"];
    for (int i = 0; i < jobs.length; i++) {
      _conversations.add(
        Conversation(
          presta: jobs[i],
          lastMessage: samples[i % samples.length],
          timeLabel: i < times.length ? times[i] : "Récemment",
          unreadCount: i % 3 == 0 ? 2 : 0,
        ),
      );
    }
    notifyListeners();
  }

  void updateLastMessage(PrestaModel presta, String message, String timeLabel) {
    final idx = _conversations.indexWhere(
      (c) => c.presta.title == presta.title,
    );
    if (idx != -1) {
      _conversations[idx].lastMessage = message;
      _conversations[idx].timeLabel = timeLabel;
      notifyListeners();
    }
  }
}
