class PrestaUserModel {
  final String? id;
  final String companyName;
  final List imageUrl;
  final String location;
  final String status;
  final String categorie;
  final String about;
  final int salary;

  PrestaUserModel({
    this.id,
    required this.companyName,
    required this.imageUrl,
    required this.location,
    required this.status,
    required this.categorie,
    required this.about,
    required this.salary,
  });
  factory PrestaUserModel.fromJson(Map<String, dynamic> json) {
    return PrestaUserModel(
      id: json['id'],
      companyName: json['companyName'],
      imageUrl: json['imageUrl'],
      location: json['location'],
      status: json['status'],
      categorie: json['categorie'],
      about: json['about'],
      salary: json['salary'].toString() as int,
    );
  }

  // Serialize Model → JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'companyName': companyName,
    'imageUrl': imageUrl,
    'location': location,
    'status': status,
    'categorie': categorie,
    'about': about,
    'salary': salary,
  };
}
