import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/core/auth_provider.dart';
import 'package:my_app/screens/splash_screen.dart';
import 'package:my_app/screens/onboarding_screen.dart';
import 'package:my_app/screens/auth/login_screen.dart';
import 'package:my_app/screens/home/home_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.loading) {
          return const SplashScreen();
        }
        if (!auth.isAuthenticated) {
          return const AuthFlow();
        }
        return const HomeScreen();
      },
    );
  }
}

class AuthFlow extends StatelessWidget {
  const AuthFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [
        const MaterialPage(child: OnboardingScreen()),
      ],
      onPopPage: (_, __) => false,
    );
  }
}
