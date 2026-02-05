import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/user.dart';

/// Сервис для запросов к бэкенду back_k.
class ApiService {
  static String get baseUrl => AppConstants.apiBaseUrl;

  static Map<String, String> _headers({String? token}) {
    final m = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      m['Authorization'] = 'Bearer $token';
    }
    return m;
  }

  /// POST /api/v1/auth/request-otp — запрос кода в WhatsApp
  static Future<void> requestOtp(String phone) async {
    final normalized = phone.replaceAll(RegExp(r'\D'), '');
    if (normalized.length < 10) throw ApiException(400, 'Введите номер телефона');
    final r = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/request-otp'),
      headers: _headers(),
      body: jsonEncode({'phone': normalized}),
    );
    final data = jsonDecode(r.body is String ? r.body : '{}') as Map<String, dynamic>? ?? {};
    if (r.statusCode >= 400) {
      throw ApiException(r.statusCode, data['detail']?.toString() ?? r.body);
    }
  }

  /// POST /api/v1/auth/login-admin — вход админа без OTP (только номер 77001234567)
  static Future<Map<String, dynamic>> loginAdmin(String phone) async {
    final normalized = phone.replaceAll(RegExp(r'\D'), '');
    if (normalized.length < 10) throw ApiException(400, 'Введите номер телефона');
    final r = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/login-admin'),
      headers: _headers(),
      body: jsonEncode({'phone': normalized}),
    );
    final data = jsonDecode(r.body is String ? r.body : '{}') as Map<String, dynamic>? ?? {};
    if (r.statusCode >= 400) {
      throw ApiException(r.statusCode, data['detail']?.toString() ?? r.body);
    }
    return data;
  }

  /// POST /api/v1/auth/verify-otp — проверка кода и вход (без пароля)
  static Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    final normalized = phone.replaceAll(RegExp(r'\D'), '');
    if (normalized.length < 10) throw ApiException(400, 'Введите номер телефона');
    final r = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/verify-otp'),
      headers: _headers(),
      body: jsonEncode({'phone': normalized, 'code': code.replaceAll(RegExp(r'\D'), '')}),
    );
    final data = jsonDecode(r.body is String ? r.body : '{}') as Map<String, dynamic>? ?? {};
    if (r.statusCode >= 400) {
      throw ApiException(r.statusCode, data['detail']?.toString() ?? r.body);
    }
    return data;
  }

  /// GET /api/v1/auth/me
  static Future<User> me(String token) async {
    final r = await http.get(
      Uri.parse('$baseUrl/api/v1/auth/me'),
      headers: _headers(token: token),
    );
    final data = jsonDecode(r.body is String ? r.body : '{}') as Map<String, dynamic>? ?? {};
    if (r.statusCode >= 400) {
      throw ApiException(r.statusCode, data['detail']?.toString() ?? r.body);
    }
    return User.fromApiMe(data);
  }

  /// PATCH /api/v1/auth/profile — заполнение профиля пациента (имя, фамилия, адрес, рост, вес, пол)
  static Future<User> updateProfile(
    String token, {
    required String firstName,
    required String lastName,
    required String address,
    required int heightCm,
    required int weightKg,
    required String gender,
  }) async {
    final r = await http.patch(
      Uri.parse('$baseUrl/api/v1/auth/profile'),
      headers: _headers(token: token),
      body: jsonEncode({
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'address': address.trim(),
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'gender': gender.toUpperCase().startsWith('M') ? 'M' : 'F',
      }),
    );
    final data = jsonDecode(r.body is String ? r.body : '{}') as Map<String, dynamic>? ?? {};
    if (r.statusCode >= 400) {
      throw ApiException(r.statusCode, data['detail']?.toString() ?? r.body);
    }
    return User.fromApiMe(data);
  }

  /// GET /api/v1/admin/doctors — список врачей (только для админа)
  static Future<List<dynamic>> adminListDoctors(String token) async {
    final r = await http.get(
      Uri.parse('$baseUrl/api/v1/admin/doctors'),
      headers: _headers(token: token),
    );
    final data = jsonDecode(r.body is String ? r.body : '[]');
    if (r.statusCode >= 400) {
      final m = data is Map ? data['detail']?.toString() : r.body;
      throw ApiException(r.statusCode, m ?? r.body);
    }
    return data is List ? data : [];
  }

  /// POST /api/v1/admin/doctors — добавить врача (номер + специальность), только для админа
  static Future<Map<String, dynamic>> adminAddDoctor(
    String token, {
    required String phone,
    required String specialty,
  }) async {
    final normalized = phone.replaceAll(RegExp(r'\D'), '');
    if (normalized.length < 10) throw ApiException(400, 'Номер не менее 10 цифр');
    final r = await http.post(
      Uri.parse('$baseUrl/api/v1/admin/doctors'),
      headers: _headers(token: token),
      body: jsonEncode({'phone': normalized, 'specialty': specialty.trim()}),
    );
    final data = jsonDecode(r.body is String ? r.body : '{}') as Map<String, dynamic>? ?? {};
    if (r.statusCode >= 400) {
      throw ApiException(r.statusCode, data['detail']?.toString() ?? r.body);
    }
    return data;
  }

  /// GET /api/v1/medk/doctors — список врачей для пациентов (без токена)
  static Future<List<dynamic>> medkListDoctors() async {
    final r = await http.get(Uri.parse('$baseUrl/api/v1/medk/doctors'), headers: _headers());
    if (r.statusCode >= 400) {
      throw ApiException(r.statusCode, r.body is String ? r.body : 'Ошибка загрузки врачей');
    }
    final raw = r.body is String ? r.body : '[]';
    if (raw.trim().isEmpty) return [];
    dynamic data;
    try {
      data = jsonDecode(raw);
    } catch (_) {
      return [];
    }
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      if (data['data'] is List) return data['data'] as List;
      if (data['doctors'] is List) return data['doctors'] as List;
    }
    return [];
  }

  /// GET /api/v1/medk/doctors/by-user/{user_id} — карточка врача по user_id
  static Future<Map<String, dynamic>?> medkGetDoctorByUser(int userId) async {
    final r = await http.get(
      Uri.parse('$baseUrl/api/v1/medk/doctors/by-user/$userId'),
      headers: _headers(),
    );
    if (r.statusCode == 404 || r.body == 'null' || r.body.isEmpty) return null;
    final data = jsonDecode(r.body is String ? r.body : '{}') as Map<String, dynamic>?;
    if (r.statusCode >= 400) throw ApiException(r.statusCode, data?['detail']?.toString() ?? r.body);
    return data;
  }

  /// PATCH /api/v1/medk/doctors/me — обновить профиль врача (описание, услуги)
  static Future<Map<String, dynamic>> medkUpdateDoctorProfile(
    String token, {
    String? fullName,
    String? specialty,
    String? description,
    List<String>? services,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['full_name'] = fullName;
    if (specialty != null) body['specialty'] = specialty;
    if (description != null) body['description'] = description;
    if (services != null) body['services'] = services;
    final r = await http.patch(
      Uri.parse('$baseUrl/api/v1/medk/doctors/me'),
      headers: _headers(token: token),
      body: jsonEncode(body),
    );
    final data = jsonDecode(r.body is String ? r.body : '{}') as Map<String, dynamic>? ?? {};
    if (r.statusCode >= 400) throw ApiException(r.statusCode, data['detail']?.toString() ?? r.body);
    return data;
  }

  /// POST /medk/doctors/ensure — получить или создать врача (user_id для заглушки можно 1)
  static Future<Map<String, dynamic>> medkEnsureDoctor({required int userId, String fullName = ''}) async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/v1/medk/doctors/ensure?user_id=$userId&full_name=${Uri.encodeComponent(fullName)}'),
      headers: _headers(),
    );
    final data = jsonDecode(r.body is String ? r.body : '{}') as Map<String, dynamic>? ?? {};
    if (r.statusCode >= 400) throw ApiException(r.statusCode, data['detail']?.toString() ?? r.body);
    return data;
  }

  /// GET /medk/appointments?doctor_id= или patient_id=
  static Future<List<dynamic>> medkListAppointments({int? doctorId, int? patientId, String? status}) async {
    var uri = '$baseUrl/api/v1/medk/appointments?';
    if (doctorId != null) uri += 'doctor_id=$doctorId&';
    if (patientId != null) uri += 'patient_id=$patientId&';
    if (status != null && status.isNotEmpty) uri += 'status=$status&';
    final r = await http.get(Uri.parse(uri), headers: _headers());
    final data = jsonDecode(r.body is String ? r.body : '[]');
    if (r.statusCode >= 400) throw ApiException(r.statusCode, r.body);
    return data is List ? data : [];
  }

  /// POST /medk/appointments
  static Future<Map<String, dynamic>> medkCreateAppointment({
    required int patientId,
    required int doctorId,
    required DateTime scheduledAt,
  }) async {
    final body = {
      'patient_id': patientId,
      'doctor_id': doctorId,
      'scheduled_at': scheduledAt.toIso8601String(),
    };
    final r = await http.post(
      Uri.parse('$baseUrl/api/v1/medk/appointments'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    final data = jsonDecode(r.body is String ? r.body : '{}') as Map<String, dynamic>? ?? {};
    if (r.statusCode >= 400) throw ApiException(r.statusCode, data['detail']?.toString() ?? r.body);
    return data;
  }

  /// GET /medk/appointments/{id}
  static Future<Map<String, dynamic>> medkGetAppointment(int id) async {
    final r = await http.get(Uri.parse('$baseUrl/api/v1/medk/appointments/$id'), headers: _headers());
    final data = jsonDecode(r.body is String ? r.body : '{}') as Map<String, dynamic>? ?? {};
    if (r.statusCode >= 400) throw ApiException(r.statusCode, data['detail']?.toString() ?? r.body);
    return data;
  }

  /// POST /medk/appointments/{id}/complete
  static Future<Map<String, dynamic>> medkCompleteAppointment(
    int appointmentId, {
    required String complaint,
    required String diagnosis,
    required String treatmentText,
    String? familyAnamnesisSnapshot,
  }) async {
    final body = {
      'complaint': complaint,
      'diagnosis': diagnosis,
      'treatment_text': treatmentText,
      if (familyAnamnesisSnapshot != null) 'family_anamnesis_snapshot': familyAnamnesisSnapshot,
    };
    final r = await http.post(
      Uri.parse('$baseUrl/api/v1/medk/appointments/$appointmentId/complete'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    final data = jsonDecode(r.body is String ? r.body : '{}') as Map<String, dynamic>? ?? {};
    if (r.statusCode >= 400) throw ApiException(r.statusCode, data['detail']?.toString() ?? r.body);
    return data;
  }

  /// GET /api/v1/medk/patients/by-user/{user_id} — пациент по user_id (без создания)
  static Future<Map<String, dynamic>?> medkGetPatientByUser(int userId) async {
    final r = await http.get(
      Uri.parse('$baseUrl/api/v1/medk/patients/by-user/$userId'),
      headers: _headers(),
    );
    if (r.statusCode == 404 || r.body == 'null' || (r.body.isEmpty)) return null;
    final data = jsonDecode(r.body is String ? r.body : '{}') as Map<String, dynamic>?;
    if (r.statusCode >= 400) throw ApiException(r.statusCode, data?['detail']?.toString() ?? r.body);
    return data;
  }

  /// GET /medk/patients
  static Future<List<dynamic>> medkListPatients() async {
    final r = await http.get(Uri.parse('$baseUrl/api/v1/medk/patients'), headers: _headers());
    if (r.statusCode >= 400) throw ApiException(r.statusCode, r.body);
    final data = jsonDecode(r.body is String ? r.body : '[]');
    return data is List ? data : [];
  }

  /// POST /medk/patients
  static Future<Map<String, dynamic>> medkCreatePatient({
    required String fullName,
    String? sex,
    double? heightCm,
    double? weightKg,
    String? familyAnamnesis,
    List<String>? chronicConditions,
    int? userId,
  }) async {
    final body = <String, dynamic>{
      'full_name': fullName,
      if (sex != null) 'sex': sex,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (familyAnamnesis != null) 'family_anamnesis': familyAnamnesis,
      if (chronicConditions != null) 'chronic_conditions': chronicConditions,
      if (userId != null) 'user_id': userId,
    };
    final r = await http.post(
      Uri.parse('$baseUrl/api/v1/medk/patients'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    final data = jsonDecode(r.body is String ? r.body : '{}') as Map<String, dynamic>? ?? {};
    if (r.statusCode >= 400) throw ApiException(r.statusCode, data['detail']?.toString() ?? r.body);
    return data;
  }

  /// POST /medk/patients/ensure — получить или создать пациента по user_id
  static Future<Map<String, dynamic>> medkEnsurePatient({required int userId, String fullName = 'Пациент'}) async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/v1/medk/patients/ensure?user_id=$userId&full_name=${Uri.encodeComponent(fullName)}'),
      headers: _headers(),
    );
    final data = jsonDecode(r.body is String ? r.body : '{}') as Map<String, dynamic>? ?? {};
    if (r.statusCode >= 400) throw ApiException(r.statusCode, data['detail']?.toString() ?? r.body);
    return data;
  }

  /// GET /medk/patients/{id}/active-reminders
  static Future<Map<String, dynamic>> medkGetPatientReminders(int patientId) async {
    final r = await http.get(
      Uri.parse('$baseUrl/api/v1/medk/patients/$patientId/active-reminders'),
      headers: _headers(),
    );
    final data = jsonDecode(r.body is String ? r.body : '{}') as Map<String, dynamic>? ?? {};
    if (r.statusCode >= 400) throw ApiException(r.statusCode, data['detail']?.toString() ?? r.body);
    return data;
  }

  /// PATCH /api/v1/medk/appointments/{id}/status
  static Future<Map<String, dynamic>> medkUpdateAppointmentStatus(int appointmentId, String status) async {
    final r = await http.patch(
      Uri.parse('$baseUrl/api/v1/medk/appointments/$appointmentId/status'),
      headers: _headers(),
      body: jsonEncode({'status': status}),
    );
    final data = jsonDecode(r.body is String ? r.body : '{}') as Map<String, dynamic>? ?? {};
    if (r.statusCode >= 400) throw ApiException(r.statusCode, data['detail']?.toString() ?? r.body);
    return data;
  }

  /// GET /api/v1/medk/patients/{id}/analyses
  static Future<List<dynamic>> medkListAnalyses(int patientId) async {
    final r = await http.get(
      Uri.parse('$baseUrl/api/v1/medk/patients/$patientId/analyses'),
      headers: _headers(),
    );
    if (r.statusCode >= 400) throw ApiException(r.statusCode, r.body);
    final data = jsonDecode(r.body is String ? r.body : '[]');
    return data is List ? data : [];
  }

  /// POST /api/v1/medk/patients/{id}/analyses
  static Future<Map<String, dynamic>> medkCreateAnalysis({
    required int patientId,
    required String name,
    String type = 'other',
    DateTime? analysisDate,
    Map<String, dynamic>? results,
    String? notes,
    int? appointmentId,
  }) async {
    final body = <String, dynamic>{
      'patient_id': patientId,
      'name': name,
      'type': type,
    };
    if (analysisDate != null) body['analysis_date'] = analysisDate.toIso8601String();
    if (results != null) body['results'] = results;
    if (notes != null) body['notes'] = notes;
    if (appointmentId != null) body['appointment_id'] = appointmentId;
    final r = await http.post(
      Uri.parse('$baseUrl/api/v1/medk/patients/$patientId/analyses'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    final data = jsonDecode(r.body is String ? r.body : '{}') as Map<String, dynamic>? ?? {};
    if (r.statusCode >= 400) throw ApiException(r.statusCode, data['detail']?.toString() ?? r.body);
    return data;
  }

  /// GET /api/v1/medk/patients/{id}/documents
  static Future<List<dynamic>> medkListDocuments(int patientId) async {
    final r = await http.get(
      Uri.parse('$baseUrl/api/v1/medk/patients/$patientId/documents'),
      headers: _headers(),
    );
    if (r.statusCode >= 400) throw ApiException(r.statusCode, r.body);
    final data = jsonDecode(r.body is String ? r.body : '[]');
    return data is List ? data : [];
  }

  /// POST /api/v1/medk/patients/{id}/documents (multipart PDF)
  static Future<Map<String, dynamic>> medkUploadDocument({
    required int patientId,
    required List<int> fileBytes,
    required String fileName,
    String title = 'Документ',
    String documentType = 'other',
    int? doctorId,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/medk/patients/$patientId/documents');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_headers(token: token));
    request.fields['title'] = title;
    request.fields['document_type'] = documentType;
    if (doctorId != null) request.fields['doctor_id'] = doctorId.toString();
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: fileName.endsWith('.pdf') ? fileName : '$fileName.pdf',
    ));
    final streamed = await request.send();
    final r = await http.Response.fromStream(streamed);
    final data = jsonDecode(r.body is String ? r.body : '{}') as Map<String, dynamic>? ?? {};
    if (r.statusCode >= 400) throw ApiException(r.statusCode, data['detail']?.toString() ?? r.body);
    return data;
  }

  /// URL для скачивания/просмотра документа
  static String medkDocumentFileUrl(int patientId, int documentId) =>
      '$baseUrl/api/v1/medk/patients/$patientId/documents/$documentId/file';

  /// POST /api/v1/medical/predict (для врача)
  static Future<Map<String, dynamic>> medicalPredict({
    required int age,
    required String gender,
    List<String> familyHistoryCodes = const [],
    String noteText = '',
  }) async {
    final body = {
      'age': age,
      'gender': gender,
      'family_history_codes': familyHistoryCodes,
      'note_text': noteText,
    };
    final r = await http.post(
      Uri.parse('$baseUrl/api/v1/medical/predict'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    final data = jsonDecode(r.body is String ? r.body : '{}') as Map<String, dynamic>? ?? {};
    if (r.statusCode >= 400) {
      throw ApiException(r.statusCode, data['detail']?.toString() ?? r.body);
    }
    return data;
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => message;
}
