import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/notification_model.dart';
import '../theme/app_tokens.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final notifications = appProvider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
        elevation: 0,
        actions: [
          if (appProvider.unreadNotificationsCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all_rounded),
              tooltip: 'Отметить все как прочитанные',
              onPressed: () {
                appProvider.markAllNotificationsAsRead();
              },
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text('Уведомлений нет'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppTokens.lg),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationCard(notification: notification);
              },
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    final theme = Theme.of(context);
    final typeIcons = {
      'appointment': Icons.event_rounded,
      'analysis': Icons.science_rounded,
      'promotion': Icons.local_offer_rounded,
      'general': Icons.notifications_rounded,
    };
    final typeColors = {
      'appointment': theme.colorScheme.primary,
      'analysis': theme.colorScheme.secondary,
      'promotion': AppTokens.warning,
      'general': theme.colorScheme.outline,
    };

    final icon = typeIcons[notification.type] ?? Icons.notifications_rounded;
    final color = typeColors[notification.type] ?? theme.colorScheme.outline;

    return Card(
      margin: const EdgeInsets.only(bottom: AppTokens.md),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      ),
      color: notification.isRead
          ? theme.colorScheme.surface
          : theme.colorScheme.primaryContainer.withOpacity(0.3),
      child: InkWell(
        onTap: () {
          final provider = Provider.of<AppProvider>(context, listen: false);
          provider.markNotificationAsRead(notification.id);
        },
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!notification.isRead)
                Container(
                  width: 4,
                  height: 56,
                  margin: const EdgeInsets.only(right: AppTokens.sm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(AppTokens.sm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTokens.radiusInput),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: AppTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTokens.xs),
                    Text(
                      notification.message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppTokens.sm),
                    Text(
                      dateFormat.format(notification.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
