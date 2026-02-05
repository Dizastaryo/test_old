import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../theme/app_tokens.dart';

/// Экран редактирования карточки врача: имя, специальность, описание, услуги.
class DoctorProfileEditScreen extends StatefulWidget {
  const DoctorProfileEditScreen({super.key});

  @override
  State<DoctorProfileEditScreen> createState() => _DoctorProfileEditScreenState();
}

class _DoctorProfileEditScreenState extends State<DoctorProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _specialtyController;
  late TextEditingController _descriptionController;
  late TextEditingController _servicesController;
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _specialtyController = TextEditingController();
    _descriptionController = TextEditingController();
    _servicesController = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _descriptionController.dispose();
    _servicesController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final userId = int.tryParse(appProvider.currentUser?.id ?? '');
    if (userId == null) {
      setState(() {
        _loading = false;
        _loadError = 'Пользователь не найден';
      });
      return;
    }
    try {
      final doc = await ApiService.medkGetDoctorByUser(userId);
      if (mounted) {
        setState(() {
          _loading = false;
          if (doc != null) {
            _nameController.text = (doc['full_name'] ?? '').toString();
            _specialtyController.text = (doc['specialty'] ?? '').toString();
            _descriptionController.text = (doc['description'] ?? '').toString();
            final services = doc['services'];
            _servicesController.text = services is List
                ? (services as List).map((e) => e.toString()).join(', ')
                : '';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = e.toString().replaceFirst('ApiException: ', '');
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final token = appProvider.accessToken;
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нужна авторизация')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final servicesStr = _servicesController.text.trim();
      final services = servicesStr.isEmpty
          ? <String>[]
          : servicesStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      await ApiService.medkUpdateDoctorProfile(
        token,
        fullName: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
        specialty: _specialtyController.text.trim().isEmpty ? null : _specialtyController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        services: services.isEmpty ? null : services,
      );
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Карточка врача сохранена'), backgroundColor: AppTokens.success),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('ApiException: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Карточка врача'), elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Карточка врача'), elevation: 0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_loadError!, textAlign: TextAlign.center),
                const SizedBox(height: AppTokens.md),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _loading = true;
                      _loadError = null;
                    });
                    _loadProfile();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточка врача'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Сохранить'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'ФИО',
                  hintText: 'Как отображать в карточке',
                ),
              ),
              const SizedBox(height: AppTokens.lg),
              TextFormField(
                controller: _specialtyController,
                decoration: const InputDecoration(
                  labelText: 'Специальность',
                  hintText: 'Терапевт, Кардиолог, ...',
                ),
              ),
              const SizedBox(height: AppTokens.lg),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'О себе',
                  hintText: 'Краткое описание для пациентов',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppTokens.lg),
              TextFormField(
                controller: _servicesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Услуги',
                  hintText: 'Через запятую: Консультация, Осмотр, Диагностика',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
