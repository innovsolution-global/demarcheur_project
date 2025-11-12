class PrestaModel {
  final String? id;
  final String title;
  final String companyName;
  final List imageUrl;
  final String postDate;
  final String location;
  final String status;
  final String categorie;
  final List exigences;
  final String about;
  final String salary;

  PrestaModel({
    this.id,
    required this.title,
    required this.companyName,
    required this.imageUrl,
    required this.postDate,
    required this.location,
    required this.status,
    required this.categorie,
    required this.exigences,
    required this.about,
    required this.salary,
  });
  factory PrestaModel.fromJson(Map<String, dynamic> json) {
    return PrestaModel(
      id: json['id'],
      title: json['title'],
      companyName: json['companyName'],
      imageUrl: json['imageUrl'],
      postDate: json['postDate'],
      location: json['location'],
      status: json['status'],
      categorie: json['categorie'],
      exigences: json['exigences'],
      about: json['about'],
      salary: json['salary'],
    );
  }

  // Serialize Model → JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'companyName': companyName,
    'imageUrl': imageUrl,
    'postDate': postDate,
    'location': location,
    'status': status,
    'categorie': categorie,
    'exigences': exigences,
    'about': about,
    'salary': salary,
  };
}
