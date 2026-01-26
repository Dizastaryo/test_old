import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'my_orders_screen.dart';

/// Современная страница профиля
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    final username = currentUser != null ? currentUser['username'] : 'Пользователь';
    final email = currentUser != null ? currentUser['email'] : 'user@qamqor.clinic';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar с градиентом
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF2E7D32),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2E7D32),
                      const Color(0xFF4CAF50),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Text(
                          username.isNotEmpty ? username[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Контент
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Мои записи
                  _ProfileCard(
                    icon: Icons.event_note,
                    title: 'Мои записи',
                    subtitle: 'Просмотр записей на прием',
                    color: const Color(0xFF2E7D32),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyOrdersScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Уведомления
                  _ProfileCard(
                    icon: Icons.notifications,
                    title: 'Уведомления',
                    subtitle: 'Настройки уведомлений',
                    color: const Color(0xFF4CAF50),
                    onTap: () {
                      // TODO: Настройки уведомлений
                    },
                  ),
                  const SizedBox(height: 12),

                  // Политика конфиденциальности
                  _ProfileCard(
                    icon: Icons.privacy_tip,
                    title: 'Политика конфиденциальности',
                    subtitle: 'Как мы защищаем ваши данные',
                    color: const Color(0xFF66BB6A),
                    onTap: () {
                      _showPrivacyDialog(context);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Пользовательское соглашение
                  _ProfileCard(
                    icon: Icons.gavel,
                    title: 'Пользовательское соглашение',
                    subtitle: 'Условия использования',
                    color: const Color(0xFF81C784),
                    onTap: () {
                      _showTermsDialog(context);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Поддержка
                  _ProfileCard(
                    icon: Icons.support_agent,
                    title: 'Поддержка',
                    subtitle: 'Связаться с нами',
                    color: const Color(0xFF2E7D32),
                    onTap: () {
                      _showSupportDialog(context);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Кнопка выхода
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Выход'),
                            content: const Text('Вы уверены, что хотите выйти?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Отмена'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Выйти'),
                              ),
                            ],
                          ),
                        );

                        if (shouldLogout == true) {
                          await authProvider.logout(context);
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, '/auth');
                          }
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'Выйти из аккаунта',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Политика конфиденциальности'),
        content: const SingleChildScrollView(
          child: Text(
            'Мы серьезно относимся к защите ваших персональных данных. '
            'Вся информация хранится в зашифрованном виде и используется '
            'только для предоставления медицинских услуг.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Пользовательское соглашение'),
        content: const SingleChildScrollView(
          child: Text(
            'Используя приложение Qamqor Clinic, вы соглашаетесь с условиями '
            'использования. Приложение предоставляется "как есть" для удобства '
            'записи на прием и получения медицинских услуг.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Поддержка'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Свяжитесь с нами:'),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone, size: 20),
                SizedBox(width: 8),
                Text('+7 (XXX) XXX-XX-XX'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.email, size: 20),
                SizedBox(width: 8),
                Text('support@qamqor.clinic'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 20),
                SizedBox(width: 8),
                Text('Пн-Пт: 9:00 - 18:00'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
