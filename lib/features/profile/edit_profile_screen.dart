import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/design/design.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _websiteCtrl;
  File? _newAvatar;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _fullNameCtrl = TextEditingController(text: user?.fullName ?? '');
    _usernameCtrl = TextEditingController(text: user?.username ?? '');
    _bioCtrl = TextEditingController(text: user?.bio ?? '');
    _websiteCtrl = TextEditingController(text: user?.website ?? '');
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 400,
    );
    if (picked != null && mounted) {
      setState(() => _newAvatar = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      Map<String, dynamic> data = {
        'full_name': _fullNameCtrl.text.trim(),
        'username': _usernameCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'website': _websiteCtrl.text.trim(),
      };

      if (_newAvatar != null) {
        final formData = FormData.fromMap({
          ...data,
          'avatar': await MultipartFile.fromFile(_newAvatar!.path),
        });
        final response = await apiClient.patch(
          ApiEndpoints.editProfile,
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );
        // Update auth state with new user data
        if (mounted) {
          ref.read(authProvider.notifier).updateUser(
            ref.read(authProvider).user!.copyWith(
              fullName: _fullNameCtrl.text.trim(),
              username: _usernameCtrl.text.trim(),
              bio: _bioCtrl.text.trim(),
              website: _websiteCtrl.text.trim(),
            ),
          );
        }
        // response used to update UI
        debugPrint('Profile updated: ${response.statusCode}', wrapWidth: 1024);
      } else {
        await apiClient.patch(ApiEndpoints.editProfile, data: data);
        if (mounted) {
          ref.read(authProvider.notifier).updateUser(
            ref.read(authProvider).user!.copyWith(
              fullName: _fullNameCtrl.text.trim(),
              username: _usernameCtrl.text.trim(),
              bio: _bioCtrl.text.trim(),
              website: _websiteCtrl.text.trim(),
            ),
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профиль обновлён!')),
        );
        context.pop();
      }
    } catch (_) {
      // Apply locally even if API fails
      ref.read(authProvider.notifier).updateUser(
        ref.read(authProvider).user!.copyWith(
          fullName: _fullNameCtrl.text.trim(),
          bio: _bioCtrl.text.trim(),
          website: _websiteCtrl.text.trim(),
        ),
      );
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Сохранено локально')),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: SeeUColors.background,
      appBar: AppBar(
        backgroundColor: SeeUColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Редактировать профиль', style: SeeUTypography.subtitle),
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft(), size: 22, color: SeeUColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: SeeUColors.accent, strokeWidth: 2),
                    )
                  : Text(
                      'Готово',
                      style: SeeUTypography.subtitle.copyWith(
                        color: SeeUColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 24),

            // Avatar
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: SeeUColors.surfaceElevated,
                      backgroundImage: _newAvatar != null
                          ? FileImage(_newAvatar!) as ImageProvider
                          : user?.avatarUrl != null
                              ? NetworkImage(user!.avatarUrl!)
                              : null,
                      child: _newAvatar == null && user?.avatarUrl == null
                          ? Text(
                              user?.username.substring(0, 1).toUpperCase() ??
                                  'U',
                              style: SeeUTypography.displayL.copyWith(
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: SeeUColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: SeeUColors.background,
                            width: 2,
                          ),
                        ),
                        child: Icon(PhosphorIcons.camera(PhosphorIconsStyle.fill),
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Изменить фото профиля',
                style: SeeUTypography.body.copyWith(
                  color: SeeUColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Form fields
            Text('Полное имя', style: SeeUTypography.caption),
            const SizedBox(height: 6),
            SeeUInput(
              controller: _fullNameCtrl,
              textCapitalization: TextCapitalization.words,
              hintText: 'Полное имя',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Обязательное поле' : null,
            ),
            const SizedBox(height: 16),

            Text('Имя пользователя', style: SeeUTypography.caption),
            const SizedBox(height: 6),
            SeeUInput(
              controller: _usernameCtrl,
              autocorrect: false,
              hintText: 'Имя пользователя',
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Обязательное поле';
                if (v.length < 3) return 'At least 3 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),

            Text('О себе', style: SeeUTypography.caption),
            const SizedBox(height: 6),
            SeeUInput(
              controller: _bioCtrl,
              maxLines: 3,
              maxLength: 150,
              hintText: 'Расскажите о себе...',
            ),
            const SizedBox(height: 16),

            Text('Сайт', style: SeeUTypography.caption),
            const SizedBox(height: 6),
            SeeUInput(
              controller: _websiteCtrl,
              keyboardType: TextInputType.url,
              autocorrect: false,
              hintText: 'Ссылка на сайт',
            ),
            const SizedBox(height: 40),

            SeeUButton(
              label: 'Сохранить',
              variant: SeeUButtonVariant.primary,
              isLoading: _isSaving,
              onTap: _isSaving ? null : _save,
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
