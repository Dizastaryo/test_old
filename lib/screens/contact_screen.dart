import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import '../theme/app_tokens.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $email';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Контакты'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Карта (моковая)
            Container(
              height: 250,
              width: double.infinity,
              color: theme.brightness == Brightness.dark ? AppTokens.surface2Dark : AppTokens.surface2,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_rounded,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: AppTokens.sm),
                    Text(
                      'Карта',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppTokens.xs),
                    Text(
                      '${AppConstants.clinicLatitude}, ${AppConstants.clinicLongitude}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTokens.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Контактная информация',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTokens.xl),
                  _ContactItem(
                    icon: Icons.call_rounded,
                    title: 'Телефон',
                    value: AppConstants.clinicPhone,
                    onTap: () => _makePhoneCall(AppConstants.clinicPhone),
                    actionText: 'Позвонить',
                  ),
                  const SizedBox(height: AppTokens.lg),
                  _ContactItem(
                    icon: Icons.email_rounded,
                    title: 'Email',
                    value: AppConstants.clinicEmail,
                    onTap: () => _sendEmail(AppConstants.clinicEmail),
                    actionText: 'Написать',
                  ),
                  const SizedBox(height: AppTokens.lg),
                  _ContactItem(
                    icon: Icons.location_on_rounded,
                    title: 'Адрес',
                    value: AppConstants.clinicAddress,
                    onTap: null,
                  ),
                  const SizedBox(height: AppTokens.xl),
                  Container(
                    padding: const EdgeInsets.all(AppTokens.lg),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
                      border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: AppTokens.sm),
                            Text(
                              'Время работы',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTokens.md),
                        Text(
                          AppConstants.workingHours,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;
  final String? actionText;

  const _ContactItem({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppTokens.sm),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(value),
        trailing: onTap != null
            ? TextButton(
                onPressed: onTap,
                child: Text(actionText ?? ''),
              )
            : null,
      ),
    );
  }
}
