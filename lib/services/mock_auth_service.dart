import 'dart:async';

/// Mock сервис авторизации - всегда успешно входит
class MockAuthService {
  // Заглушка для отправки OTP на email
  Future<void> sendEmailOtp(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Всегда успешно
  }

  // Заглушка для проверки OTP для email
  Future<void> verifyEmailOtp(String email, String otp) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Всегда успешно
  }

  // Заглушка для отправки OTP на телефон
  Future<void> sendSmsOtp(String phone) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Всегда успешно
  }

  // Заглушка для проверки OTP по телефону
  Future<void> verifySmsOtp(String phone, String otp) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Всегда успешно
  }

  // Заглушка для регистрации через email - возвращает mock данные
  Future<Map<String, dynamic>> registerWithEmail(
    String username,
    String email,
    String password,
    String otp,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      'accessToken': 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
      'username': username,
      'email': email,
      'roles': ['ROLE_USER'],
    };
  }

  // Заглушка для регистрации по телефону
  Future<Map<String, dynamic>> registerWithPhone(
    String username,
    String phone,
    String password,
    String otp,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      'accessToken': 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
      'username': username,
      'email': phone,
      'roles': ['ROLE_USER'],
    };
  }

  // Заглушка для входа - всегда успешно
  Future<Map<String, dynamic>> login(String login, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      'accessToken': 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
      'username': login,
      'email': login.contains('@') ? login : '$login@qamqor.clinic',
      'roles': ['ROLE_USER'],
    };
  }

  // Заглушка для обновления токена
  Future<Map<String, dynamic>> refreshToken() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'accessToken': 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
      'username': 'user',
      'email': 'user@qamqor.clinic',
      'roles': ['ROLE_USER'],
    };
  }

  // Заглушка для выхода
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Всегда успешно
  }

  // Заглушка для запроса сброса пароля
  Future<void> requestPasswordReset(String login) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Всегда успешно
  }

  // Заглушка для подтверждения сброса пароля
  Future<void> confirmPasswordReset(
    String login,
    String otp,
    String newPassword,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Всегда успешно
  }
}
