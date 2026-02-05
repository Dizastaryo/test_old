import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../services/lang_service.dart';
import '../theme/app_tokens.dart';

String _t(String key) => LangService.getString(key);
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
        title: Text(_t('doctor_detail_title')),
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

            if (doctor.description.isNotEmpty) ...[
              Text(
                _t('doctor_about'),
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
            ],

            Text(
              _t('doctor_services'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTokens.sm),
            Wrap(
              spacing: AppTokens.sm,
              runSpacing: AppTokens.sm,
              children: (doctor.services.isNotEmpty
                      ? doctor.services
                      : ['Консультация', 'Осмотр', 'Диагностика'])
                  .map((label) => _Chip(label: label))
                  .toList(),
            ),
            const SizedBox(height: AppTokens.xl),

            Text(
              _t('doctor_schedule'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTokens.sm),
            Text(
              _t('doctor_schedule_hint'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTokens.xxl),

            // CTA
            AppTonalButton(
              label: _t('doctor_book_btn'),
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
        color: theme.brightness == Brightness.dark ? AppTokens.surface2Dark : AppTokens.surface2,
        borderRadius: BorderRadius.circular(AppTokens.radiusChip),
      ),
      child: Text(label, style: theme.textTheme.bodySmall),
    );
  }
}
