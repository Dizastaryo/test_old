import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../theme/app_tokens.dart';

/// Список приёмов врача: принять приём, завершить, добавить анализы/документы.
class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  List<dynamic> _appointments = [];
  int? _doctorId;
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
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final userId = appProvider.currentUser?.id;
      int uid = 1;
      if (userId != null && userId != 'stub') {
        uid = int.tryParse(userId) ?? 1;
      }
      final doctor = await ApiService.medkEnsureDoctor(
        userId: uid,
        fullName: appProvider.currentUser?.name ?? 'Врач',
      );
      final did = doctor['id'] as int?;
      if (did == null) throw ApiException(500, 'Нет doctor_id');
      final list = await ApiService.medkListAppointments(doctorId: did);
      setState(() {
        _doctorId = did;
        _appointments = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e is ApiException ? e.message : e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои приёмы'),
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
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _load, child: const Text('Повторить')),
                      ],
                    ),
                  ),
                )
              : _appointments.isEmpty
                  ? const Center(child: Text('Нет приёмов'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _appointments.length,
                        itemBuilder: (context, i) {
                          final a = _appointments[i] as Map<String, dynamic>;
                          final id = a['id'] as int? ?? 0;
                          final status = a['status'] as String? ?? '';
                          final patientName = a['patient_name'] as String? ?? 'Пациент';
                          final patientId = a['patient_id'] as int? ?? 0;
                          final scheduledAt = a['scheduled_at'];
                          DateTime? dt;
                          if (scheduledAt != null) {
                            try {
                              dt = DateTime.parse(scheduledAt.toString());
                            } catch (_) {}
                          }
                          final completed = status == 'completed';
                          final canAccept = status == 'scheduled';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(patientName),
                              subtitle: Text(
                                '${dt != null ? DateFormat('dd.MM.yyyy HH:mm').format(dt) : scheduledAt?.toString() ?? ''} • ${_statusLabel(status)}',
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (canAccept)
                                    TextButton(
                                      onPressed: () => _acceptAppointment(id),
                                      child: const Text('Принять'),
                                    ),
                                  if (!completed)
                                    TextButton(
                                      onPressed: () => _openComplete(context, id, a),
                                      child: const Text('Завершить'),
                                    ),
                                ],
                              ),
                              onTap: () => _openDetail(context, a),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'scheduled': return 'Запланирован';
      case 'in_progress': return 'В приёме';
      case 'completed': return 'Завершён';
      case 'cancelled': return 'Отменён';
      default: return status;
    }
  }

  Future<void> _acceptAppointment(int appointmentId) async {
    try {
      await ApiService.medkUpdateAppointmentStatus(appointmentId, 'in_progress');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Приём принят'), backgroundColor: Colors.green),
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is ApiException ? e.message : e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _openDetail(BuildContext context, Map<String, dynamic> appointment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _DoctorAppointmentDetailPage(
          appointment: appointment,
          doctorId: _doctorId ?? 0,
          onDone: () {
            Navigator.pop(context);
            _load();
          },
        ),
      ),
    );
  }

  void _openComplete(BuildContext context, int appointmentId, Map<String, dynamic> appointment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _CompleteAppointmentPage(
          appointmentId: appointmentId,
          patientName: appointment['patient_name']?.toString() ?? 'Пациент',
          onDone: () {
            Navigator.pop(context);
            _load();
          },
        ),
      ),
    );
  }
}

