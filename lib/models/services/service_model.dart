class ServiceModel {
  String? id;
  String service_name;
  String? createdAt;
  String? updatedAt;

  ServiceModel({
    this.id,
    required this.service_name,
    this.createdAt,
    this.updatedAt,
  });
  factory ServiceModel.fromJson(Map<String, dynamic>? json) {
    return ServiceModel(
      id: json!['id'] ?? '',
      service_name: json['service_name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'service_name': service_name,
    'createdAt': createdAt,
    'updated_at': updatedAt,
  };
}
