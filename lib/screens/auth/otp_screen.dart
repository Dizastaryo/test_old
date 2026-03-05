import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/core/auth_provider.dart';
import 'package:my_app/gen_l10n/app_localizations.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone});
  final String phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _verify() async {
    final code = _codeController.text.replaceAll(RegExp(r'\D'), '');
    if (code.length < 4) {
      setState(() => _error = 'Введите код');
      return;
    }
    setState(() { _error = null; _loading = true; });
    final token = await context.read<AuthProvider>().verifyOtp(widget.phone, code);
    if (!mounted) return;
    setState(() => _loading = false);
    if (token != null) {
      await context.read<AuthProvider>().init();
    } else {
      setState(() => _error = 'Неверный код');
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.enterCode)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: l10n.enterCode,
                errorText: _error,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _verify,
              child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(l10n.confirm),
            ),
          ],
        ),
      ),
    );
  }
}
