import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import 'main_screen.dart';

/// Экран заполнения профиля пациента при первом входе (имя, фамилия, адрес, рост, вес, пол).
class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String _gender = 'M';
  bool _loading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final height = int.tryParse(_heightController.text.trim());
    final weight = int.tryParse(_weightController.text.trim());
    if (height == null || height < 50 || height > 250) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Рост от 50 до 250 см'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (weight == null || weight < 20 || weight > 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Вес от 20 до 300 кг'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final token = appProvider.accessToken;
      if (token == null || token.isEmpty) throw ApiException(401, 'Нет токена');
      final user = await ApiService.updateProfile(
        token,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        address: _addressController.text.trim(),
        heightCm: height,
        weightKg: weight,
        gender: _gender,
      );
      if (!mounted) return;
      await appProvider.updateUser(user);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is ApiException ? e.message : e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Заполните профиль'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text(
                'Укажите ваши данные для записи к врачу',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _firstNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Имя',
                  hintText: 'Иван',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Введите имя';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Фамилия',
                  hintText: 'Иванов',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Введите фамилию';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Адрес',
                  hintText: 'Город, улица, дом',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  alignLabelWithHint: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Введите адрес';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Рост (см)',
                  hintText: '170',
                  prefixIcon: Icon(Icons.height),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Введите рост';
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 50 || n > 250) return 'От 50 до 250 см';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Вес (кг)',
                  hintText: '70',
                  prefixIcon: Icon(Icons.monitor_weight_outlined),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Введите вес';
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 20 || n > 300) return 'От 20 до 300 кг';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(
                  labelText: 'Пол',
                  prefixIcon: Icon(Icons.wc_rounded),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: const [
                  DropdownMenuItem(value: 'M', child: Text('Мужской')),
                  DropdownMenuItem(value: 'F', child: Text('Женский')),
                ],
                onChanged: (v) => setState(() => _gender = v ?? 'M'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Сохранить и продолжить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
