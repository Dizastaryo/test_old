import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/design/design.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = await ref.read(authProvider.notifier).login(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
    if (success && mounted) {
      context.go('/feed');
    }
  }

  void _demoLogin() {
    ref.read(authProvider.notifier).demoLogin();
    context.go('/feed');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: SeeUColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 72),

                // Logo
                Text(
                  'SeeU',
                  style: SeeUTypography.displayXL,
                ),
                const SizedBox(height: 8),
                Text(
                  'Связь с миром',
                  style: SeeUTypography.body.copyWith(
                    color: SeeUColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),

                // Error banner
                if (authState.error != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: SeeUColors.accentSoft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      authState.error!,
                      style: SeeUTypography.caption.copyWith(
                        color: SeeUColors.accent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Email field
                SeeUInput(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  hintText: 'Эл. почта',
                  prefix: Icon(
                    PhosphorIcons.envelope(PhosphorIconsStyle.regular),
                    size: 20,
                    color: SeeUColors.textTertiary,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Введите эл. почту';
                    if (!v.contains('@')) return 'Введите корректную почту';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Password field
                SeeUInput(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                  hintText: 'Пароль',
                  prefix: Icon(
                    PhosphorIcons.lock(PhosphorIconsStyle.regular),
                    size: 20,
                    color: SeeUColors.textTertiary,
                  ),
                  suffix: GestureDetector(
                    onTap: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword
                          ? PhosphorIcons.eye(PhosphorIconsStyle.regular)
                          : PhosphorIcons.eyeSlash(PhosphorIconsStyle.regular),
                      size: 20,
                      color: SeeUColors.textTertiary,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Введите пароль';
                    if (v.length < 6) return 'Пароль слишком короткий';
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Забыли пароль?',
                        style: SeeUTypography.caption.copyWith(
                          color: SeeUColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login button
                SeeUButton(
                  label: 'Войти',
                  variant: SeeUButtonVariant.primary,
                  isLoading: authState.isLoading,
                  onTap: authState.isLoading ? null : _login,
                ),
                const SizedBox(height: 28),

                // OR divider
                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: SeeUColors.borderSubtle),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ИЛИ',
                        style: SeeUTypography.caption.copyWith(
                          color: SeeUColors.textTertiary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: SeeUColors.borderSubtle),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Demo login
                SeeUButton(
                  label: 'Войти как демо-пользователь',
                  variant: SeeUButtonVariant.ghost,
                  onTap: _demoLogin,
                ),
                const SizedBox(height: 48),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Нет аккаунта? ',
                      style: SeeUTypography.body.copyWith(
                        color: SeeUColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/register'),
                      child: Text(
                        'Регистрация',
                        style: SeeUTypography.body.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: SeeUColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
