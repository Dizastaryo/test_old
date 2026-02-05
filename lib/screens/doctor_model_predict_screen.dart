import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_tokens.dart';

/// Страница врача: ввод данных пациента и клинической заметки, предсказание по модели.
class DoctorModelPredictScreen extends StatefulWidget {
  const DoctorModelPredictScreen({super.key});

  @override
  State<DoctorModelPredictScreen> createState() => _DoctorModelPredictScreenState();
}

class _DoctorModelPredictScreenState extends State<DoctorModelPredictScreen> {
  final _ageController = TextEditingController(text: '55');
  final _familyHistoryController = TextEditingController(text: 'HTN, DM2');
  final _noteController = TextEditingController(
    text: 'Пациент предъявляет жалобы на слабость и жажду. При осмотре: состояние удовлетворительное. АД 145/90. Рекомендации: коррекция дозы, контроль глюкозы.',
  );
  String _gender = 'M';
  bool _isLoading = false;
  List<Map<String, dynamic>>? _predictions;

  static const _labelNames = {
    'has_diabetes': 'Сахарный диабет',
    'has_hypertension': 'Гипертония',
    'has_copd_asthma': 'ХОБЛ/астма',
    'has_ckd': 'ХБП',
    'has_depression': 'Депрессия',
    'has_obesity': 'Ожирение',
    'exacerbation_risk_next_year': 'Риск обострения (год)',
    'medication_adherence_risk': 'Риск низкой приверженности',
  };

  @override
  void dispose() {
    _ageController.dispose();
    _familyHistoryController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _runPredict() async {
    final age = int.tryParse(_ageController.text.trim()) ?? 55;
    if (age < 1 || age > 120) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Возраст: 1–120')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
      _predictions = null;
    });
    try {
      final raw = _familyHistoryController.text.trim();
      final codes = raw.isEmpty
          ? <String>[]
          : raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final data = await ApiService.medicalPredict(
        age: age,
        gender: _gender,
        familyHistoryCodes: codes,
        noteText: _noteController.text.trim(),
      );
      final list = data['predictions'] as List<dynamic>?;
      setState(() {
        _predictions = list?.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
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
      appBar: AppBar(
        title: const Text('Модель предсказаний'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Данные пациента',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Возраст',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: const InputDecoration(
                      labelText: 'Пол',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'M', child: Text('M')),
                      DropdownMenuItem(value: 'F', child: Text('F')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _gender = v);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _familyHistoryController,
              decoration: const InputDecoration(
                labelText: 'Семейный анамнез (DM2, HTN, CVD, CANCER, NONE)',
                border: OutlineInputBorder(),
                hintText: 'Через запятую',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Клиническая заметка',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _runPredict,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTokens.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Получить предсказания'),
              ),
            ),
            if (_predictions != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const Text(
                'Результаты',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ..._predictions!.map((p) {
                final name = p['name'] as String? ?? '';
                final label = _labelNames[name] ?? name;
                final prob = (p['probability'] as num?)?.toDouble() ?? 0.0;
                final positive = p['positive'] == true;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: positive ? Colors.red.shade50 : null,
                  child: ListTile(
                    title: Text(label),
                    trailing: Text(
                      '${(prob * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: positive ? Colors.red : null,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
