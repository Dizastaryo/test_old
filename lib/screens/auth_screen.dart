import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main_screen.dart';
import 'profile_completion_screen.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';

/// Экран входа: только номер телефона и код подтверждения (OTP в WhatsApp).
/// Регистрации и «забыл пароль» нет.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _codeSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  static const String _adminPhone = '77001234567';

  String _normalizePhone(String v) {
    return v.replaceAll(RegExp(r'\D'), '');
  }

  bool _isAdminPhone(String normalized) {
    return normalized == _adminPhone;
  }

  Future<void> _loginAsAdmin() async {
    final phone = _normalizePhone(_phoneController.text);
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите номер телефона'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.loginAdmin(phone);
      final token = data['access_token']?.toString();
      if (token == null || token.isEmpty) throw ApiException(500, 'Нет токена');
      final user = await ApiService.me(token);
      if (!mounted) return;
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.setSession(token, user);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is ApiException ? e.message : e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _requestOtp() async {
    final phone = _normalizePhone(_phoneController.text);
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите номер телефона (не менее 10 цифр)'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ApiService.requestOtp(phone);
      if (mounted) {
        setState(() {
          _codeSent = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Код отправлен в WhatsApp'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is ApiException ? e.message : e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _verifyAndLogin() async {
    final phone = _normalizePhone(_phoneController.text);
    final code = _codeController.text.replaceAll(RegExp(r'\D'), '');
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите номер телефона'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите код из WhatsApp'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.verifyOtp(phone, code);
      final token = data['access_token']?.toString();
      if (token == null || token.isEmpty) throw ApiException(500, 'Нет токена');
      final user = await ApiService.me(token);
      if (!mounted) return;
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.setSession(token, user);
      if (!mounted) return;
      if (user.isPatient && !user.profileComplete) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ProfileCompletionScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is ApiException ? e.message : e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _backToPhone() {
    setState(() {
      _codeSent = false;
      _codeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.local_hospital, size: 50, color: cs.onPrimary),
                ),
                const SizedBox(height: 16),
                Text(
                  'Qamqor Clinic',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Частная клиника',
                  style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 32),
                if (!_codeSent) ...[
                  Text(
                    'Введите номер телефона. Код подтверждения придёт в WhatsApp.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Номер телефона',
                      hintText: '+7 700 123 45 67',
                      prefixIcon: const Icon(Icons.phone_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: cs.surface,
                    ),
                    validator: (v) {
                      final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                      if (digits.length < 10) return 'Не менее 10 цифр';
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 24),
                  if (_isAdminPhone(_normalizePhone(_phoneController.text))) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _loginAsAdmin,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.primary,
                          side: BorderSide(color: cs.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Войти как админ (без кода)'),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _requestOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary),
                            )
                          : const Text('Получить код'),
                    ),
                  ),
                ] else ...[
                  Text(
                    'Введите код из WhatsApp',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _phoneController.text.trim().isEmpty
                        ? ''
                        : 'Номер: ${_phoneController.text.trim()}',
                    style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    decoration: InputDecoration(
                      labelText: 'Код подтверждения',
                      hintText: '123456',
                      prefixIcon: const Icon(Icons.sms_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: cs.surface,
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyAndLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary),
                            )
                          : const Text('Войти'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _isLoading ? null : _backToPhone,
                    child: Text('Изменить номер', style: TextStyle(color: cs.primary)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
