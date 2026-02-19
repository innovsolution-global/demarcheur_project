class ApplicationModel {
  final String id;
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
    // If the API nests job data
    final job =
        json['jobId'] ?? json['job'] ?? json['JobScalarFieldEnumob'] ?? {};
    final company = job is Map
        ? (job['company'] ?? job['enterprise'] ?? {})
        : {};

    return ApplicationModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title:
          (job is Map ? job['title'] : null) ??
          json['title']?.toString() ??
          'N/A',
      postDate:
          json['createdAt']?.toString() ??
          json['postDate']?.toString() ??
          (job is Map ? job['createdAt']?.toString() : null) ??
          (job is Map ? job['deadline']?.toString() : null) ??
          'Date inconnu',
      companyName:
          (company is Map ? company['name'] : null) ??
          (job is Map ? job['companyName'] : null) ??
          json['companyName']?.toString() ??
          (job is Map && job.containsKey('companyId')
              ? 'Entreprise #${job['companyId'].toString().substring(0, 4)}'
              : 'Entreprise'),
      logo: _sanitizeImage(
        (company is Map ? company['picture'] : null) ??
            (job is Map ? job['picture'] : null) ??
            json['logo']?.toString(),
      ),
      location:
          (job is Map ? (job['city'] ?? job['location']) : null) ??
          json['location']?.toString() ??
          'N/A',
      status: json['status']?.toString() ?? 'En cours',
      jobStatus:
          (job is Map ? job['status'] : null) ??
          json['jobStatus']?.toString() ??
          'Disponible',
    );
  }

  static String _sanitizeImage(String? url) {
    if (url == null || url.isEmpty || url == 'null') {
      return 'https://placehold.co/100x100.png';
    }
    if (url.contains('placehold.co') &&
        !url.endsWith('.png') &&
        !url.endsWith('.jpg')) {
      return '$url.png';
    }
    return url;
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
