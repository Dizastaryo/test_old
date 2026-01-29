import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Info card (подсказки). Surface2, radius 16.
class AppInfoCard extends StatelessWidget {
  const AppInfoCard({
    super.key,
    required this.child,
    this.icon,
  });

  final Widget child;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppTokens.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        border: Border.all(color: AppTokens.outline.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(
                size: 20,
                color: theme.colorScheme.primary,
              ),
              child: icon!,
            ),
            const SizedBox(width: AppTokens.md),
          ],
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Action card (быстрые действия). Один стиль теней, radius 16.
class AppActionCard extends StatelessWidget {
  const AppActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Material(
      color: c.withOpacity(0.12),
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        child: Container(
          padding: const EdgeInsets.all(AppTokens.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.radiusCard),
            border: Border.all(color: c.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: c),
              const SizedBox(height: AppTokens.sm),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: c,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Promo card (акции). Gradient, radius 16.
class AppPromoCard extends StatelessWidget {
  const AppPromoCard({
    super.key,
    required this.title,
    required this.description,
    this.discountPercent,
  });

  final String title;
  final String description;
  final int? discountPercent;

  static const List<Color> _gradientColors = [
    Color(0xFF1E40AF),
    Color(0xFF14B8A6),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTokens.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: _gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        boxShadow: [
          BoxShadow(
            color: AppTokens.primary.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (discountPercent != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.md,
                  vertical: AppTokens.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTokens.radiusChip),
                ),
                child: Text(
                  'Скидка $discountPercent%',
                  style: const TextStyle(
                    color: AppTokens.primaryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.md),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppTokens.sm),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
