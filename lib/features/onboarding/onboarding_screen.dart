import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/design/design.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _currentPage = 0;

  late final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: PhosphorIcons.heart(PhosphorIconsStyle.fill),
      title: 'Делитесь\nмоментами',
      subtitle: 'Публикуйте фото, истории и делитесь впечатлениями с друзьями',
      gradient: const [Color(0xFFFF5A3C), Color(0xFFFF8F6B)],
    ),
    _OnboardingPage(
      icon: PhosphorIcons.heartbeat(PhosphorIconsStyle.fill),
      title: 'Находите людей\nрядом',
      subtitle: 'Уникальный BLE-сканер покажет друзей и знакомых поблизости',
      gradient: const [Color(0xFFC04CFD), Color(0xFFDA8AFF)],
    ),
    _OnboardingPage(
      icon: PhosphorIcons.chatCircle(PhosphorIconsStyle.fill),
      title: 'Общайтесь\nбез границ',
      subtitle: 'Мгновенные сообщения, ответы на истории и комментарии',
      gradient: const [Color(0xFFFFB547), Color(0xFFFFD080)],
    ),
  ];

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.go('/login');
    }
  }

  void _skip() {
    context.go('/login');
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SeeUColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 16, 0),
                child: GestureDetector(
                  onTap: _skip,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      'Пропустить',
                      style: SeeUTypography.caption.copyWith(
                        color: SeeUColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _buildPage(page);
                },
              ),
            ),
            // Indicator + button
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageCtrl,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                      spacing: 6,
                      activeDotColor: SeeUColors.accent,
                      dotColor: SeeUColors.borderSubtle,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SeeUButton(
                    label: _currentPage == _pages.length - 1
                        ? 'Начать'
                        : 'Далее',
                    onTap: _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: page.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: page.gradient.first.withValues(alpha: 0.3),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: SeeUTypography.displayXL.copyWith(fontSize: 36),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            style: SeeUTypography.body.copyWith(
              color: SeeUColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}
