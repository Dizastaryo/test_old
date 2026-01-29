import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/notification_model.dart';
import '../services/mock_data.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoggedIn = false;
  bool _isDarkMode = false;
  String _language = 'ru';
  bool _onboardingCompleted = false;
  List<AppNotification> _notifications = [];

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get onboardingCompleted => _onboardingCompleted;
  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  List<AppNotification> get notifications => _notifications;

  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  AppProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
    _isDarkMode = prefs.getBool(AppConstants.keyTheme) ?? false;
    _language = prefs.getString(AppConstants.keyLanguage) ?? 'ru';
    _onboardingCompleted = prefs.getBool(AppConstants.keyOnboardingCompleted) ?? false;

    if (_isLoggedIn) {
      final userJson = prefs.getString(AppConstants.keyUser);
      if (userJson != null) {
        // В реальном приложении здесь был бы парсинг JSON
        _currentUser = MockData.getCurrentUser();
      }
    }

    _notifications = MockData.getNotifications();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    // Моковая авторизация
    await Future.delayed(const Duration(seconds: 1));
    
    final user = MockData.getCurrentUser();
    _currentUser = user;
    _isLoggedIn = true;
    _notifications = MockData.getNotifications();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
    await prefs.setString(AppConstants.keyUser, user.toJson().toString());

    notifyListeners();
    return true;
  }

  Future<void> register(String name, String email, String password, String phone) async {
    // Моковая регистрация
    await Future.delayed(const Duration(seconds: 1));
    
    final user = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      age: 0,
      gender: '',
      createdAt: DateTime.now(),
    );
    
    _currentUser = user;
    _isLoggedIn = true;
    _notifications = MockData.getNotifications();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
    await prefs.setString(AppConstants.keyUser, user.toJson().toString());

    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;
    _notifications = [];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, false);
    await prefs.remove(AppConstants.keyUser);

    notifyListeners();
  }

  Future<void> updateUser(User updatedUser) async {
    _currentUser = updatedUser;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUser, updatedUser.toJson().toString());
    
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(AppConstants.keyTheme, _isDarkMode);
    });
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(AppConstants.keyLanguage, lang);
    });
    notifyListeners();
  }

  void markNotificationAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboardingCompleted = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingCompleted, true);
    notifyListeners();
  }
}
