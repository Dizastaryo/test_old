class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int age;
  final String gender;
  final String role; // doctor | patient | admin
  final String? photoUrl;
  final DateTime createdAt;
  final String? firstName;
  final String? lastName;
  final String? address;
  final int? heightCm;
  final int? weightKg;

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
    this.firstName,
    this.lastName,
    this.address,
    this.heightCm,
    this.weightKg,
  });

  bool get isDoctor => role == 'doctor';
  bool get isPatient => role == 'patient';
  bool get isAdmin => role == 'admin';

  /// Профиль пациента заполнен (имя и фамилия есть).
  bool get profileComplete =>
      (firstName != null && firstName!.trim().isNotEmpty) &&
      (lastName != null && lastName!.trim().isNotEmpty);

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
    String? firstName,
    String? lastName,
    String? address,
    int? heightCm,
    int? weightKg,
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
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
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
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'heightCm': heightCm,
      'weightKg': weightKg,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final fn = json['firstName']?.toString();
    final ln = json['lastName']?.toString();
    final name = [fn, ln].where((s) => s != null && s.isNotEmpty).join(' ').trim();
    return User(
      id: json['id']?.toString() ?? '',
      name: name.isNotEmpty ? name : (json['name']?.toString() ?? json['phone']?.toString() ?? ''),
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      age: (json['age'] is int) ? json['age'] : (int.tryParse(json['age']?.toString() ?? '0') ?? 0),
      gender: json['gender']?.toString() ?? '',
      role: json['role']?.toString() ?? 'patient',
      photoUrl: json['photoUrl']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
      firstName: fn,
      lastName: ln,
      address: json['address']?.toString(),
      heightCm: json['heightCm'] is int ? json['heightCm'] : int.tryParse(json['heightCm']?.toString() ?? ''),
      weightKg: json['weightKg'] is int ? json['weightKg'] : int.tryParse(json['weightKg']?.toString() ?? ''),
    );
  }

  /// Из ответа /me бэкенда (id, phone, role, first_name, last_name, address, height_cm, weight_kg, gender).
  factory User.fromApiMe(Map<String, dynamic> json) {
    final phone = json['phone']?.toString() ?? '';
    final fn = json['first_name']?.toString()?.trim();
    final ln = json['last_name']?.toString()?.trim();
    final name = [fn, ln].where((s) => s != null && s.isNotEmpty).join(' ').trim();
    final gender = json['gender']?.toString() ?? '';
    return User(
      id: json['id']?.toString() ?? '',
      name: name.isNotEmpty ? name : (phone.isNotEmpty ? phone : 'Пользователь'),
      email: json['email']?.toString() ?? '',
      phone: phone,
      age: 0,
      gender: gender,
      role: json['role']?.toString() ?? 'patient',
      createdAt: DateTime.now(),
      firstName: fn,
      lastName: ln,
      address: json['address']?.toString(),
      heightCm: json['height_cm'] is int ? json['height_cm'] : int.tryParse(json['height_cm']?.toString() ?? ''),
      weightKg: json['weight_kg'] is int ? json['weight_kg'] : int.tryParse(json['weight_kg']?.toString() ?? ''),
    );
  }
}
