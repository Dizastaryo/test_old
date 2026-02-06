import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../theme/app_tokens.dart';

/// Экран админа: список врачей и добавление врача (номер + специальность).
class AdminDoctorsScreen extends StatefulWidget {
  const AdminDoctorsScreen({super.key});

  @override
  State<AdminDoctorsScreen> createState() => _AdminDoctorsScreenState();
}

class _AdminDoctorsScreenState extends State<AdminDoctorsScreen> {
  List<dynamic> _doctors = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = Provider.of<AppProvider>(context, listen: false).accessToken;
      if (token == null || token.isEmpty) throw ApiException(401, 'Нет токена');
      final list = await ApiService.adminListDoctors(token);
      setState(() {
        _doctors = list is List ? list : [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e is ApiException ? e.message : e.toString();
        _loading = false;
      });
    }
  }

  void _openAddDoctor() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _AddDoctorPage(onDone: () {
          Navigator.pop(context);
          _load();
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Врачи'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                  child: Builder(
                    builder: (context) {
                      final theme = Theme.of(context);
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(onPressed: _load, child: const Text('Повторить')),
                          ],
                        ),
                      );
                    },
                  ),
                )
              : _doctors.isEmpty
                  ? Center(
                      child: Builder(
                        builder: (context) {
                          final theme = Theme.of(context);
                          final cs = theme.colorScheme;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.medical_services_outlined, size: 64, color: cs.outline),
                              const SizedBox(height: 16),
                              Text(
                                'Врачей пока нет',
                                style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurface),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Нажмите + чтобы добавить врача по номеру и специальности',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppTokens.lg),
                        itemCount: _doctors.length,
                        itemBuilder: (context, i) {
                          final d = _doctors[i] as Map<String, dynamic>;
                          final phone = d['phone']?.toString() ?? '—';
                          final fullName = d['full_name']?.toString() ?? '—';
                          final specialty = d['specialty']?.toString() ?? '—';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                child: Icon(Icons.person_rounded, color: Theme.of(context).colorScheme.primary),
                              ),
                              title: Text(fullName.isEmpty ? phone : fullName),
                              subtitle: Text('$specialty • $phone'),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddDoctor,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddDoctorPage extends StatefulWidget {
  final VoidCallback onDone;

  const _AddDoctorPage({required this.onDone});

  @override
  State<_AddDoctorPage> createState() => _AddDoctorPageState();
}

class _AddDoctorPageState extends State<_AddDoctorPage> {
  final _phoneController = TextEditingController();
  String _specialty = 'Терапевт';
  bool _loading = false;

  static const List<String> specialties = [
    'Терапевт',
    'Кардиолог',
    'Невролог',
    'Педиатр',
    'Хирург',
    'Гинеколог',
    'Офтальмолог',
    'Отоларинголог',
    'Другое',
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите номер телефона (не менее 10 цифр)'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final token = Provider.of<AppProvider>(context, listen: false).accessToken;
      if (token == null) throw ApiException(401, 'Нет токена');
      await ApiService.adminAddDoctor(token, phone: phone, specialty: _specialty);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Врач добавлен'), backgroundColor: Colors.green),
      );
      widget.onDone();
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
      appBar: AppBar(title: const Text('Добавить врача')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Укажите номер телефона и специальность. При первом входе по OTP этот номер станет врачом.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Номер телефона',
                hintText: '+7 700 123 45 67',
                prefixIcon: Icon(Icons.phone_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _specialty,
              decoration: const InputDecoration(
                labelText: 'Специальность',
                border: OutlineInputBorder(),
              ),
              items: specialties.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _specialty = v ?? 'Терапевт'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Добавить врача'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
