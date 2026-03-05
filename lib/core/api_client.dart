import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const _kTokenKey = 'jwt_token';

class ApiClient {
  ApiClient({String? baseUrl}) : _baseUrl = baseUrl ?? 'http://10.0.2.2:8000';
  final String _baseUrl;

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  Future<String?> _getToken() async {
    return (await _prefs).getString(_kTokenKey);
  }

  Future<void> setToken(String token) async {
    await (await _prefs).setString(_kTokenKey, token);
  }

  Future<void> clearToken() async {
    await (await _prefs).remove(_kTokenKey);
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
