import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../models/medical_record.dart';
import '../theme/app_tokens.dart';

class MedicalHistoryScreen extends StatefulWidget {
  final int initialTab;

  const MedicalHistoryScreen({super.key, this.initialTab = 0});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<MedicalRecord> _records = [];
  List<AnalysisResult> _analyses = [];
  List<Map<String, dynamic>> _documents = [];
  String _selectedFilter = 'Все';
  int? _patientId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 2),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final userId = appProvider.currentUser?.id;
      if (userId == null || userId.isEmpty) {
        setState(() {
          _loading = false;
          _patientId = null;
          _records = [];
          _analyses = [];
          _documents = [];
        });
        return;
      }
      final uid = int.tryParse(userId) ?? 0;
      if (uid == 0) {
        setState(() {
          _loading = false;
          _patientId = null;
          _records = [];
          _analyses = [];
          _documents = [];
        });
        return;
      }
      final patient = await ApiService.medkEnsurePatient(
        userId: uid,
        fullName: appProvider.currentUser?.name ?? 'Пациент',
      );
      final pid = patient['id'] as int?;
      if (pid == null) {
        setState(() {
          _loading = false;
          _patientId = null;
          _records = [];
          _analyses = [];
          _documents = [];
        });
        return;
      }
      final appointments = await ApiService.medkListAppointments(patientId: pid, status: 'completed');
      final analyses = await ApiService.medkListAnalyses(pid);
      final documents = await ApiService.medkListDocuments(pid);

      final records = <MedicalRecord>[];
      for (final a in appointments) {
        final map = a as Map<String, dynamic>;
        DateTime? dt;
        try {
          final s = map['scheduled_at']?.toString();
          if (s != null) dt = DateTime.parse(s);
        } catch (_) {}
        records.add(MedicalRecord(
          id: map['id']?.toString() ?? '',
          userId: userId,
          doctorId: map['doctor_id']?.toString() ?? '',
          doctorName: map['doctor_name']?.toString() ?? 'Врач',
          visitDate: dt ?? DateTime.now(),
          diagnosis: map['diagnosis']?.toString(),
          symptoms: map['complaint']?.toString(),
          treatment: map['treatment_text']?.toString(),
          analyses: null,
        ));
      }
      final analysisList = <AnalysisResult>[];
      for (final a in analyses) {
        final map = a as Map<String, dynamic>;
        DateTime? dt;
        try {
          final s = map['analysis_date']?.toString();
          if (s != null) dt = DateTime.parse(s);
        } catch (_) {}
        analysisList.add(AnalysisResult(
          id: map['id']?.toString() ?? '',
          name: map['name']?.toString() ?? 'Анализ',
          type: map['type']?.toString() ?? 'other',
          date: dt ?? DateTime.now(),
          results: Map<String, dynamic>.from(map['results'] is Map ? map['results'] as Map : {}),
          notes: map['notes']?.toString(),
        ));
      }
      final docList = documents is List ? documents.map((e) => e as Map<String, dynamic>).toList() : <Map<String, dynamic>>[];

      setState(() {
        _patientId = pid;
        _records = records;
        _analyses = analysisList;
        _documents = docList;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e is ApiException ? e.message : e.toString();
        _loading = false;
        _records = [];
        _analyses = [];
        _documents = [];
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AnalysisResult> get _filteredAnalyses {
    if (_selectedFilter == 'Все') return _analyses;
    return _analyses.where((a) => a.type == _selectedFilter.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('История посещений'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: cs.onPrimary,
          labelColor: cs.onPrimary,
          unselectedLabelColor: cs.onPrimary.withOpacity(0.8),
          tabs: const [
            Tab(icon: Icon(Icons.medical_services_rounded), text: 'Визиты'),
            Tab(icon: Icon(Icons.science_rounded), text: 'Анализы'),
            Tab(icon: Icon(Icons.description_rounded), text: 'Документы'),
          ],
        ),
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
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _loadData, child: const Text('Повторить')),
                      ],
                    ),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildVisitsTab(),
                    _buildAnalysesTab(),
                    _buildDocumentsTab(),
                  ],
                ),
    );
  }

  Widget _buildDocumentsTab() {
    if (_documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: AppTokens.lg),
            Text(
              'Документы пока отсутствуют. Врач может добавить выписки и справки в разделе приёма.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppTokens.lg),
      itemCount: _documents.length,
      itemBuilder: (context, index) {
        final doc = _documents[index];
        final id = doc['id'] as int? ?? 0;
        final title = doc['title']?.toString() ?? 'Документ';
        final type = doc['document_type']?.toString() ?? 'other';
        final createdAt = doc['created_at']?.toString();
        DateTime? dt;
        if (createdAt != null) {
          try {
            dt = DateTime.parse(createdAt);
          } catch (_) {}
        }
        final typeLabel = type == 'discharge' ? 'Выписка' : type == 'certificate' ? 'Справка' : type == 'referral' ? 'Направление' : 'Документ';
        return Card(
          margin: const EdgeInsets.only(bottom: AppTokens.md),
          child: ListTile(
            leading: Icon(Icons.description_rounded, color: Theme.of(context).colorScheme.primary),
            title: Text(title),
            subtitle: Text('$typeLabel • ${dt != null ? DateFormat('dd.MM.yyyy').format(dt) : ''}'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              if (_patientId != null) {
                final url = ApiService.medkDocumentFileUrl(_patientId!, id);
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildVisitsTab() {
    if (_records.isEmpty) {
      return Center(
        child: Text(
          'История посещений пуста',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTokens.lg),
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        return _VisitCard(record: record);
      },
    );
  }

  Widget _buildAnalysesTab() {
    if (_analyses.isEmpty) {
      return Center(
        child: Text(
          'Анализы не найдены',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }

    return Column(
      children: [
        // Фильтр
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: ['Все', 'Кровь', 'Моча', 'Рентген', 'Другое'].length,
            itemBuilder: (context, index) {
              final filter = ['Все', 'Кровь', 'Моча', 'Рентген', 'Другое'][index];
              final isSelected = filter == _selectedFilter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedFilter = filter);
                  },
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  checkmarkColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
        ),
        
        // Список анализов
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredAnalyses.length,
            itemBuilder: (context, index) {
              final analysis = _filteredAnalyses[index];
              return _AnalysisCard(analysis: analysis);
            },
          ),
        ),
      ],
    );
  }
}

class _VisitCard extends StatelessWidget {
  final MedicalRecord record;

  const _VisitCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppTokens.md),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(AppTokens.sm),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          ),
          child: Icon(Icons.medical_services_rounded, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          record.doctorName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          dateFormat.format(record.visitDate),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (record.symptoms != null) ...[
                  _InfoRow(label: 'Симптомы', value: record.symptoms!),
                  const SizedBox(height: 12),
                ],
                if (record.diagnosis != null) ...[
                  _InfoRow(label: 'Диагноз', value: record.diagnosis!),
                  const SizedBox(height: 12),
                ],
                if (record.treatment != null) ...[
                  _InfoRow(label: 'Лечение', value: record.treatment!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  final AnalysisResult analysis;

  const _AnalysisCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final typeNames = {
      'blood': 'Кровь',
      'urine': 'Моча',
      'xray': 'Рентген',
      'other': 'Другое',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: AppTokens.md),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(AppTokens.sm),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.6),
            borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          ),
          child: Icon(Icons.science_rounded, color: Theme.of(context).colorScheme.secondary),
        ),
        title: Text(
          analysis.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          '${typeNames[analysis.type] ?? analysis.type} • ${dateFormat.format(analysis.date)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Результаты:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                ...analysis.results.entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            entry.value.toString(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )),
                if (analysis.notes != null) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    'Примечания: ${analysis.notes}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
