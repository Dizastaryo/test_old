import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/promotion.dart';
import '../models/notification_model.dart';

/// Локализация: загрузка ru.json / kaz.json по языку, строки интерфейса и данные (акции, уведомления).
class LangService {
  static String _currentLang = 'ru';
  static Map<String, dynamic>? _cached;

  static String _assetPath(String lang) =>
      'assets/lang/${lang == 'kk' ? 'kaz' : 'ru'}.json';

  /// Загрузить локаль (ru или kk). Вызывать при старте и при смене языка.
  static Future<void> loadLocale(String lang) async {
    _currentLang = lang;
    _cached = null;
    try {
      final str = await rootBundle.loadString(_assetPath(lang));
      _cached = jsonDecode(str) as Map<String, dynamic>? ?? {};
    } catch (_) {
      _cached = {};
    }
  }

  static Future<Map<String, dynamic>> _loadJson() async {
    if (_cached != null) return _cached!;
    await loadLocale(_currentLang);
    return _cached!;
  }

  /// Строка интерфейса по ключу (например 'nav_home', 'home_welcome').
  static String getString(String key) {
    final ui = _cached?['ui'];
    if (ui is! Map) return key;
    final v = ui[key];
    if (v == null) return key;
    return v.toString();
  }

  /// Акции из текущей локали. Даты от текущего момента по startOffsetDays / endOffsetDays.
  static Future<List<Promotion>> getPromotions() async {
    final data = await _loadJson();
    final list = data['promotions'];
    if (list == null || list is! List) return [];
    final now = DateTime.now();
    return list.map((e) {
      final map = e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map);
      final startOffset = (map['startOffsetDays'] as num?)?.toInt() ?? 0;
      final endOffset = (map['endOffsetDays'] as num?)?.toInt() ?? 30;
      return Promotion(
        id: (map['id'] ?? '').toString(),
        title: (map['title'] ?? '').toString(),
        description: (map['description'] ?? '').toString(),
        imageUrl: map['imageUrl']?.toString(),
        startDate: now.add(Duration(days: startOffset)),
        endDate: now.add(Duration(days: endOffset)),
        discount: (map['discount'] as num?)?.toDouble(),
      );
    }).toList();
  }

  /// Уведомления из текущей локали. createdAt = now - hoursAgo.
  static Future<List<AppNotification>> getNotifications() async {
    final data = await _loadJson();
    final list = data['notifications'];
    if (list == null || list is! List) return [];
    final now = DateTime.now();
    return list.map((e) {
      final map = e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map);
      final hoursAgo = (map['hoursAgo'] as num?)?.toInt() ?? 0;
      return AppNotification(
        id: (map['id'] ?? '').toString(),
        title: (map['title'] ?? '').toString(),
        message: (map['message'] ?? '').toString(),
        type: (map['type'] ?? 'general').toString(),
        createdAt: now.subtract(Duration(hours: hoursAgo)),
        isRead: map['isRead'] == true,
      );
    }).toList();
  }

  static void clearCache() {
    _cached = null;
  }
}
