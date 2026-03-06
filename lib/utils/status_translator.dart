class StatusTranslator {
  static const Map<String, String> _translations = {
    'pending': 'En attente',
    'submitted': 'Soumis',
    'reviewed': 'En cours',
    'interview': 'Entretien',
    'accepted': 'Accepté',
    'rejected': 'Rejeté',
    'en attente': 'En attente',
    'soumis': 'Soumis',
    'en cours': 'En cours',
    'entretien': 'Entretien',
    'accepté': 'Accepté',
    'rejeté': 'Rejeté',
  };

  static String translate(String status) {
    if (status.isEmpty) return 'N/A';
    final lowerStatus = status.toLowerCase().trim();
    
    // Check for exact match
    if (_translations.containsKey(lowerStatus)) {
      return _translations[lowerStatus]!;
    }

    // Check for partial matches
    if (lowerStatus.contains('accept')) return 'Accepté';
    if (lowerStatus.contains('reject')) return 'Rejeté';
    if (lowerStatus.contains('rejet')) return 'Rejeté';
    if (lowerStatus.contains('interview')) return 'Entretien';
    if (lowerStatus.contains('attente')) return 'En attente';
    if (lowerStatus.contains('soumis')) return 'Soumis';
    if (lowerStatus.contains('pending')) return 'En attente';
    if (lowerStatus.contains('reviewed')) return 'En cours';

    return status; // Return original if no translation found
  }
}
