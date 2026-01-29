import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_buttons.dart';

/// Экран детальной информации о враче: фото, о враче, услуги, расписание, CTA «Записаться».
class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key, required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Врач'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Крупный аватар и имя
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppTokens.lg),
                  Text(
                    doctor.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTokens.xs),
                  Text(
                    doctor.specialization,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTokens.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_rounded, size: 20, color: AppTokens.warning),
                      const SizedBox(width: AppTokens.xs),
                      Text(
                        doctor.rating.toStringAsFixed(1),
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(width: AppTokens.lg),
                      Icon(Icons.work_rounded, size: 20, color: theme.colorScheme.outline),
                      const SizedBox(width: AppTokens.xs),
                      Text(
                        '${doctor.experienceYears} лет опыта',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.xl),

            // О враче
            Text(
              'О враче',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTokens.sm),
            Text(
              doctor.description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTokens.xl),

            // Услуги (мок)
            Text(
              'Услуги',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTokens.sm),
            Wrap(
              spacing: AppTokens.sm,
              runSpacing: AppTokens.sm,
              children: [
                _Chip(label: 'Консультация'),
                _Chip(label: 'Осмотр'),
                _Chip(label: 'Диагностика'),
              ],
            ),
            const SizedBox(height: AppTokens.xl),

            // Расписание (мок)
            Text(
              'Ближайшие слоты',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTokens.sm),
            Text(
              'Пн–Пт: 09:00–18:00. Запись через форму ниже.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTokens.xxl),

            // CTA
            AppTonalButton(
              label: 'Записаться к этому врачу',
              icon: const Icon(Icons.event_available_rounded, size: 20),
              onPressed: () {
                Navigator.pop(context, doctor);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.md,
        vertical: AppTokens.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTokens.radiusChip),
      ),
      child: Text(label, style: theme.textTheme.bodySmall),
    );
  }
}
