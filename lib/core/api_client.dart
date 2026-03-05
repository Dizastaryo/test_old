import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  ApiClient({String? baseUrl}) : _baseUrl = baseUrl ?? 'http://10.0.2.2:8000';
  final String _baseUrl;
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> setToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = {'Content-Type': 'application/json', 'Accept': 'application/json'};
    if (withAuth) {
      final token = await _getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> get(String path, {bool auth = true}) async {
    return await http.get(Uri.parse('$_baseUrl$path'), headers: await _headers(withAuth: auth));
  }

  Future<http.Response> post(String path, Map<String, dynamic> body, {bool auth = true}) async {
    return await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(withAuth: auth),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> put(String path, Map<String, dynamic> body, {bool auth = true}) async {
    return await http.put(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(withAuth: auth),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String path, {bool auth = true}) async {
    return await http.delete(Uri.parse('$_baseUrl$path'), headers: await _headers(withAuth: auth));
  }
}