/// Детали приёма: принять, завершить, добавить анализы, добавить документ.
class _DoctorAppointmentDetailPage extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final int doctorId;
  final VoidCallback onDone;

  const _DoctorAppointmentDetailPage({
    required this.appointment,
    required this.doctorId,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final id = appointment['id'] as int? ?? 0;
    final patientId = appointment['patient_id'] as int? ?? 0;
    final status = appointment['status'] as String? ?? '';
    final patientName = appointment['patient_name']?.toString() ?? 'Пациент';
    final scheduledAt = appointment['scheduled_at'];
    DateTime? dt;
    if (scheduledAt != null) {
      try {
        dt = DateTime.parse(scheduledAt.toString());
      } catch (_) {}
    }
    final canAccept = status == 'scheduled';
    final canComplete = status == 'scheduled' || status == 'in_progress';

    return Scaffold(
      appBar: AppBar(title: Text('Приём: $patientName')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Пациент: $patientName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Дата: ${dt != null ? DateFormat('dd.MM.yyyy HH:mm').format(dt) : scheduledAt ?? ''}'),
                    Text('Статус: $status'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (canAccept)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await ApiService.medkUpdateAppointmentStatus(id, 'in_progress');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Приём принят'), backgroundColor: Colors.green),
                        );
                        onDone();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e is ApiException ? e.message : e.toString()), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Принять приём'),
                ),
              ),
            if (canComplete)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => _CompleteAppointmentPage(
                          appointmentId: id,
                          patientName: patientName,
                          onDone: () {
                            Navigator.pop(context);
                            onDone();
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.assignment_turned_in),
                  label: const Text('Завершить приём'),
                ),
              ),
            const Divider(height: 24),
            const Text('Данные пациента', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: patientId > 0
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => _AddAnalysisPage(
                            patientId: patientId,
                            appointmentId: id,
                            patientName: patientName,
                            onDone: () {
                              Navigator.pop(context);
                              onDone();
                            },
                          ),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.science),
              label: const Text('Добавить анализы'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: patientId > 0
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => _AddDocumentPage(
                            patientId: patientId,
                            doctorId: doctorId,
                            patientName: patientName,
                            onDone: () {
                              Navigator.pop(context);
                              onDone();
                            },
                          ),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.description),
              label: const Text('Добавить документ (PDF)'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddAnalysisPage extends StatefulWidget {
  final int patientId;
  final int appointmentId;
  final String patientName;
  final VoidCallback onDone;

  const _AddAnalysisPage({
    required this.patientId,
    required this.appointmentId,
    required this.patientName,
    required this.onDone,
  });

  @override
  State<_AddAnalysisPage> createState() => _AddAnalysisPageState();
}

class _AddAnalysisPageState extends State<_AddAnalysisPage> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  String _type = 'other';
  final _resultsControllers = <String, TextEditingController>{};
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    for (final c in _resultsControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Укажите название анализа')));
      return;
    }
    setState(() => _loading = true);
    try {
      final results = <String, dynamic>{};
      for (final e in _resultsControllers.entries) {
        if (e.value.text.trim().isNotEmpty) results[e.key] = e.value.text.trim();
      }
      await ApiService.medkCreateAnalysis(
        patientId: widget.patientId,
        name: _nameController.text.trim(),
        type: _type,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        results: results.isEmpty ? null : results,
        appointmentId: widget.appointmentId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Анализ добавлен'), backgroundColor: Colors.green));
        widget.onDone();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is ApiException ? e.message : e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _addResultRow() {
    showDialog(
      context: context,
      builder: (ctx) {
        final nameController = TextEditingController();
        final valueController = TextEditingController();
        return AlertDialog(
          title: const Text('Показатель'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Название (напр. Hb)')),
              const SizedBox(height: 8),
              TextField(controller: valueController, decoration: const InputDecoration(labelText: 'Значение')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            TextButton(
              onPressed: () {
                final n = nameController.text.trim();
                if (n.isNotEmpty) {
                  _resultsControllers[n] = TextEditingController(text: valueController.text);
                  setState(() {});
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Анализы: ${widget.patientName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Название анализа', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Тип', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'blood', child: Text('Кровь')),
                DropdownMenuItem(value: 'urine', child: Text('Моча')),
                DropdownMenuItem(value: 'xray', child: Text('Рентген')),
                DropdownMenuItem(value: 'other', child: Text('Другое')),
              ],
              onChanged: (v) => setState(() => _type = v ?? 'other'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Примечания', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Text('Результаты (показатель — значение)', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._resultsControllers.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(child: Text(e.key)),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: e.value,
                          decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                )),
            TextButton.icon(onPressed: _addResultRow, icon: const Icon(Icons.add), label: const Text('Добавить показатель')),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppTokens.primary, foregroundColor: Colors.white),
                child: _loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Сохранить анализ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddDocumentPage extends StatefulWidget {
  final int patientId;
  final int doctorId;
  final String patientName;
  final VoidCallback onDone;

  const _AddDocumentPage({
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.onDone,
  });

  @override
  State<_AddDocumentPage> createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends State<_AddDocumentPage> {
  final _titleController = TextEditingController();
  String _documentType = 'other';
  bool _loading = false;
  List<int>? _fileBytes;
  String? _fileName;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final f = result.files.single;
        if (f.bytes != null && f.bytes!.isNotEmpty) {
          setState(() {
            _fileBytes = f.bytes;
            _fileName = f.name;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Не удалось прочитать файл. Выберите PDF.'), backgroundColor: Colors.orange),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Укажите название документа')));
      return;
    }
    if (_fileBytes == null || _fileBytes!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Выберите PDF файл')));
      return;
    }
    setState(() => _loading = true);
    try {
      await ApiService.medkUploadDocument(
        patientId: widget.patientId,
        fileBytes: _fileBytes!,
        fileName: _fileName ?? 'document.pdf',
        title: _titleController.text.trim(),
        documentType: _documentType,
        doctorId: widget.doctorId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Документ загружен'), backgroundColor: Colors.green));
        widget.onDone();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is ApiException ? e.message : e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Документ: ${widget.patientName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Название (выписка, справка и т.д.)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _documentType,
              decoration: const InputDecoration(labelText: 'Тип', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'discharge', child: Text('Выписка')),
                DropdownMenuItem(value: 'certificate', child: Text('Справка')),
                DropdownMenuItem(value: 'referral', child: Text('Направление')),
                DropdownMenuItem(value: 'other', child: Text('Другое')),
              ],
              onChanged: (v) => setState(() => _documentType = v ?? 'other'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.upload_file),
              label: Text(_fileName ?? 'Выбрать PDF файл'),
            ),
            if (_fileName != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Файл: $_fileName', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline))),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppTokens.primary, foregroundColor: Colors.white),
                child: _loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Загрузить документ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompleteAppointmentPage extends StatefulWidget {
  final int appointmentId;
  final String patientName;
  final VoidCallback onDone;

  const _CompleteAppointmentPage({
    required this.appointmentId,
    required this.patientName,
    required this.onDone,
  });

  @override
  State<_CompleteAppointmentPage> createState() => _CompleteAppointmentPageState();
}

class _CompleteAppointmentPageState extends State<_CompleteAppointmentPage> {
  final _complaintController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _familyController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _complaintController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _familyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_treatmentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Укажите назначения (жалоба, диагноз, лечение)')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await ApiService.medkCompleteAppointment(
        widget.appointmentId,
        complaint: _complaintController.text.trim(),
        diagnosis: _diagnosisController.text.trim(),
        treatmentText: _treatmentController.text.trim(),
        familyAnamnesisSnapshot: _familyController.text.trim().isEmpty ? null : _familyController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Приём завершён. Напоминалка сформирована.'), backgroundColor: Colors.green),
        );
        widget.onDone();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is ApiException ? e.message : e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Завершить приём: ${widget.patientName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Жалоба', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            TextField(
              controller: _complaintController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Жалобы пациента сейчас',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Семейный анамнез (если не в медкарте)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            TextField(
              controller: _familyController,
              maxLines: 1,
              decoration: const InputDecoration(
                hintText: 'DM2, HTN, CVD, CANCER, NONE',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Диагноз', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            TextField(
              controller: _diagnosisController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Текущий диагноз (хронические добавятся в медкарту)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Назначения (диета, препараты)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            TextField(
              controller: _treatmentController,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Например:\nДиета №5.\nПанкреатин 3 раза в день 7 дней.\nАугментин 2 раза в день после еды 7 дней.\nФлуконазол однократно на 3-й день после начала аугментина.',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTokens.primary,
                  foregroundColor: Colors.white,
                ),
                child: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Завершить приём (модель + LLM → напоминалка)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
