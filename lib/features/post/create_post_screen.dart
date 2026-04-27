import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/design/design.dart';
import '../../core/providers/feed_provider.dart';
import '../../data/mock_service.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  File? _selectedImage;
  final _captionCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  bool _isPosting = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showPickerDialog());
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _showPickerDialog() {
    showSeeUBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Выбрать фото',
                style: SeeUTypography.subtitle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                PhosphorIcons.images(PhosphorIconsStyle.bold),
                color: SeeUColors.textPrimary,
              ),
              title: Text('Выбрать из галереи', style: SeeUTypography.body),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(
                PhosphorIcons.camera(PhosphorIconsStyle.bold),
                color: SeeUColors.textPrimary,
              ),
              title: Text('Сделать фото', style: SeeUTypography.body),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ).then((_) {
      if (_selectedImage == null && mounted) {
        context.pop();
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 1080,
    );
    if (picked != null && mounted) {
      setState(() => _selectedImage = File(picked.path));
    } else if (mounted) {
      context.pop();
    }
  }

  Future<void> _sharePost() async {
    if (_selectedImage == null) return;
    setState(() => _isPosting = true);
    try {
      final imageUrl = 'https://picsum.photos/seed/new${DateTime.now().millisecondsSinceEpoch}/800/800';
      await MockService.instance.createPost(
        imageUrl: imageUrl,
        caption: _captionCtrl.text.trim(),
        location: _locationCtrl.text.trim().isNotEmpty ? _locationCtrl.text.trim() : null,
      );
      if (mounted) {
        ref.read(feedProvider.notifier).refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пост опубликован!')),
        );
        context.go('/feed');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isPosting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось опубликовать.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SeeUColors.background,
      appBar: AppBar(
        backgroundColor: SeeUColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('Новый пост', style: SeeUTypography.subtitle),
        leading: IconButton(
          icon: Icon(
            PhosphorIcons.x(PhosphorIconsStyle.bold),
            color: SeeUColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: _isPosting ? null : _sharePost,
                child: _isPosting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: SeeUColors.accent, strokeWidth: 2),
                      )
                    : Text(
                        'Поделиться',
                        style: SeeUTypography.subtitle.copyWith(
                          color: SeeUColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
        ],
      ),
      body: _selectedImage == null
          ? const Center(
              child: CircularProgressIndicator(color: SeeUColors.accent),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(SeeURadii.card),
                      child: Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: 280,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: SeeUColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(SeeURadii.small),
                      ),
                      child: TextField(
                        controller: _captionCtrl,
                        maxLines: 5,
                        minLines: 3,
                        style: SeeUTypography.body,
                        decoration: InputDecoration(
                          hintText: 'Добавьте описание...',
                          hintStyle: SeeUTypography.body.copyWith(
                            color: SeeUColors.textTertiary,
                          ),
                          border: InputBorder.none,
                          filled: false,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: SeeUColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(SeeURadii.small),
                      ),
                      child: TextField(
                        controller: _locationCtrl,
                        style: SeeUTypography.body,
                        decoration: InputDecoration(
                          hintText: 'Добавить место',
                          hintStyle: SeeUTypography.body.copyWith(
                            color: SeeUColors.textTertiary,
                          ),
                          border: InputBorder.none,
                          filled: false,
                          contentPadding: const EdgeInsets.all(16),
                          prefixIcon: Icon(
                            PhosphorIcons.mapPin(PhosphorIconsStyle.bold),
                            color: SeeUColors.textTertiary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: _showPickerDialog,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: SeeUColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(SeeURadii.small),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              PhosphorIcons.images(PhosphorIconsStyle.bold),
                              color: SeeUColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Изменить фото',
                              style: SeeUTypography.body.copyWith(
                                color: SeeUColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                              color: SeeUColors.textTertiary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SeeUButton(
                      label: 'Поделиться',
                      onTap: _isPosting ? null : _sharePost,
                      isLoading: _isPosting,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
