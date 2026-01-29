import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import 'app_buttons.dart';

/// Empty state: иллюстрация + текст + опциональный CTA.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.ctaLabel,
    this.onCtaPressed,
  });

  final String title;
  final String? message;
  final IconData? icon;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 64,
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: AppTokens.xl),
            ],
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppTokens.sm),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTokens.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (ctaLabel != null && onCtaPressed != null) ...[
              const SizedBox(height: AppTokens.xl),
              SizedBox(
                width: double.infinity,
                child: AppTonalButton(
                  label: ctaLabel!,
                  onPressed: onCtaPressed,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
