class CompaModel {
  final String? id;
  final String title;
  final String postDate;
  final String status;
  final String companyName;
  final String imageUrl;

  CompaModel({
    this.id,
    required this.title,
    required this.postDate,
    required this.companyName,
    required this.status,

    required this.imageUrl,
  });
  factory CompaModel.fromJson(Map<String, dynamic> json) {
    return CompaModel(
      id: json['id'],
      title: json['title'],
      status: json['status'],

      postDate: json['postDate'],
      companyName: json['companyName'],
      imageUrl: json['imageUrl'],
    );
  }

  // Serialize Model → JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'postDate': postDate,
    'status': status,
    'companyName': companyName,
    'imageUrl': imageUrl,
  };
}
