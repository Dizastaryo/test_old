class Appointment {
  final String id;
  final String userId;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final DateTime dateTime;
  final String status; // 'scheduled', 'completed', 'cancelled'
  final String? notes;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.dateTime,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialization': doctorSpecialization,
      'dateTime': dateTime.toIso8601String(),
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      userId: json['userId'],
      doctorId: json['doctorId'],
      doctorName: json['doctorName'],
      doctorSpecialization: json['doctorSpecialization'],
      dateTime: DateTime.parse(json['dateTime']),
      status: json['status'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  /// Из ответа API medk: id, patient_id, doctor_id, scheduled_at, status, doctor_name, created_at
  factory Appointment.fromMedkJson(Map<String, dynamic> json, {String? userId}) {
    final rawId = json['id'];
    final rawDoctorId = json['doctor_id'];
    final scheduledAt = json['scheduled_at'];
    final createdAt = json['created_at'];
    return Appointment(
      id: rawId is int ? rawId.toString() : (rawId?.toString() ?? ''),
      userId: userId ?? (json['patient_id']?.toString() ?? ''),
      doctorId: rawDoctorId is int ? rawDoctorId.toString() : (rawDoctorId?.toString() ?? ''),
      doctorName: (json['doctor_name'] ?? 'Врач').toString(),
      doctorSpecialization: (json['doctor_specialization'] ?? '').toString(),
      dateTime: scheduledAt != null ? DateTime.parse(scheduledAt.toString()) : DateTime.now(),
      status: (json['status'] ?? 'scheduled').toString(),
      notes: json['complaint']?.toString(),
      createdAt: createdAt != null ? DateTime.parse(createdAt.toString()) : DateTime.now(),
    );
  }
}
