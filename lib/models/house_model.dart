class HouseModel {
  final String? id;
  final String companyName;
  final String logo;
  final String countType;
    final List<String> 
 imageUrl;
  final String postDate;
  final double rent;
  final String location;
  final String type;
  final double rate;
  final String status;
  final String category;

  HouseModel({
    this.id,
    required this.companyName,
    required this.logo,
    required this.countType,
    required this.imageUrl,
    required this.postDate,
    required this.rent,
    required this.location,
    required this.type,
    required this.rate,
    required this.status,
    required this.category,
  });
  factory HouseModel.fromJson(Map<String, dynamic> json) {
    return HouseModel(
      id: json['id'],
      companyName: json['companyName'],
      logo: json['logo'],
      countType: json['countType'],
      imageUrl: json['imageUrl'],
      postDate: json['postDate'],
      rent: (json['rent'] as num).toDouble(),
      location: json['location'],
      type: json['type'],
      status: json['status'],
      rate: (json['rate'] as num).toDouble(),
      category: json['category'],
    );
  }

  // Serialize Model → JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'companyName': companyName,
    'logo': logo,
    'countType': countType,
    'imageUrl': imageUrl,
    'postDate': postDate,
    'salary': rent,
    'location': location,
    'type': type,
    'status': status,
    'rate': rate,
    'category': category,
  };
}
