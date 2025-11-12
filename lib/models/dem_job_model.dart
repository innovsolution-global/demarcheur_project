class DemJobModel {
  final String? id;
  final String title;
  final String companyName;
  final String imageUrl;
  final String postDate;
  final double salary;
  final String location;
  final String type;
  final String status;
  final String category;

  DemJobModel({
    this.id,
    required this.title,
    required this.companyName,
    required this.imageUrl,
    required this.postDate,
    required this.salary,
    required this.location,
    required this.type,
    required this.status,
    required this.category,
  });
  factory DemJobModel.fromJson(Map<String, dynamic> json) {
    return DemJobModel(
      id: json['id'],
      title: json['title'],
      companyName: json['companyName'],
      imageUrl: json['imageUrl'],
      postDate: json['postDate'],
      salary: (json['salary'] as num).toDouble(),
      location: json['location'],
      type: json['type'],
      status: json['status'],
      category: json['category'],
    );
  }

  // Serialize Model → JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'companyName': companyName,
    'imageUrl': imageUrl,
    'postDate': postDate,
    'salary': salary,
    'location': location,
    'type': type,
    'status': status,
    'category': category,
  };
}
