// Моковый сервис авторизации
class AuthService {
  // Имитация авторизации - принимает любой email и пароль
  static Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    // Всегда возвращает true для моковой авторизации
    return email.isNotEmpty && password.isNotEmpty;
  }

  // Имитация регистрации
  static Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    // Всегда возвращает true для моковой регистрации
    return name.isNotEmpty && email.isNotEmpty && password.isNotEmpty;
  }

  // Имитация восстановления пароля
  static Future<bool> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    return email.isNotEmpty;
  }
}
