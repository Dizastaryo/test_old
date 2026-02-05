import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/user.dart';
import '../services/lang_service.dart';
import '../theme/app_tokens.dart';

import '../widgets/hero_header.dart';
import '../widgets/app_buttons.dart';
import 'auth_screen.dart';
import 'notifications_screen.dart';
import 'contact_screen.dart';
import 'medical_history_screen.dart';
import 'doctor_profile_edit_screen.dart';

String _t(String key) => LangService.getString(key);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_t('profile_logout')),
        content: Text(_t('profile_logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_t('profile_cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(_t('profile_logout_btn'), style: const TextStyle(color: AppTokens.error)),
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
      return Scaffold(
        body: Center(child: Text(_t('profile_user_not_found'))),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          HeroHeader(
            expandedHeight: 200,
            title: '',
            centerTitle: true,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      user.name,
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
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
                        title: _t('profile_personal_data'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(user: user),
                            ),
                          );
                        },
                      ),
                      if (user.isDoctor) ...[
                        const Divider(height: 1),
                        _ProfileMenuItem(
                          icon: Icons.medical_services_rounded,
                          title: _t('profile_doctor_card'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DoctorProfileEditScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                      const Divider(height: 1),
                      _ProfileMenuItem(
                        icon: Icons.folder_rounded,
                        title: _t('profile_visit_history'),
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
                        title: _t('profile_notifications'),
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
                        title: _t('profile_settings'),
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
                        title: _t('profile_help'),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_t('profile_help_dev'))),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _ProfileMenuItem(
                        icon: Icons.call_rounded,
                        title: _t('profile_contacts'),
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
                    label: _t('profile_logout_btn_main'),
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
          content: Text(_t('profile_updated')),
          backgroundColor: AppTokens.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('profile_edit_title')),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              _t('profile_save'),
              style: const TextStyle(color: Colors.white),
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
                decoration: InputDecoration(
                  labelText: _t('profile_label_name'),
                  prefixIcon: Icon(Icons.badge_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _t('profile_validate_name');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: _t('profile_label_email'),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _t('profile_validate_email');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: _t('profile_label_phone'),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _t('profile_validate_phone');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _t('profile_label_age'),
                  prefixIcon: Icon(Icons.cake),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _t('profile_validate_age');
                  }
                  if (int.tryParse(value) == null) {
                    return _t('profile_validate_age_invalid');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  labelText: _t('profile_label_gender'),
                  prefixIcon: Icon(Icons.wc),
                ),
                items: [
                  DropdownMenuItem(value: 'Мужской', child: Text(_t('profile_gender_male'))),
                  DropdownMenuItem(value: 'Женский', child: Text(_t('profile_gender_female'))),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _t('profile_validate_gender');
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
        title: Text(_t('settings_title')),
        elevation: 0,
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return ListView(
            children: [
              SwitchListTile(
                title: Text(_t('settings_dark_theme')),
                subtitle: Text(_t('settings_dark_theme_sub')),
                value: appProvider.isDarkMode,
                onChanged: (value) {
                  appProvider.toggleTheme();
                },
                secondary: const Icon(Icons.dark_mode_rounded),
              ),
              const Divider(),
              ListTile(
                title: Text(_t('settings_language')),
                subtitle: Text(appProvider.language == 'ru' ? _t('settings_lang_ru') : _t('settings_lang_kk')),
                leading: const Icon(Icons.language_rounded),
                trailing: DropdownButton<String>(
                  value: appProvider.language,
                  items: [
                    DropdownMenuItem(value: 'ru', child: Text(_t('settings_lang_ru'))),
                    DropdownMenuItem(value: 'kk', child: Text(_t('settings_lang_kk'))),
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
                title: Text(_t('settings_notif_appointments')),
                subtitle: Text(_t('settings_notif_appointments_sub')),
                value: true,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_t('settings_saved'))),
                  );
                },
                secondary: const Icon(Icons.notifications_active_rounded),
              ),
              const Divider(),
              SwitchListTile(
                title: Text(_t('settings_email_notif')),
                subtitle: Text(_t('settings_email_notif_sub')),
                value: true,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_t('settings_saved'))),
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
