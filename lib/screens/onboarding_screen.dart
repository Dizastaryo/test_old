import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_buttons.dart';
import 'auth_screen.dart';
import 'main_screen.dart';

/// 3 экрана онбординга с «Пропустить» и CTA «Начать».
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.event_available_rounded,
      title: 'Запись за минуту',
      body: 'Выбирайте врача, дату и время — запись на приём за пару тапов.',
    ),
    _OnboardingPage(
      icon: Icons.folder_rounded,
      title: 'История и анализы',
      body: 'Все визиты и результаты анализов в одном месте. Удобно и понятно.',
    ),
    _OnboardingPage(
      icon: Icons.smart_toy_rounded,
      title: 'Чат-помощник',
      body: 'Ответы на вопросы о клинике, записи и подготовке к анализам — в чате.',
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.completeOnboarding();
    if (!mounted) return;
    if (appProvider.isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Пропустить'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.xxl,
                      vertical: AppTokens.xl,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          p.icon,
                          size: 64,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: AppTokens.xxl),
                        Text(
                          p.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTokens.md),
                        Text(
                          p.body,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppTokens.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _currentPage
                        ? theme.colorScheme.primary
                        : AppTokens.outline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTokens.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTokens.xl),
              child: AppPrimaryButton(
                label: _currentPage < _pages.length - 1 ? 'Далее' : 'Начать',
                onPressed: _next,
              ),
            ),
            const SizedBox(height: AppTokens.xxl),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String body;
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });
}
