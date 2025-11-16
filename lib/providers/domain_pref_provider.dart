import 'package:flutter/foundation.dart';

class DomainModel {
  final String id;
  final String name;
  final String category;

  DomainModel({
    required this.id,
    required this.name,
    required this.category,
  });
}

class DomainPrefProvider extends ChangeNotifier {
  bool _isInitialLoading = true;
  final Set<String> _selectedDomains = {};

  // Domain data organized by categories
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Ingénierie logicielle et Informatique',
      'domains': [
        DomainModel(id: '1', name: 'Développement Mobile', category: 'Ingénierie logicielle et Informatique'),
        DomainModel(id: '2', name: 'Développement web', category: 'Ingénierie logicielle et Informatique'),
        DomainModel(id: '3', name: 'Fullstack development', category: 'Ingénierie logicielle et Informatique'),
        DomainModel(id: '4', name: 'Python development', category: 'Ingénierie logicielle et Informatique'),
        DomainModel(id: '5', name: 'React native', category: 'Ingénierie logicielle et Informatique'),
        DomainModel(id: '6', name: 'React development', category: 'Ingénierie logicielle et Informatique'),
        DomainModel(id: '7', name: 'Flutter development', category: 'Ingénierie logicielle et Informatique'),
        DomainModel(id: '8', name: 'Frontend development', category: 'Ingénierie logicielle et Informatique'),
        DomainModel(id: '9', name: 'Backend development', category: 'Ingénierie logicielle et Informatique'),
        DomainModel(id: '10', name: 'DevOps', category: 'Ingénierie logicielle et Informatique'),
        DomainModel(id: '11', name: 'Java development', category: 'Ingénierie logicielle et Informatique'),
        DomainModel(id: '12', name: 'Node.js development', category: 'Ingénierie logicielle et Informatique'),
      ],
    },
    {
      'name': 'Ingénierie cyber sécurité et Informatique',
      'domains': [
        DomainModel(id: '13', name: 'Cyber sécurité', category: 'Ingénierie cyber sécurité et Informatique'),
        DomainModel(id: '14', name: 'Administrateur réseau', category: 'Ingénierie cyber sécurité et Informatique'),
        DomainModel(id: '15', name: 'Administrateur système', category: 'Ingénierie cyber sécurité et Informatique'),
        DomainModel(id: '16', name: 'Sécurité informatique', category: 'Ingénierie cyber sécurité et Informatique'),
        DomainModel(id: '17', name: 'Audit de sécurité', category: 'Ingénierie cyber sécurité et Informatique'),
      ],
    },
    {
      'name': 'Science des données',
      'domains': [
        DomainModel(id: '18', name: 'Data science', category: 'Science des données'),
        DomainModel(id: '19', name: 'Ingénierie de données', category: 'Science des données'),
        DomainModel(id: '20', name: 'Analyse de données', category: 'Science des données'),
        DomainModel(id: '21', name: 'Machine Learning', category: 'Science des données'),
        DomainModel(id: '22', name: 'Intelligence artificielle', category: 'Science des données'),
        DomainModel(id: '23', name: 'Business Intelligence', category: 'Science des données'),
      ],
    },
    {
      'name': 'Comptabilité et Finance',
      'domains': [
        DomainModel(id: '24', name: 'Comptabilité générale', category: 'Comptabilité et Finance'),
        DomainModel(id: '25', name: 'Comptabilité analytique', category: 'Comptabilité et Finance'),
        DomainModel(id: '26', name: 'Expert-comptable', category: 'Comptabilité et Finance'),
        DomainModel(id: '27', name: 'Fiscalité', category: 'Comptabilité et Finance'),
        DomainModel(id: '28', name: 'Audit financier', category: 'Comptabilité et Finance'),
        DomainModel(id: '29', name: 'Gestion financière', category: 'Comptabilité et Finance'),
        DomainModel(id: '30', name: 'Conseil financier', category: 'Comptabilité et Finance'),
        DomainModel(id: '31', name: 'Contrôle de gestion', category: 'Comptabilité et Finance'),
        DomainModel(id: '32', name: 'Trésorerie', category: 'Comptabilité et Finance'),
      ],
    },
    {
      'name': 'Marketing et Communication',
      'domains': [
        DomainModel(id: '33', name: 'Marketing digital', category: 'Marketing et Communication'),
        DomainModel(id: '34', name: 'Marketing stratégique', category: 'Marketing et Communication'),
        DomainModel(id: '35', name: 'Communication', category: 'Marketing et Communication'),
        DomainModel(id: '36', name: 'Publicité', category: 'Marketing et Communication'),
        DomainModel(id: '37', name: 'Social Media Marketing', category: 'Marketing et Communication'),
        DomainModel(id: '38', name: 'SEO/SEM', category: 'Marketing et Communication'),
        DomainModel(id: '39', name: 'Content Marketing', category: 'Marketing et Communication'),
        DomainModel(id: '40', name: 'Brand Management', category: 'Marketing et Communication'),
        DomainModel(id: '41', name: 'E-marketing', category: 'Marketing et Communication'),
      ],
    },
    {
      'name': 'Vente et Commerce',
      'domains': [
        DomainModel(id: '42', name: 'Vente B2B', category: 'Vente et Commerce'),
        DomainModel(id: '43', name: 'Vente B2C', category: 'Vente et Commerce'),
        DomainModel(id: '44', name: 'Business Development', category: 'Vente et Commerce'),
        DomainModel(id: '45', name: 'Gestion de magasin', category: 'Vente et Commerce'),
        DomainModel(id: '46', name: 'E-commerce', category: 'Vente et Commerce'),
        DomainModel(id: '47', name: 'Relation client', category: 'Vente et Commerce'),
        DomainModel(id: '48', name: 'Négociation commerciale', category: 'Vente et Commerce'),
        DomainModel(id: '49', name: 'Gestion de compte', category: 'Vente et Commerce'),
      ],
    },
    {
      'name': 'Ressources Humaines',
      'domains': [
        DomainModel(id: '50', name: 'Recrutement', category: 'Ressources Humaines'),
        DomainModel(id: '51', name: 'Gestion des talents', category: 'Ressources Humaines'),
        DomainModel(id: '52', name: 'Formation et développement', category: 'Ressources Humaines'),
        DomainModel(id: '53', name: 'Paie et administration', category: 'Ressources Humaines'),
        DomainModel(id: '54', name: 'Relations sociales', category: 'Ressources Humaines'),
        DomainModel(id: '55', name: 'GPEC', category: 'Ressources Humaines'),
        DomainModel(id: '56', name: 'Développement RH', category: 'Ressources Humaines'),
      ],
    },
    {
      'name': 'Santé et Bien-être',
      'domains': [
        DomainModel(id: '57', name: 'Médecine générale', category: 'Santé et Bien-être'),
        DomainModel(id: '58', name: 'Soins infirmiers', category: 'Santé et Bien-être'),
        DomainModel(id: '59', name: 'Pharmacie', category: 'Santé et Bien-être'),
        DomainModel(id: '60', name: 'Kinésithérapie', category: 'Santé et Bien-être'),
        DomainModel(id: '61', name: 'Psychologie', category: 'Santé et Bien-être'),
        DomainModel(id: '62', name: 'Nutrition', category: 'Santé et Bien-être'),
        DomainModel(id: '63', name: 'Médecine spécialisée', category: 'Santé et Bien-être'),
        DomainModel(id: '64', name: 'Soins à domicile', category: 'Santé et Bien-être'),
      ],
    },
    {
      'name': 'Éducation et Formation',
      'domains': [
        DomainModel(id: '65', name: 'Enseignement primaire', category: 'Éducation et Formation'),
        DomainModel(id: '66', name: 'Enseignement secondaire', category: 'Éducation et Formation'),
        DomainModel(id: '67', name: 'Enseignement supérieur', category: 'Éducation et Formation'),
        DomainModel(id: '68', name: 'Formation professionnelle', category: 'Éducation et Formation'),
        DomainModel(id: '69', name: 'E-learning', category: 'Éducation et Formation'),
        DomainModel(id: '70', name: 'Coaching', category: 'Éducation et Formation'),
        DomainModel(id: '71', name: 'Tutorat', category: 'Éducation et Formation'),
      ],
    },
    {
      'name': 'Juridique et Droit',
      'domains': [
        DomainModel(id: '72', name: 'Droit des affaires', category: 'Juridique et Droit'),
        DomainModel(id: '73', name: 'Droit du travail', category: 'Juridique et Droit'),
        DomainModel(id: '74', name: 'Droit fiscal', category: 'Juridique et Droit'),
        DomainModel(id: '75', name: 'Droit immobilier', category: 'Juridique et Droit'),
        DomainModel(id: '76', name: 'Avocat', category: 'Juridique et Droit'),
        DomainModel(id: '77', name: 'Notaire', category: 'Juridique et Droit'),
        DomainModel(id: '78', name: 'Conseil juridique', category: 'Juridique et Droit'),
      ],
    },
    {
      'name': 'Design et Création',
      'domains': [
        DomainModel(id: '79', name: 'Design graphique', category: 'Design et Création'),
        DomainModel(id: '80', name: 'UI/UX Design', category: 'Design et Création'),
        DomainModel(id: '81', name: 'Design web', category: 'Design et Création'),
        DomainModel(id: '82', name: 'Design industriel', category: 'Design et Création'),
        DomainModel(id: '83', name: 'Design d\'intérieur', category: 'Design et Création'),
        DomainModel(id: '84', name: 'Illustration', category: 'Design et Création'),
        DomainModel(id: '85', name: 'Motion Design', category: 'Design et Création'),
        DomainModel(id: '86', name: 'Branding', category: 'Design et Création'),
      ],
    },
    {
      'name': 'Architecture et Construction',
      'domains': [
        DomainModel(id: '87', name: 'Architecture', category: 'Architecture et Construction'),
        DomainModel(id: '88', name: 'Génie civil', category: 'Architecture et Construction'),
        DomainModel(id: '89', name: 'BTP', category: 'Architecture et Construction'),
        DomainModel(id: '90', name: 'Électricité', category: 'Architecture et Construction'),
        DomainModel(id: '91', name: 'Plomberie', category: 'Architecture et Construction'),
        DomainModel(id: '92', name: 'Menuiserie', category: 'Architecture et Construction'),
        DomainModel(id: '93', name: 'Maçonnerie', category: 'Architecture et Construction'),
        DomainModel(id: '94', name: 'Peinture en bâtiment', category: 'Architecture et Construction'),
      ],
    },
    {
      'name': 'Ingénierie et Industrie',
      'domains': [
        DomainModel(id: '95', name: 'Ingénierie mécanique', category: 'Ingénierie et Industrie'),
        DomainModel(id: '96', name: 'Ingénierie électrique', category: 'Ingénierie et Industrie'),
        DomainModel(id: '97', name: 'Ingénierie industrielle', category: 'Ingénierie et Industrie'),
        DomainModel(id: '98', name: 'Maintenance industrielle', category: 'Ingénierie et Industrie'),
        DomainModel(id: '99', name: 'Qualité et contrôle', category: 'Ingénierie et Industrie'),
        DomainModel(id: '100', name: 'Production', category: 'Ingénierie et Industrie'),
      ],
    },
    {
      'name': 'Immobilier',
      'domains': [
        DomainModel(id: '101', name: 'Agent immobilier', category: 'Immobilier'),
        DomainModel(id: '102', name: 'Gestion locative', category: 'Immobilier'),
        DomainModel(id: '103', name: 'Promotion immobilière', category: 'Immobilier'),
        DomainModel(id: '104', name: 'Expertise immobilière', category: 'Immobilier'),
        DomainModel(id: '105', name: 'Syndic de copropriété', category: 'Immobilier'),
      ],
    },
    {
      'name': 'Transport et Logistique',
      'domains': [
        DomainModel(id: '106', name: 'Transport routier', category: 'Transport et Logistique'),
        DomainModel(id: '107', name: 'Logistique', category: 'Transport et Logistique'),
        DomainModel(id: '108', name: 'Supply Chain', category: 'Transport et Logistique'),
        DomainModel(id: '109', name: 'Transport maritime', category: 'Transport et Logistique'),
        DomainModel(id: '110', name: 'Transport aérien', category: 'Transport et Logistique'),
        DomainModel(id: '111', name: 'Livraison', category: 'Transport et Logistique'),
      ],
    },
    {
      'name': 'Hôtellerie et Restauration',
      'domains': [
        DomainModel(id: '112', name: 'Restauration', category: 'Hôtellerie et Restauration'),
        DomainModel(id: '113', name: 'Hôtellerie', category: 'Hôtellerie et Restauration'),
        DomainModel(id: '114', name: 'Cuisine', category: 'Hôtellerie et Restauration'),
        DomainModel(id: '115', name: 'Service en salle', category: 'Hôtellerie et Restauration'),
        DomainModel(id: '116', name: 'Événementiel', category: 'Hôtellerie et Restauration'),
      ],
    },
    {
      'name': 'Agriculture et Agroalimentaire',
      'domains': [
        DomainModel(id: '117', name: 'Agriculture', category: 'Agriculture et Agroalimentaire'),
        DomainModel(id: '118', name: 'Élevage', category: 'Agriculture et Agroalimentaire'),
        DomainModel(id: '119', name: 'Agroalimentaire', category: 'Agriculture et Agroalimentaire'),
        DomainModel(id: '120', name: 'Agronomie', category: 'Agriculture et Agroalimentaire'),
      ],
    },
    {
      'name': 'Médias et Journalisme',
      'domains': [
        DomainModel(id: '121', name: 'Journalisme', category: 'Médias et Journalisme'),
        DomainModel(id: '122', name: 'Rédaction', category: 'Médias et Journalisme'),
        DomainModel(id: '123', name: 'Production audiovisuelle', category: 'Médias et Journalisme'),
        DomainModel(id: '124', name: 'Photographie', category: 'Médias et Journalisme'),
        DomainModel(id: '125', name: 'Vidéographie', category: 'Médias et Journalisme'),
      ],
    },
    {
      'name': 'Conseil et Stratégie',
      'domains': [
        DomainModel(id: '126', name: 'Conseil en management', category: 'Conseil et Stratégie'),
        DomainModel(id: '127', name: 'Conseil en stratégie', category: 'Conseil et Stratégie'),
        DomainModel(id: '128', name: 'Conseil en organisation', category: 'Conseil et Stratégie'),
        DomainModel(id: '129', name: 'Conseil en transformation', category: 'Conseil et Stratégie'),
        DomainModel(id: '130', name: 'Audit organisationnel', category: 'Conseil et Stratégie'),
      ],
    },
    {
      'name': 'Services à la Personne',
      'domains': [
        DomainModel(id: '131', name: 'Aide à domicile', category: 'Services à la Personne'),
        DomainModel(id: '132', name: 'Garde d\'enfants', category: 'Services à la Personne'),
        DomainModel(id: '133', name: 'Ménage et entretien', category: 'Services à la Personne'),
        DomainModel(id: '134', name: 'Coiffure et esthétique', category: 'Services à la Personne'),
        DomainModel(id: '135', name: 'Soins esthétiques', category: 'Services à la Personne'),
      ],
    },
    {
      'name': 'Sport et Loisirs',
      'domains': [
        DomainModel(id: '136', name: 'Entraînement sportif', category: 'Sport et Loisirs'),
        DomainModel(id: '137', name: 'Animation sportive', category: 'Sport et Loisirs'),
        DomainModel(id: '138', name: 'Gestion d\'équipements sportifs', category: 'Sport et Loisirs'),
      ],
    },
  ];

  bool get isInitialLoading => _isInitialLoading;
  Set<String> get selectedDomains => _selectedDomains;
  List<Map<String, dynamic>> get categories => _categories;
  bool get hasSelection => _selectedDomains.isNotEmpty;

  // Initialize loading
  Future<void> initialize() async {
    _isInitialLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    _isInitialLoading = false;
    notifyListeners();
  }

  // Toggle domain selection
  void toggleDomain(String domainId) {
    if (_selectedDomains.contains(domainId)) {
      _selectedDomains.remove(domainId);
    } else {
      _selectedDomains.add(domainId);
    }
    notifyListeners();
  }

  // Check if domain is selected
  bool isSelected(String domainId) {
    return _selectedDomains.contains(domainId);
  }

  // Get selected domain names
  List<String> getSelectedDomainNames() {
    final List<String> names = [];
    for (var category in _categories) {
      final domains = category['domains'] as List<DomainModel>;
      for (var domain in domains) {
        if (_selectedDomains.contains(domain.id)) {
          names.add(domain.name);
        }
      }
    }
    return names;
  }

  // Clear all selections
  void clearSelection() {
    _selectedDomains.clear();
    notifyListeners();
  }
}

