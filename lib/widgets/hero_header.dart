import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_tokens.dart';

/// Hero header: gradient + title. For Home, Profile. Шрифт Manrope для корректного отображения кириллицы.
class HeroHeader extends StatelessWidget {
  const HeroHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.expandedHeight = 160,
    this.child,
    this.centerTitle = false,
  });

  final String title;
  final String? subtitle;
  final double expandedHeight;
  final Widget? child;
  /// Если true, заголовок центрируется (для профиля).
  final bool centerTitle;

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
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: centerTitle,
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
