class AppConstants {
  // Цвета
  static const int primaryColorValue = 0xFF1976D2;
  static const int secondaryColorValue = 0xFF03DAC6;

  // Контакты клиники
  static const String clinicName = 'Qamqor Clinic';
  static const String clinicPhone = '+7 (727) 123-45-67';
  static const String clinicEmail = 'info@qamqorclinic.kz';
  static const String clinicAddress = 'г. Алматы, ул. Абая, д. 150';
  static const double clinicLatitude = 43.238949;
  static const double clinicLongitude = 76.889709;

  // Время работы
  static const String workingHours =
      'Пн-Пт: 9:00 - 18:00\nСб: 9:00 - 14:00\nВс: Выходной';

  // SharedPreferences keys
  static const String keyUser = 'user';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyAccessToken = 'access_token';
  static const String keyLanguage = 'language';
  static const String keyTheme = 'theme';
  static const String keyOnboardingCompleted = 'onboarding_completed';

  // API (бэкенд back_k).
  // Локальная сеть: сервер на 192.168.8.37:8000
  // Для Android-эмулятора: http://10.0.2.2:8000
  static const String apiBaseUrl = 'http://172.20.10.3:8000';
}
