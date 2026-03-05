import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/core/api_client.dart';
import 'package:my_app/core/auth_provider.dart';
import 'package:my_app/gen_l10n/app_localizations.dart';
import 'package:my_app/screens/booking/booking_success_screen.dart';
import 'dart:convert';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.serviceId,
    required this.service,
    required this.datetimeStart,
    required this.totalPrice,
  });
  final int serviceId;
  final Map<String, dynamic> service;
  final String datetimeStart;
  final double totalPrice;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _pay() async {
    final card = _cardController.text.replaceAll(RegExp(r'\D'), '');
    if (card.length != 16) {
      setState(() => _error = 'Номер карты 16 цифр');
      return;
    }
    setState(() { _error = null; _loading = true; });
    final api = context.read<ApiClient>();
    final dtStart = widget.datetimeStart.replaceAll(' ', 'T');
    final createRes = await api.post('/bookings', {
      'service_id': widget.serviceId,
      'datetime_start': dtStart,
      'comment': null,
      'quantity': 1,
      'use_bonus_points': 0,
    });
    if (createRes.statusCode != 200) {
      setState(() { _loading = false; _error = 'Ошибка создания брони'; });
      return;
    }
    final booking = jsonDecode(createRes.body) as Map<String, dynamic>;
    final bookingId = booking['id'] as int;
    final payRes = await api.post('/payments', {
      'booking_id': bookingId,
      'card_number': card,
      'card_expiry': _expiryController.text,
      'card_cvv': _cvvController.text,
    });
    if (!mounted) return;
    setState(() => _loading = false);
    if (payRes.statusCode == 200) {
      final data = jsonDecode(payRes.body) as Map<String, dynamic>;
      if (data['success'] == true) {
        await context.read<AuthProvider>().init();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BookingSuccessScreen(
              bookingId: bookingId,
              serviceName: widget.service['name'] as String? ?? '',
              datetimeStart: widget.datetimeStart,
              totalPrice: widget.totalPrice,
            ),
          ),
        );
        return;
      }
    }
    setState(() => _error = 'Ошибка оплаты');
  }

  @override
  void dispose() {
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pay)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${l10n.total}: ${widget.totalPrice} ₸', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            TextField(
              controller: _cardController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.cardNumber, errorText: _error),
            ),
            TextField(controller: _expiryController, decoration: InputDecoration(labelText: l10n.expiry)),
            TextField(controller: _cvvController, obscureText: true, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.cvv)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _pay,
              child: _loading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)) : Text(l10n.pay),
            ),
          ],
        ),
      ),
    );
  }
}
