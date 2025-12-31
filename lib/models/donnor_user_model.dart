class DonnorUserModel {
  final String id;
  final String companyName;
  final String logo;
  final String domaine;
  final double rate;
  final String email;
  final String phoneNumber;
  final String location;
  final String passWord;
  bool isVerified;

  DonnorUserModel({
    required this.id,
    required this.companyName,
    required this.logo,
    required this.domaine,
    required this.rate,
    required this.email,
    required this.phoneNumber,
    required this.location,
    required this.passWord,
    this.isVerified = false,
  });

  factory DonnorUserModel.fromJson(Map<String, dynamic> json) {
    return DonnorUserModel(
      id: json['id'],
      companyName: json['companyName'],
      logo: json['logo'],
      domaine: json['domaine'],
      rate: json['rate'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      location: json['location'],
      passWord: json['passWord'],
      isVerified: json['isVerified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'logo': logo,
      'domaine': domaine,
      'rate': rate,
      'email': email,
      'phoneNumber': phoneNumber,
      'location': location,
      'passWord': passWord,
      'isVerified': isVerified,
    };
  }

  DonnorUserModel copyWith({
    String? id,
    String? companyName,
    String? logo,
    String? domaine,
    double? rate,
    String? email,
    String? phoneNumber,
    String? location,
    String? passWord,
    bool? isVerified,
  }) {
    return DonnorUserModel(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      logo: logo ?? this.logo,
      domaine: domaine ?? this.domaine,
      rate: rate ?? this.rate,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      passWord: passWord ?? this.passWord,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
