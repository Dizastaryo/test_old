import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/mock_data.dart';
import '../models/medical_record.dart';
import 'package:intl/intl.dart';

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
  String _selectedFilter = 'Все';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _loadData();
  }

  void _loadData() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final userId = appProvider.currentUser?.id ?? 'user_1';
    _records = MockData.getMedicalRecords(userId);
    _analyses = _records
        .where((r) => r.analyses != null)
        .expand((r) => r.analyses!)
        .toList();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('История посещений'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Посещения'),
            Tab(text: 'Анализы'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVisitsTab(),
          _buildAnalysesTab(),
        ],
      ),
    );
  }

  Widget _buildVisitsTab() {
    if (_records.isEmpty) {
      return const Center(
        child: Text('История посещений пуста'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        return _VisitCard(record: record);
      },
    );
  }

  Widget _buildAnalysesTab() {
    if (_analyses.isEmpty) {
      return const Center(
        child: Text('Анализы не найдены'),
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
                  selectedColor: Colors.blue.shade100,
                  checkmarkColor: Colors.blue.shade700,
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
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.medical_services, color: Colors.blue),
        ),
        title: Text(
          record.doctorName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          dateFormat.format(record.visitDate),
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
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.science, color: Colors.green),
        ),
        title: Text(
          analysis.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${typeNames[analysis.type] ?? analysis.type} • ${dateFormat.format(analysis.date)}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Результаты:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            entry.value.toString(),
                            style: TextStyle(
                              color: Colors.blue.shade700,
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
                      color: Colors.grey.shade600,
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
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
