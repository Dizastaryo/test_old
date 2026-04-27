import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/design/design.dart';
import '../../core/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: SeeUColors.background,
      appBar: AppBar(
        backgroundColor: SeeUColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Настройки', style: SeeUTypography.subtitle),
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft(), size: 22, color: SeeUColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildSection('Аккаунт', [
            _SettingsTile(
              icon: PhosphorIcons.user(PhosphorIconsStyle.fill),
              title: 'Редактировать профиль',
              onTap: () => context.push('/profile/edit'),
            ),
            _SettingsTile(
              icon: PhosphorIcons.lock(PhosphorIconsStyle.fill),
              title: 'Конфиденциальность',
              subtitle: 'Приватный аккаунт, блокировки',
              onTap: () => _showComingSoon(context),
            ),
            _SettingsTile(
              icon: PhosphorIcons.bell(PhosphorIconsStyle.fill),
              title: 'Уведомления',
              subtitle: 'Push, звуки, вибрация',
              onTap: () => _showComingSoon(context),
            ),
          ]),
          const SizedBox(height: 16),
          _buildSection('Приложение', [
            _SettingsTile(
              icon: PhosphorIcons.palette(PhosphorIconsStyle.fill),
              title: 'Тема',
              subtitle: 'Светлая',
              onTap: () => _showThemeSheet(context),
            ),
            _SettingsTile(
              icon: PhosphorIcons.globe(PhosphorIconsStyle.fill),
              title: 'Язык',
              subtitle: 'Русский',
              onTap: () => _showComingSoon(context),
            ),
            _SettingsTile(
              icon: PhosphorIcons.database(PhosphorIconsStyle.fill),
              title: 'Хранилище и данные',
              subtitle: 'Кэш, загрузки',
              onTap: () => _showComingSoon(context),
            ),
          ]),
          const SizedBox(height: 16),
          _buildSection('Информация', [
            _SettingsTile(
              icon: PhosphorIcons.info(PhosphorIconsStyle.fill),
              title: 'О приложении',
              subtitle: 'SeeU v1.0.0',
              onTap: () => _showAbout(context),
            ),
            _SettingsTile(
              icon: PhosphorIcons.questionMark(PhosphorIconsStyle.fill),
              title: 'Помощь и поддержка',
              onTap: () => _showComingSoon(context),
            ),
          ]),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SeeUButton(
              label: 'Выйти из аккаунта',
              variant: SeeUButtonVariant.secondary,
              icon: PhosphorIcons.signOut(),
              onTap: () {
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: SeeUTypography.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: SeeUColors.textTertiary,
            fontSize: 12,
          )),
        ),
        Container(
          decoration: BoxDecoration(
            color: SeeUColors.surfaceElevated,
            borderRadius: BorderRadius.circular(SeeURadii.card),
            boxShadow: SeeUShadows.sm,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Скоро будет доступно')),
    );
  }

  void _showThemeSheet(BuildContext context) {
    showSeeUBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Тема', style: SeeUTypography.title),
            ),
            _ThemeOption(
              label: 'Светлая',
              icon: PhosphorIcons.sun(PhosphorIconsStyle.fill),
              isSelected: true,
              onTap: () => Navigator.pop(context),
            ),
            _ThemeOption(
              label: 'Тёмная',
              icon: PhosphorIcons.moon(PhosphorIconsStyle.fill),
              isSelected: false,
              onTap: () => Navigator.pop(context),
            ),
            _ThemeOption(
              label: 'Системная',
              icon: PhosphorIcons.deviceMobile(PhosphorIconsStyle.fill),
              isSelected: false,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showSeeUBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('SeeU', style: SeeUTypography.displayL),
              const SizedBox(height: 8),
              Text(
                'Социальная сеть с BLE-сканером',
                style: SeeUTypography.body.copyWith(color: SeeUColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                'Версия 1.0.0',
                style: SeeUTypography.caption,
              ),
              const SizedBox(height: 24),
              Text(
                'Находите людей рядом, делитесь моментами, общайтесь.',
                style: SeeUTypography.body.copyWith(color: SeeUColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SeeUButton(
                label: 'Закрыть',
                variant: SeeUButtonVariant.secondary,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable.faded(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: SeeUColors.accentSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: SeeUColors.accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: SeeUTypography.body.copyWith(fontWeight: FontWeight.w500)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: SeeUTypography.caption),
                  ],
                ],
              ),
            ),
            Icon(PhosphorIcons.caretRight(), size: 18, color: SeeUColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 22, color: isSelected ? SeeUColors.accent : SeeUColors.textSecondary),
      title: Text(label, style: SeeUTypography.body.copyWith(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? SeeUColors.accent : SeeUColors.textPrimary,
      )),
      trailing: isSelected
          ? Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
              color: SeeUColors.accent, size: 22)
          : null,
      onTap: onTap,
    );
  }
}
