import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/mock_auth_service.dart';

class AuthProvider with ChangeNotifier {
  final MockAuthService _authService = MockAuthService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isLoading = false;
  dynamic currentUser;
  String? _token;

  static const _kRefreshToken = 'refreshToken';
  static const _kIsLoggedIn = 'isLoggedIn';

  AuthProvider() {
    // Автоматически входим при инициализации
    _autoLogin();
  }

  bool get isLoading => _isLoading;
  String? get token => _token;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Автоматический вход - заглушка
  Future<void> _autoLogin() async {
    final isLoggedIn = await _secureStorage.read(key: _kIsLoggedIn);
    if (isLoggedIn == 'true') {
      // Если уже был вход, восстанавливаем пользователя
      await silentAutoLogin();
    } else {
      // Иначе создаем mock пользователя
      _token = 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}';
      currentUser = {
        'username': 'Пользователь',
        'email': 'user@qamqor.clinic',
        'roles': ['ROLE_USER'],
      };
      await _secureStorage.write(key: _kIsLoggedIn, value: 'true');
      notifyListeners();
    }
  }

  Future<String?> _loadRefreshToken() async {
    return await _secureStorage.read(key: _kRefreshToken);
  }

  Future<String?> loadRefreshTokenForDebug() async {
    return await _loadRefreshToken();
  }

  Future<void> _clearRefreshToken() async {
    await _secureStorage.delete(key: _kRefreshToken);
    await _secureStorage.delete(key: _kIsLoggedIn);
  }

  // Упрощенный вход - всегда успешно
  Future<void> login(String login, String password,
      [BuildContext? context]) async {
    try {
      _setLoading(true);
      // Используем mock сервис - всегда успешно
      final response = await _authService.login(login, password);
      _token = response['accessToken'];
      currentUser = {
        'username': response['username'],
        'email': response['email'],
        'roles': response['roles'],
      };
      await _secureStorage.write(key: _kIsLoggedIn, value: 'true');
      await _secureStorage.write(key: _kRefreshToken, value: _token!);
      notifyListeners();

      if (context != null) {
        final roles = List<String>.from(response['roles']);
        _navigateBasedOnRole(context, roles);
      }
    } catch (e) {
      throw Exception('Login error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> silentAutoLogin() async {
    final stored = await _loadRefreshToken();
    if (stored == null) {
      // Если нет токена, создаем нового пользователя
      _token = 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}';
      currentUser = {
        'username': 'Пользователь',
        'email': 'user@qamqor.clinic',
        'roles': ['ROLE_USER'],
      };
      await _secureStorage.write(key: _kIsLoggedIn, value: 'true');
      await _secureStorage.write(key: _kRefreshToken, value: _token!);
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final response = await _authService.refreshToken();
      _token = response['accessToken'];
      currentUser = {
        'username': response['username'],
        'email': response['email'],
        'roles': response['roles'],
      };
      await _secureStorage.write(key: _kRefreshToken, value: _token!);
      notifyListeners();
    } catch (e) {
      debugPrint('silentAutoLogin error: $e');
      // В случае ошибки все равно создаем пользователя
      _token = stored;
      currentUser = {
        'username': 'Пользователь',
        'email': 'user@qamqor.clinic',
        'roles': ['ROLE_USER'],
      };
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> tryRefreshToken() async {
    try {
      await silentAutoLogin();
      return true;
    } catch (_) {
      // Всегда возвращаем true для mock
      return true;
    }
  }

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
      // Все равно очищаем
      await _clearRefreshToken();
      _token = null;
      currentUser = null;
      notifyListeners();
      Navigator.pushReplacementNamed(context, '/auth');
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
      _token = response['accessToken'];
      currentUser = {
        'username': response['username'],
        'email': response['email'],
        'roles': response['roles'],
      };
      await _secureStorage.write(key: _kRefreshToken, value: _token!);
      notifyListeners();
    } catch (e) {
      debugPrint('refreshToken error: $e');
      // Все равно обновляем токен
      _token = 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}';
      notifyListeners();
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
      _token = response['accessToken'];
      currentUser = {
        'username': response['username'],
        'email': response['email'],
        'roles': response['roles'],
      };
      await _secureStorage.write(key: _kIsLoggedIn, value: 'true');
      await _secureStorage.write(key: _kRefreshToken, value: _token!);
      notifyListeners();

      if (context != null) {
        final roles = List<String>.from(response['roles']);
        _navigateBasedOnRole(context, roles);
      }
    } catch (e) {
      throw Exception('registerWithEmail error: $e');
    } finally {
      _setLoading(false);
    }
  }

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
      _token = response['accessToken'];
      currentUser = {
        'username': response['username'],
        'email': response['email'],
        'roles': response['roles'],
      };
      await _secureStorage.write(key: _kIsLoggedIn, value: 'true');
      await _secureStorage.write(key: _kRefreshToken, value: _token!);
      notifyListeners();

      if (context != null) {
        final roles = List<String>.from(response['roles']);
        _navigateBasedOnRole(context, roles);
      }
    } catch (e) {
      throw Exception('registerWithPhone error: $e');
    } finally {
      _setLoading(false);
    }
  }
}
