import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/design/design.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isCheckingUsername = false;
  bool? _usernameAvailable;
  Timer? _usernameDebounce;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _usernameDebounce?.cancel();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    _usernameDebounce?.cancel();
    if (value.length < 3) {
      setState(() {
        _usernameAvailable = null;
        _isCheckingUsername = false;
      });
      return;
    }
    setState(() => _isCheckingUsername = true);
    _usernameDebounce = Timer(const Duration(milliseconds: 600), () async {
      try {
        final apiClient = ref.read(apiClientProvider);
        await apiClient.get(
          ApiEndpoints.checkUsername,
          queryParameters: {'username': value},
        );
        if (mounted) {
          setState(() {
            _usernameAvailable = true;
            _isCheckingUsername = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _usernameAvailable = false;
            _isCheckingUsername = false;
          });
        }
      }
    });
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = await ref.read(authProvider.notifier).register(
          username: _usernameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          fullName: _fullNameCtrl.text.trim(),
        );
    if (success && mounted) {
      context.go('/feed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: SeeUColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            PhosphorIcons.arrowLeft(PhosphorIconsStyle.regular),
            size: 22,
            color: SeeUColors.textPrimary,
          ),
          onPressed: () => context.go('/login'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Heading
                Text(
                  'Создать\nаккаунт',
                  style: SeeUTypography.displayXL,
                ),
                const SizedBox(height: 8),
                Text(
                  'Присоединяйся к SeeU',
                  style: SeeUTypography.body.copyWith(
                    color: SeeUColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

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

                // Full Name
                SeeUInput(
                  controller: _fullNameCtrl,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  hintText: 'Полное имя',
                  prefix: Icon(
                    PhosphorIcons.user(PhosphorIconsStyle.regular),
                    size: 20,
                    color: SeeUColors.textTertiary,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Введите полное имя';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Username
                SeeUInput(
                  controller: _usernameCtrl,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  onChanged: _onUsernameChanged,
                  hintText: 'Имя пользователя',
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 8),
                    child: Text(
                      '@',
                      style: SeeUTypography.subtitle.copyWith(
                        color: SeeUColors.textSecondary,
                      ),
                    ),
                  ),
                  suffix: _buildUsernameStatus(),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Введите имя пользователя';
                    }
                    if (v.length < 3) return 'Минимум 3 символа';
                    if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(v)) {
                      return 'Только буквы, цифры, точки, подчёркивания';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Email
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

                // Password
                SeeUInput(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _register(),
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
                    if (v.length < 8) return 'Минимум 8 символов';
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // Register button
                SeeUButton(
                  label: 'Создать аккаунт',
                  variant: SeeUButtonVariant.primary,
                  isLoading: authState.isLoading,
                  onTap: authState.isLoading ? null : _register,
                ),
                const SizedBox(height: 24),

                // Terms
                Center(
                  child: Text(
                    'Регистрируясь, вы соглашаетесь с Условиями использования и Политикой конфиденциальности.',
                    textAlign: TextAlign.center,
                    style: SeeUTypography.caption.copyWith(
                      color: SeeUColors.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Уже есть аккаунт? ',
                      style: SeeUTypography.body.copyWith(
                        color: SeeUColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text(
                        'Войти',
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

  Widget? _buildUsernameStatus() {
    if (_isCheckingUsername) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: SeeUColors.accent,
          ),
        ),
      );
    }
    if (_usernameAvailable == true) {
      return Icon(
        PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
        color: SeeUColors.success,
        size: 20,
      );
    }
    if (_usernameAvailable == false) {
      return Icon(
        PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
        color: SeeUColors.like,
        size: 20,
      );
    }
    return null;
  }
}
