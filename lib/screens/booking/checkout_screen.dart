import 'package:flutter/material.dart';
import 'package:my_app/gen_l10n/app_localizations.dart';
import 'package:my_app/screens/booking/payment_screen.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({
    super.key,
    required this.serviceId,
    required this.service,
    required this.datetimeStart,
  });
  final int serviceId;
  final Map<String, dynamic> service;
  final String datetimeStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final price = (service['price'] as num?)?.toDouble() ?? 0.0;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingDetails)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(service['name'] as String? ?? '', style: Theme.of(context).textTheme.titleLarge),
            Text('${l10n.provider}: ${service['provider_name'] ?? ''}'),
            Text('${l10n.dateTime}: $datetimeStart'),
            Text('${l10n.total}: $price ₸'),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentScreen(
                    serviceId: serviceId,
                    service: service,
                    datetimeStart: datetimeStart,
                    totalPrice: price,
                  ),
                ),
              ),
              child: Text(l10n.proceedToPay),
            ),
          ],
        ),
      ),
    );
  }
}
