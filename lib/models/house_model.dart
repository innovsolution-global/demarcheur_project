
class HouseModel {
  String? id;
  String? ownerId;
  String? companyName;
  String? logo;
  String? countType;
  List<String> imageUrl;
  String? postDate;
  double? rent; // Kept for legacy compatibility
  String? location; // Kept for legacy compatibility
  String? city;
  String? type; // This is the ID of the type
  String? status; // Kept for legacy compatibility
  double? rate;
  String? category;

  // New fields from API definition
  String? title;
  String? description;
  String? district;
  int? rooms;
  int? livingRooms;
  String? area;
  String? statusProperty;
  int? garage;
  int? kitchen;
  int? store;
  bool? garden;
  double? price;
  String? otherDescription;
  String? advantage;
  String? condition;
  String? typePropertId; // Misspelled as per API
  String? companyId;
  int? piscine;

  HouseModel({
    this.id,
    this.ownerId,
    this.companyName,
    this.logo,
    this.countType,
    this.imageUrl = const [],
    this.postDate,
    this.rent,
    this.location,
    this.city,
    this.type,
    this.status,
    this.rate,
    this.category,
    this.title,
    this.description,
    this.district,
    this.rooms,
    this.livingRooms,
    this.area,
    this.statusProperty,
    this.garage,
    this.kitchen,
    this.store,
    this.garden,
    this.price,
    this.otherDescription,
    this.advantage,
    this.condition,
    this.typePropertId,
    this.companyId,
    this.piscine,
  });

