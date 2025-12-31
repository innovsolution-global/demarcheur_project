class AddVancyModel {
  String? id;
  String title;
  String description;
  String typeJobe;
  String level;
  String experience;
  int salary;
  String deadline;
  String city;
  String companyId;
  List reqProfile;
  List conditions;
  List benefits;
  List missions;
  List otherInfo;
  String? companyName;
  String? companyImage;
  String? createdAt;

  AddVancyModel({
    this.id,
    required this.benefits,
    required this.city,
    required this.companyId,
    required this.conditions,
    required this.deadline,
    required this.description,
    required this.experience,
    required this.level,
    required this.missions,
    required this.otherInfo,
    required this.reqProfile,
    required this.salary,
    required this.title,
    required this.typeJobe,
    this.companyName,
    this.companyImage,
    this.createdAt,
  });

  factory AddVancyModel.fromJson(Map<String, dynamic> json) {
    return AddVancyModel(
      id: json['id']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      typeJobe: (json['typeJobe'] ?? json['typeJob'] ?? '')?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      experience: (json['experience'] ?? json['experienceYear'] ?? '')?.toString() ?? '',
      salary: int.tryParse(json['salary']?.toString() ?? '0') ?? 0,
      deadline: json['deadline']?.toString() ?? '',
      city: (json['city'] ?? json['location'] ?? '')?.toString() ?? '',
      companyId: (json['companyId'] ?? json['entrepriseId'] ?? '')?.toString() ?? '',
      reqProfile: json['reqProfile'] ?? json['requiredProdfile'] ?? json['requiredProfile'] ?? [],
      conditions: json['conditions'] ?? [],
      benefits: json['benefits'] ?? [],
      missions: json['missions'] ?? [],
      otherInfo: json['otherInfo'] ?? json['otherInfos'] ?? [],
      companyName: json['companyName']?.toString() ?? json['entrepriseName']?.toString(),
      companyImage: json['companyPicture']?.toString() ?? json['entreprisePicture']?.toString(),
      createdAt: json['createdAt']?.toString() ?? json['dateCreation']?.toString(),
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'typeJob': typeJobe,
    'level': level,
    'experience': experience,
    'salary': salary,
    'deadline': deadline,
    'city': city,
    'companyId': companyId,

    'reqProfile': reqProfile,
    'conditions': conditions,
    'benefits': benefits,
    'missions': missions,
    'otherInfo': otherInfo,
    'companyName': companyName,
    'companyPicture': companyImage,
    'createdAt': createdAt,
  };
}
