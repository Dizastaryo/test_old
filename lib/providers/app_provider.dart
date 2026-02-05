import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/notification_model.dart';
import '../services/mock_data.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider with ChangeNotifier {
  User? _currentUser;
  String? _accessToken;
  bool _isLoggedIn = false;
  bool _initialLoadDone = false;
  bool _isDarkMode = false;
  String _language = 'ru';
  bool _onboardingCompleted = false;
  List<AppNotification> _notifications = [];

  User? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  bool get isLoggedIn => _isLoggedIn;
  bool get initialLoadDone => _initialLoadDone;
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
    _accessToken = prefs.getString(AppConstants.keyAccessToken);
    _isDarkMode = prefs.getBool(AppConstants.keyTheme) ?? false;
    _language = prefs.getString(AppConstants.keyLanguage) ?? 'ru';
    _onboardingCompleted = prefs.getBool(AppConstants.keyOnboardingCompleted) ?? false;

    if (_accessToken != null && _accessToken!.isNotEmpty) {
      try {
        final user = await ApiService.me(_accessToken!);
        _currentUser = user;
        _isLoggedIn = true;
        await prefs.setString(AppConstants.keyUser, jsonEncode(user.toJson()));
      } catch (_) {
        _accessToken = null;
        _currentUser = null;
        _isLoggedIn = false;
        await prefs.remove(AppConstants.keyAccessToken);
        await prefs.remove(AppConstants.keyUser);
      }
    }

    _notifications = MockData.getNotifications();
    _initialLoadDone = true;
    notifyListeners();
  }

  /// Сохранить сессию после успешного входа по OTP (verify-otp).
  Future<void> setSession(String token, User user) async {
    _accessToken = token;
    _currentUser = user;
    _isLoggedIn = true;
    _notifications = MockData.getNotifications();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
    await prefs.setString(AppConstants.keyAccessToken, token);
    await prefs.setString(AppConstants.keyUser, jsonEncode(user.toJson()));
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _accessToken = null;
    _isLoggedIn = false;
    _notifications = [];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, false);
    await prefs.remove(AppConstants.keyAccessToken);
    await prefs.remove(AppConstants.keyUser);

    notifyListeners();
  }

  Future<void> updateUser(User updatedUser) async {
    _currentUser = updatedUser;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUser, jsonEncode(updatedUser.toJson()));
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
