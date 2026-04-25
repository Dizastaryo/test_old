import 'package:flutter/material.dart';
import 'tokens.dart';

class SeeUCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  const SeeUCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = SeeURadii.card,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: SeeUColors.surfaceElevated,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: SeeUShadows.md,
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
