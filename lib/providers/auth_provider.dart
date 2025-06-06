import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final Dio _dio;
  final CookieJar _cookieJar;
  final AuthService _authService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isLoading = false;
  dynamic currentUser;
  String? _token;

  final Uri _baseUri = Uri.parse(dotenv.env['AUTH_BASE_URL']!);
  static const _kRefreshToken = 'refreshToken';

  AuthProvider(this._dio, this._cookieJar) : _authService = AuthService(_dio) {}

  bool get isLoading => _isLoading;
  String? get token => _token;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _saveRefreshToken() async {
    final cookies = await _cookieJar.loadForRequest(_baseUri);
    final cookie = cookies.firstWhere(
      (c) => c.name == 'refreshToken',
      orElse: () => Cookie('', ''),
    );
    if (cookie.value.isNotEmpty) {
      await _secureStorage.write(key: _kRefreshToken, value: cookie.value);
    }
  }

  Future<String?> _loadRefreshToken() async {
    return await _secureStorage.read(key: _kRefreshToken);
  }

  /// Метод для отладки: возвращает текущее значение refreshToken
  Future<String?> loadRefreshTokenForDebug() async {
    return await _loadRefreshToken();
  }

  Future<void> _clearRefreshToken() async {
    await _secureStorage.delete(key: _kRefreshToken);
    await _cookieJar.deleteAll();
  }

  Future<void> login(String login, String password,
      [BuildContext? context]) async {
    try {
      _setLoading(true);
      final response = await _authService.login(login, password);
      if (response.statusCode == 200) {
        _token = response.data['accessToken'];
        currentUser = {
          'username': response.data['username'],
          'email': response.data['email'],
          'roles': response.data['roles'],
        };
        await _saveRefreshToken();
        notifyListeners();

        if (context != null) {
          final roles = List<String>.from(response.data['roles']);
          _navigateBasedOnRole(context, roles);
        }
      }
    } catch (e) {
      throw Exception('Login error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> silentAutoLogin() async {
    final stored = await _loadRefreshToken();
    if (stored == null) throw Exception('No stored refreshToken');

    _setLoading(true);
    try {
      // Удаляем все куки (в т.ч. старый refreshToken)
      await _cookieJar.deleteAll();

      // Сохраняем единственную куку из secure storage
      await _cookieJar.saveFromResponse(
        _baseUri,
        [Cookie(_kRefreshToken, stored)],
      );

      final response = await _authService.refreshToken();
      if (response.statusCode == 200) {
        _token = response.data['accessToken'];
        currentUser = {
          'username': response.data['username'],
          'email': response.data['email'],
          'roles': response.data['roles'],
        };
        await _saveRefreshToken();
        notifyListeners();
      } else {
        throw Exception('Не удалось обновить токен: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('silentAutoLogin error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> tryRefreshToken() async {
    try {
      await silentAutoLogin();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// В AuthProvider
  Future<void> logout(BuildContext context) async {
    _setLoading(true);
    try {
      await _authService.logout();
      await _clearRefreshToken();
      _token = null;
      currentUser = null;
      notifyListeners();
      Navigator.pushReplacementNamed(context, '/auth');
    } catch (e) {
      debugPrint('Logout error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _navigateBasedOnRole(BuildContext context, List<String> roles) {
    final route = roles.contains('ROLE_ADMIN')
        ? '/admin-home'
        : roles.contains('ROLE_MODERATOR')
            ? '/moderator-home'
            : '/main';
    Navigator.pushReplacementNamed(context, route);
  }

  Future<void> refreshToken() async {
    try {
      _setLoading(true);
      final response = await _authService.refreshToken();
      if (response.statusCode == 200) {
        _token = response.data['accessToken'];
        currentUser = {
          'username': response.data['username'],
          'email': response.data['email'],
          'roles': response.data['roles'],
        };
        await _saveRefreshToken();
        notifyListeners();
      } else {
        throw Exception('Не удалось обновить токен: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('refreshToken error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  List<String> get userRoles {
    final roles = currentUser != null && currentUser['roles'] is List
        ? List<String>.from(currentUser['roles'])
        : <String>[];
    return roles;
  }

  /// Вычисляет, куда навигировать по ролям
  String routeForCurrentUser() {
    final roles = userRoles;
    if (roles.contains('ROLE_ADMIN')) return '/admin-home';
    if (roles.contains('ROLE_MODERATOR')) return '/moderator-home';
    return '/main';
  }

  Future<void> requestPasswordReset(String login) =>
      _authService.requestPasswordReset(login);

  Future<void> confirmPasswordReset(
          String login, String otp, String newPassword) =>
      _authService.confirmPasswordReset(login, otp, newPassword);

  Future<void> sendEmailOtp(String email) => _authService.sendEmailOtp(email);

  Future<void> verifyEmailOtp(String email, String otp) =>
      _authService.verifyEmailOtp(email, otp);

  Future<void> sendSmsOtp(String phone) => _authService.sendSmsOtp(phone);

  Future<void> verifySmsOtp(String phone, String otp) =>
      _authService.verifySmsOtp(phone, otp);

  /// Registers via email, then treats the response exactly like login.
  Future<void> registerWithEmail(
    String username,
    String email,
    String password,
    String otp, [
    BuildContext? context,
  ]) async {
    try {
      _setLoading(true);
      final response =
          await _authService.registerWithEmail(username, email, password, otp);
      if (response.statusCode == 200) {
        _token = response.data['accessToken'];
        currentUser = {
          'username': response.data['username'],
          'email': response.data['email'],
          'roles': response.data['roles'],
        };
        await _saveRefreshToken();
        notifyListeners();

        if (context != null) {
          final roles = List<String>.from(response.data['roles']);
          _navigateBasedOnRole(context, roles);
        }
      } else {
        throw Exception('Registration error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('registerWithEmail error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Registers via phone, then treats the response exactly like login.
  Future<void> registerWithPhone(
    String username,
    String phone,
    String password,
    String otp, [
    BuildContext? context,
  ]) async {
    try {
      _setLoading(true);
      final response =
          await _authService.registerWithPhone(username, phone, password, otp);
      if (response.statusCode == 200) {
        _token = response.data['accessToken'];
        currentUser = {
          'username': response.data['username'],
          'email': response.data['email'], // if available
          'roles': response.data['roles'],
        };
        await _saveRefreshToken();
        notifyListeners();

        if (context != null) {
          final roles = List<String>.from(response.data['roles']);
          _navigateBasedOnRole(context, roles);
        }
      } else {
        throw Exception('Registration error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('registerWithPhone error: $e');
    } finally {
      _setLoading(false);
    }
  }
}
