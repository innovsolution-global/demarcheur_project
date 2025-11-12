class ApplicationModel {
  final int id;
  final String companyName;
  final String title;
  final String status;
  final String logo;
  final String location;
  final String postDate;
  final String jobStatus;
  ApplicationModel({
    required this.id,
    required this.companyName,
    required this.title,
    required this.status,
    required this.logo,
    required this.location,
    required this.postDate,
    required this.jobStatus,
  });
  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'],
      title: json['title'],
      postDate: json['postDate'],
      companyName: json['companyName'],
      logo: json['logo'],
      location: json['location'],
      status: json['status'],
      jobStatus: json['jobStatus'],
    );
  }
  // Serialize Model → JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'companyName': companyName,
    'logo': logo,
    'title': title,
    'postDate': postDate,
    'location': location,
    'status': status,
    'jobStatus': jobStatus,
  };
}
