class UserModel {
  final String? id;
  final String name;
  final String speciality;
  final String exp;
  final String postDate;
  final String location;
  final String photo;
  final String gender;
  final String status;

  // Le document PDF associé à l'utilisateur
  final String? document; // fichier PDF local ou null

  UserModel({
    this.id,
    required this.name,
    required this.speciality,
    required this.exp,
    required this.postDate,
    required this.location,
    required this.photo,
    this.document,
    required this.gender,
    required this.status,
  });

  // Conversion JSON → objet
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      speciality: json['speciality'],
      exp: json['exp'],
      postDate: json['postDate'],
      location: json['location'],
      photo: json['photo'],
      // On stocke juste le chemin du PDF s'il existe
      document: json['documentPath'],
      gender: json['gender'],
      status: json['status'],
    );
  }

  // Conversion objet → JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'speciality': speciality,
    'exp': exp,
    'postDate': postDate,
    'location': location,
    'photo': photo,
    'documentPath': document,
    'gender': gender,
    'status': status,
  };
}