  factory HouseModel.fromJson(Map<String, dynamic> json) {
    // Robustly handle price/rent parsing from String
    double? parsePrice(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    // Hande images from different formats
    List<String> parseImages(Map<String, dynamic> json) {
      List<String> images = [];
      
      void addImage(dynamic img) {
        if (img == null) return;
        final resolved = Config.getImgUrl(img.toString());
        if (resolved != null) images.add(resolved);
      }

      if (json['imageUrl'] is List) {
        for (var item in json['imageUrl']) addImage(item);
      } else if (json['imageUrl'] is String) {
        addImage(json['imageUrl']);
      }
      
      if (json['cover_image'] != null) {
        addImage(json['cover_image']);
      }
      
      if (json['galery_image'] is List) {
        for (var item in json['galery_image']) addImage(item);
      }
      
      return images.toSet().toList(); // Unique resolved images
    }

    return HouseModel(
      id: (json['id'] ?? json['_id'])?.toString(),
      ownerId: json['ownerId']?.toString() ??
          json['companyId']?.toString() ??
          json['user']?['id']?.toString() ??
          json['user']?['_id']?.toString(),
      companyName: json['companyName'] ??
          json['company_name'] ??
          json['entrepriseName'] ??
          json['entreprise_name'] ??
          json['company_organization'] ??
          json['name_organization'] ??
          json['company']?['name'] ??
          json['company']?['name_organization'] ??
          json['company']?['username'] ??
          json['user']?['name'] ??
          json['user']?['username'] ??
          json['user']?['name_organization'] ??
          json['owner']?['name'] ??
          json['owner']?['username'] ??
          json['owner']?['name_organization'],
      logo: Config.getImgUrl((json['logo'] ??
          json['logo_path'] ??
          json['company_logo'] ??
          json['entreprise_logo'] ??
          json['companyPicture'] ??
          json['entreprisePicture'] ??
          json['company_profile'] ??
          json['entreprise_profile'] ??
          json['company']?['logo'] ??
          json['company']?['profile'] ??
          json['company']?['image'] ??
          json['company']?['photo'] ??
          json['company']?['photoPath'] ??
          json['company']?['photo_path'] ??
          json['company']?['profilePath'] ??
          json['company']?['companyPicture'] ??
          json['company']?['entreprisePicture'] ??
          json['user']?['logo'] ??
          json['user']?['profile'] ??
          json['user']?['image'] ??
          json['user']?['photo'] ??
          json['user']?['photoPath'] ??
          json['user']?['photo_path'] ??
          json['user']?['profilePath'] ??
          json['owner']?['logo'] ??
          json['owner']?['profile'] ??
          json['owner']?['image'] ??
          json['owner']?['photo'] ??
          json['profile'] ??
          json['image'] ??
          json['photo'] ??
          json['photoPath'] ??
          json['photo_path'] ??
          json['profilePath'])?.toString()),
      // Map 'countType' as the display name of the property type
      countType: json['countType'] ?? json['count_type'] ?? json['typeProperty']?['name'],
      imageUrl: parseImages(json),
      postDate: json['postDate'] ?? json['post_date'] ?? json['createdAt'],
      rent: parsePrice(json['rent'] ?? json['price']),
      location: json['location'] ?? json['district'] ?? json['city'],
      city: json['city'] ?? json['ville'],
      // Keep 'type' as the ID for internal use
      type: json['type']?.toString() ?? json['typePropertId']?.toString() ?? json['typeProperty']?['id']?.toString(),
      status: json['status'] ?? json['statusProperty'],
      rate: parsePrice(json['rate']),
      category: json['category'] ?? (json['typeProperty']?['typeEnum'] == 'RESIDENCY' ? 'Location' : json['category']),
      title: json['title'],
      description: json['description'],
      district: json['district'] ?? json['location'],
      rooms: json['rooms'] is int ? json['rooms'] : int.tryParse(json['rooms']?.toString() ?? ''),
      livingRooms: json['living_rooms'] is int ? json['living_rooms'] : int.tryParse(json['living_rooms']?.toString() ?? ''),
      area: json['area']?.toString(),
      statusProperty: json['statusProperty'] ?? json['status'],
      garage: json['garage'] is int ? json['garage'] : int.tryParse(json['garage']?.toString() ?? ''),
      kitchen: json['kitchen'] is int ? json['kitchen'] : int.tryParse(json['kitchen']?.toString() ?? ''),
      store: json['store'] is int ? json['store'] : int.tryParse(json['store']?.toString() ?? ''),
      garden: json['garden'] is bool ? json['garden'] : (json['garden']?.toString() == 'true'),
      price: parsePrice(json['price'] ?? json['rent']),
      otherDescription: json['other_description'],
      advantage: json['advantage']?.toString(),
      condition: json['condition']?.toString(),
      typePropertId: json['typePropertId']?.toString() ?? json['typeProperty']?['id']?.toString(),
      companyId: json['companyId']?.toString() ??
          json['entrepriseId']?.toString() ??
          json['ownerId']?.toString() ??
          json['company']?['id']?.toString() ??
          json['company']?['_id']?.toString() ??
          json['user']?['id']?.toString() ??
          json['user']?['_id']?.toString() ??
          json['owner']?['id']?.toString() ??
          json['owner']?['_id']?.toString(),
      piscine: json['piscine'] is int ? json['piscine'] : int.tryParse(json['piscine']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title ?? companyName,
    'description': description ?? countType,
    'district': district ?? location,
    'city': city,
    'rooms': rooms ?? 0,
    'living_rooms': livingRooms ?? 0,
    'area': area ?? "0",
    'statusProperty': _mapStatus(statusProperty ?? status ?? "Disponible"),
    'garage': garage ?? 0,
    'kitchen': kitchen ?? 0,
    'store': store ?? 0,
    'garden': garden ?? false,
    'piscine': piscine ?? 0,
    'price': price ?? rent ?? 0.0,
    'other_description': otherDescription ?? "",
    'advantage': (advantage != null && advantage!.isNotEmpty) ? [advantage] : [],
    'condition': (condition != null && condition!.isNotEmpty) ? [condition] : [],
    'typePropertId': typePropertId ?? type,
    'companyId': companyId ?? ownerId,
    'category': category ?? "Location",
    
    // Legacy mapping (optional, for safety)
    'id': id,
    'ownerId': ownerId,
    'companyName': companyName,
    'logo': logo,
    'countType': countType,
    'imageUrl': imageUrl,
    'postDate': postDate,
    'rent': rent,
    'location': location,
    'type': type,
    'status': status,
    'rate': rate,
  };

  String _mapStatus(String statusStr) {
    switch (statusStr) {
      case 'Disponible':
        return 'AVAILABLE';
      case 'Loué':
        return 'RENTED';
      case 'En vente':
        return 'AVAILABLE'; // Often enums are simplified
      case 'Réservé':
        return 'BOOKED';
      default:
        if (['AVAILABLE', 'RENTED', 'BOOKED', 'SOLD'].contains(statusStr.toUpperCase())) {
          return statusStr.toUpperCase();
        }
        return 'AVAILABLE';
    }
  }
}
