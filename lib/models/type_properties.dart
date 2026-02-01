class TypeProperties {
  String? id;
  String tyPePropertyName;
  String typeEnum;
  String? createdAt;
  String? updatedAt;

  TypeProperties({
    this.id,
    required this.tyPePropertyName,
    required this.typeEnum,
    this.createdAt,
    this.updatedAt,
  });
  factory TypeProperties.fromJson(Map<String, dynamic> json) {
    // ignore: avoid_print
    print("DEBUG: TypeProperties.fromJson parsing: $json");
    return TypeProperties(
      id: (json['id'] ?? json['_id'])?.toString(),
      tyPePropertyName: json['tyPePropertyName'],
      typeEnum: json['typeEnum'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
  Map<String, dynamic> toJson() => {
    "id": id,
    "tyPePropertyName": tyPePropertyName,
    "typeEnum": typeEnum,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}
