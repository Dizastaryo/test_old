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

  /// POST /api/v1/auth/register
  static Future<Map<String, dynamic>> register({
    String? email,
    String? phone,
    required String password,
    String role = 'patient',
  }) async {
    final body = <String, dynamic>{
      'password': password,
      'role': role,
    };
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;

    final r = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/register'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    final data = jsonDecode(r.body is String ? r.body : '{}') as Map<String, dynamic>? ?? {};
    if (r.statusCode >= 400) {
      throw ApiException(r.statusCode, data['detail']?.toString() ?? r.body);
    }
    return data;
  }

  /// POST /api/v1/auth/login (email ИЛИ phone)
  static Future<Map<String, dynamic>> login({
    String? email,
    String? phone,
    required String password,
  }) async {
    final body = <String, dynamic>{'password': password};
    if (email != null && email.isNotEmpty) {
      body['email'] = email;
    } else if (phone != null && phone.isNotEmpty) {
      body['phone'] = phone;
    } else {
      throw ApiException(400, 'Укажите email или телефон');
    }

    final r = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/login'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    final data = jsonDecode(r.body is String ? r.body : '{}') as Map<String, dynamic>? ?? {};
    if (r.statusCode >= 400) {
      throw ApiException(r.statusCode, data['detail']?.toString() ?? r.body);
    }
    return data;
  }

  /// POST /api/v1/auth/forgot-password
  static Future<void> forgotPassword({String? email, String? phone}) async {
    final body = <String, dynamic>{};
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    if (body.isEmpty) throw ApiException(400, 'Укажите email или телефон');

    final r = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/forgot-password'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    if (r.statusCode >= 400) {
      final data = jsonDecode(r.body is String ? r.body : '{}') as Map<String, dynamic>? ?? {};
      throw ApiException(r.statusCode, data['detail']?.toString() ?? r.body);
    }
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
