class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String description;
  final String? photoUrl;
  final double rating;
  final int experienceYears;
  final List<String> languages;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.description,
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
      'photoUrl': photoUrl,
      'rating': rating,
      'experienceYears': experienceYears,
      'languages': languages,
    };
  }

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'],
      specialization: json['specialization'],
      description: json['description'],
      photoUrl: json['photoUrl'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      experienceYears: json['experienceYears'] ?? 0,
      languages: List<String>.from(json['languages'] ?? []),
    );
  }
}
