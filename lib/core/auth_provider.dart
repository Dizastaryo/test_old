import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_client.dart';

class UserModel {
  final int id;
  final String? phone;
  final String? name;
  final String role;
  final String locale;
  final int bonusPoints;
  UserModel({
    required this.id,
    this.phone,
    this.name,
    required this.role,
    required this.locale,
    required this.bonusPoints,
  });
  factory UserModel.fromJson(Map<String, dynamic> j) {
    return UserModel(
      id: j['id'] as int,
      phone: j['phone'] as String?,
      name: j['name'] as String?,
      role: j['role'] as String? ?? 'client',
      locale: j['locale'] as String? ?? 'ru',
      bonusPoints: j['bonus_points'] as int? ?? 0,
    );
  }
}

class AuthProvider with ChangeNotifier {
  AuthProvider(this._api);

  final ApiClient _api;
  UserModel? _user;
  bool _loading = true;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get loading => _loading;

  Future<void> init() async {
    _loading = true;
    notifyListeners();
    try {
      final r = await _api.get('/users/me');
      if (r.statusCode == 200) {
        final j = jsonDecode(r.body) as Map<String, dynamic>;
        _user = UserModel.fromJson(j);
      } else {
        _user = null;
      }
    } catch (_) {
      _user = null;
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> sendOtp(String phone) async {
    final r = await _api.post('/auth/send-otp', {'phone': phone}, auth: false);
    return r.statusCode == 200;
  }

  Future<String?> verifyOtp(String phone, String code) async {
    final r = await _api.post('/auth/verify-otp', {'phone': phone, 'code': code}, auth: false);
    if (r.statusCode != 200) return null;
    try {
      final j = jsonDecode(r.body) as Map<String, dynamic>;
      final token = j['access_token'] as String?;
      if (token != null) await _api.setToken(token);
      return token;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    await _api.clearToken();
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? locale}) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (locale != null) body['locale'] = locale;
    final r = await _api.put('/users/me', body);
    if (r.statusCode == 200) await init();
  }

  String locale() => _user?.locale ?? 'ru';
}
