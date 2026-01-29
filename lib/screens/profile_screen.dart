import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/user.dart';
import '../theme/app_tokens.dart';
import '../widgets/hero_header.dart';
import '../widgets/app_buttons.dart';
import 'auth_screen.dart';
import 'notifications_screen.dart';
import 'contact_screen.dart';
import 'medical_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Выйти', style: TextStyle(color: AppTokens.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final user = appProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Пользователь не найден')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          HeroHeader(
            expandedHeight: 200,
            title: user.name,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: AppTokens.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: AppTokens.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTokens.lg),
                  child: Column(
                    children: [
                      _ProfileMenuItem(
                        icon: Icons.badge_rounded,
                        title: 'Личные данные',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(user: user),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _ProfileMenuItem(
                        icon: Icons.group_rounded,
                        title: 'Семья / дети',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Раздел в разработке')),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _ProfileMenuItem(
                        icon: Icons.folder_rounded,
                        title: 'История посещений',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MedicalHistoryScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _ProfileMenuItem(
                        icon: Icons.notifications_rounded,
                        title: 'Уведомления',
                        badge: appProvider.unreadNotificationsCount > 0
                            ? appProvider.unreadNotificationsCount
                            : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _ProfileMenuItem(
                        icon: Icons.settings_rounded,
                        title: 'Настройки',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _ProfileMenuItem(
                        icon: Icons.help_rounded,
                        title: 'Помощь',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Раздел в разработке')),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _ProfileMenuItem(
                        icon: Icons.call_rounded,
                        title: 'Контакты',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ContactScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTokens.lg),
                  child: AppDestructiveButton(
                    label: 'Выйти',
                    onPressed: () => _logout(context),
                  ),
                ),
                const SizedBox(height: AppTokens.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final int? badge;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null && badge! > 0)
            Container(
              margin: const EdgeInsets.only(right: AppTokens.sm),
              padding: const EdgeInsets.symmetric(horizontal: AppTokens.sm, vertical: AppTokens.xs),
              decoration: BoxDecoration(
                color: AppTokens.error,
                borderRadius: BorderRadius.circular(AppTokens.radiusChip),
              ),
              child: Text(
                badge.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.colorScheme.outline),
        ],
      ),
      onTap: onTap,
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _ageController = TextEditingController(text: widget.user.age.toString());
    _selectedGender = widget.user.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final updatedUser = widget.user.copyWith(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        age: int.tryParse(_ageController.text) ?? widget.user.age,
        gender: _selectedGender ?? widget.user.gender,
      );
      appProvider.updateUser(updatedUser);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Профиль обновлён'),
          backgroundColor: AppTokens.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Сохранить',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.lg),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Имя',
                  prefixIcon: Icon(Icons.badge_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите имя';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Телефон',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите телефон';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Возраст',
                  prefixIcon: Icon(Icons.cake),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите возраст';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Введите корректный возраст';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Пол',
                  prefixIcon: Icon(Icons.wc),
                ),
                items: ['Мужской', 'Женский'].map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Выберите пол';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        elevation: 0,
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Тёмная тема'),
                subtitle: const Text('Переключить на тёмную тему'),
                value: appProvider.isDarkMode,
                onChanged: (value) {
                  appProvider.toggleTheme();
                },
                secondary: const Icon(Icons.dark_mode_rounded),
              ),
              const Divider(),
              ListTile(
                title: const Text('Язык'),
                subtitle: Text(appProvider.language == 'ru' ? 'Русский' : 'Қазақша'),
                leading: const Icon(Icons.language_rounded),
                trailing: DropdownButton<String>(
                  value: appProvider.language,
                  items: const [
                    DropdownMenuItem(value: 'ru', child: Text('Русский')),
                    DropdownMenuItem(value: 'kk', child: Text('Қазақша')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      appProvider.setLanguage(value);
                    }
                  },
                ),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Уведомления о записях'),
                subtitle: const Text('Получать уведомления о предстоящих записях'),
                value: true,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Настройка сохранена')),
                  );
                },
                secondary: const Icon(Icons.notifications_active_rounded),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Email уведомления'),
                subtitle: const Text('Получать уведомления на email'),
                value: true,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Настройка сохранена')),
                  );
                },
                secondary: const Icon(Icons.email_rounded),
              ),
            ],
          );
        },
      ),
    );
  }
}
