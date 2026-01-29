import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Hero header: gradient + title. For Home, Profile.
class HeroHeader extends StatelessWidget {
  const HeroHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.expandedHeight = 160,
    this.child,
  });

  final String title;
  final String? subtitle;
  final double expandedHeight;
  final Widget? child;

  static const List<Color> _heroGradient = [
    Color(0xFF1D4ED8),
    Color(0xFF60A5FA),
  ];

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      backgroundColor: _heroGradient.first,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: _heroGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
