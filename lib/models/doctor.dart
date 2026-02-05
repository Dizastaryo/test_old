class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String description;
  final List<String> services;
  final String? photoUrl;
  final double rating;
  final int experienceYears;
  final List<String> languages;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.description,
    this.services = const [],
    this.photoUrl,
    this.rating = 0.0,
    this.experienceYears = 0,
    this.languages = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'description': description,
      'services': services,
      'photoUrl': photoUrl,
      'rating': rating,
      'experienceYears': experienceYears,
      'languages': languages,
    };
  }

  /// Из ответа API back_k: id, full_name, specialty, description, services
  factory Doctor.fromMedkJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    return Doctor(
      id: rawId is int ? rawId.toString() : (rawId?.toString() ?? ''),
      name: (json['full_name'] ?? json['name'] ?? '').toString().trim().isEmpty ? 'Врач' : (json['full_name'] ?? json['name'] ?? '').toString(),
      specialization: (json['specialty'] ?? json['specialization'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      services: json['services'] is List ? (json['services'] as List).map((e) => e.toString()).toList() : [],
    );
  }

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['full_name'] ?? '').toString(),
      specialization: (json['specialization'] ?? json['specialty'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      services: json['services'] is List ? (json['services'] as List).map((e) => e.toString()).toList() : [],
      photoUrl: json['photoUrl']?.toString(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      experienceYears: json['experienceYears'] ?? 0,
      languages: List<String>.from(json['languages'] ?? []),
    );
  }
}
