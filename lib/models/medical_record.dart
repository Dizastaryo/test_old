class MedicalRecord {
  final String id;
  final String userId;
  final String doctorId;
  final String doctorName;
  final DateTime visitDate;
  final String? diagnosis;
  final String? symptoms;
  final String? treatment;
  final List<AnalysisResult>? analyses;

  MedicalRecord({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.doctorName,
    required this.visitDate,
    this.diagnosis,
    this.symptoms,
    this.treatment,
    this.analyses,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'visitDate': visitDate.toIso8601String(),
      'diagnosis': diagnosis,
      'symptoms': symptoms,
      'treatment': treatment,
      'analyses': analyses?.map((a) => a.toJson()).toList(),
    };
  }

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'],
      userId: json['userId'],
      doctorId: json['doctorId'],
      doctorName: json['doctorName'],
      visitDate: DateTime.parse(json['visitDate']),
      diagnosis: json['diagnosis'],
      symptoms: json['symptoms'],
      treatment: json['treatment'],
      analyses: json['analyses'] != null
          ? (json['analyses'] as List)
              .map((a) => AnalysisResult.fromJson(a))
              .toList()
          : null,
    );
  }
}

class AnalysisResult {
  final String id;
  final String name;
  final String type; // 'blood', 'urine', 'xray', 'other'
  final DateTime date;
  final Map<String, dynamic> results;
  final String? notes;

  AnalysisResult({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    required this.results,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'date': date.toIso8601String(),
      'results': results,
      'notes': notes,
    };
  }

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      date: DateTime.parse(json['date']),
      results: Map<String, dynamic>.from(json['results']),
      notes: json['notes'],
    );
  }
}
