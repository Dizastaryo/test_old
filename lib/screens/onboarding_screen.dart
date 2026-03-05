import 'package:flutter/material.dart';
import 'package:my_app/gen_l10n/app_localizations.dart';
import 'package:my_app/screens/auth/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.store, size: 100, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                l10n.appTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Бронируйте и оплачивайте местные услуги удобно',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: Text(l10n.start),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
