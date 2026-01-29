import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Skeleton placeholder for loading (карточки-плейсхолдеры).
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    super.key,
    this.width,
    this.height = 24,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius:
                widget.borderRadius ?? BorderRadius.circular(AppTokens.xs),
            color: Theme.of(context)
                .colorScheme
                .outline
                .withOpacity(_animation.value),
          ),
        );
      },
    );
  }
}

/// Skeleton card for list items.
class AppSkeletonCard extends StatelessWidget {
  const AppSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      ),
      child: Row(
        children: [
          const AppSkeleton(width: 64, height: 64),
          const SizedBox(width: AppTokens.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSkeleton(height: 16, width: 120),
                const SizedBox(height: AppTokens.sm),
                AppSkeleton(height: 14, width: double.infinity),
                const SizedBox(height: AppTokens.xs),
                AppSkeleton(height: 14, width: 180),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
