import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import '../../data/mock_service.dart';

class NotificationState {
  final List<AppNotification> notifications;
  final bool isLoading;
  final int unreadCount;
  final String? error;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.unreadCount = 0,
    this.error,
  });

  NotificationState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    int? unreadCount,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      unreadCount: unreadCount ?? this.unreadCount,
      error: error,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(const NotificationState()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final notifications = await MockService.instance.getNotifications();
      final unread = notifications.where((n) => !n.isRead).length;
      state = NotificationState(
        notifications: notifications,
        unreadCount: unread,
      );
    } catch (e) {
      final demos = AppNotification.demoNotifications;
      state = NotificationState(
        notifications: demos,
        unreadCount: demos.where((n) => !n.isRead).length,
        error: e.toString(),
      );
    }
  }

  Future<void> markAllRead() async {
    final updated = state.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    state = state.copyWith(notifications: updated, unreadCount: 0);
    await MockService.instance.markAllNotificationsRead();
  }

  Future<void> markRead(String id) async {
    final updated = state.notifications.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();
    final unread = updated.where((n) => !n.isRead).length;
    state = state.copyWith(notifications: updated, unreadCount: unread);
    await MockService.instance.markNotificationRead(id);
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});
