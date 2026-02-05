class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int age;
  final String gender;
  final String role; // doctor | patient
  final String? photoUrl;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.age,
    required this.gender,
    this.role = 'patient',
    this.photoUrl,
    required this.createdAt,
  });

  bool get isDoctor => role == 'doctor';
  bool get isPatient => role == 'patient';

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    int? age,
    String? gender,
    String? role,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'gender': gender,
      'role': role,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      age: (json['age'] is int) ? json['age'] : (int.tryParse(json['age']?.toString() ?? '0') ?? 0),
      gender: json['gender']?.toString() ?? '',
      role: json['role']?.toString() ?? 'patient',
      photoUrl: json['photoUrl']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  /// Из ответа /me бэкенда (id, email, phone, role, is_active)
  factory User.fromApiMe(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      age: 0,
      gender: '',
      role: json['role']?.toString() ?? 'patient',
      createdAt: DateTime.now(),
    );
  }
}
