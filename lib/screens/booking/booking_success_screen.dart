import 'package:flutter/material.dart';
import 'package:my_app/gen_l10n/app_localizations.dart';
import 'package:my_app/screens/home/home_screen.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({
    super.key,
    required this.bookingId,
    required this.serviceName,
    required this.datetimeStart,
    required this.totalPrice,
  });
  final int bookingId;
  final String serviceName;
  final String datetimeStart;
  final double totalPrice;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.check_circle, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              Text(l10n.bookingSuccess, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text('${l10n.service}: $serviceName'),
              Text('${l10n.dateTime}: $datetimeStart'),
              Text('${l10n.total}: $totalPrice ₸'),
              Text('№ $bookingId'),
              const SizedBox(height: 32),
              FilledButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false), child: Text(l10n.myBookingsBtn)),
              OutlinedButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false), child: Text(l10n.toHome)),
            ],
          ),
        ),
      ),
    );
  }
}
