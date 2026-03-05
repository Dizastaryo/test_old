import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/core/auth_provider.dart';
import 'package:my_app/gen_l10n/app_localizations.dart';
import 'package:my_app/screens/auth/otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController(text: '+7 ');
  bool _loading = false;
  String? _error;

  String _normalizePhone() {
    final s = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (s.startsWith('8')) return '7${s.substring(1)}';
    if (s.startsWith('7')) return s;
    return '7$s';
  }

  Future<void> _sendCode() async {
    final phone = _normalizePhone();
    if (phone.length < 11) {
      setState(() => _error = 'Введите номер');
      return;
    }
    setState(() { _error = null; _loading = true; });
    final ok = await context.read<AuthProvider>().sendOtp(phone);
    setState(() => _loading = false);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpScreen(phone: phone),
        ),
      );
    } else {
      setState(() => _error = 'Не удалось отправить код');
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.login)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: l10n.phoneNumber,
                hintText: '+7 700 000 00 00',
                errorText: _error,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _sendCode,
              child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(l10n.getCode),
            ),
          ],
        ),
      ),
    );
  }
}
