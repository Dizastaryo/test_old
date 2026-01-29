import 'package:flutter/material.dart';
import '../services/mock_data.dart';
import '../models/doctor.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_buttons.dart';
import 'appointment_screen.dart';
import 'doctor_detail_screen.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  List<Doctor> _doctors = [];
  List<Doctor> _filteredDoctors = [];
  String _selectedSpecialization = 'Все';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _doctors = MockData.getDoctors();
    _applyFilters();
    _searchController.addListener(() => setState(_applyFilters));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _specializations {
    final specializations = _doctors.map((d) => d.specialization).toSet().toList();
    specializations.insert(0, 'Все');
    return specializations;
  }

  void _applyFilters() {
    var list = _doctors;
    if (_selectedSpecialization != 'Все') {
      list = list.where((d) => d.specialization == _selectedSpecialization).toList();
    }
    final q = _searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((d) =>
          d.name.toLowerCase().contains(q) ||
          d.specialization.toLowerCase().contains(q) ||
          d.description.toLowerCase().contains(q)).toList();
    }
    _filteredDoctors = list;
  }

  void _filterDoctors(String specialization) {
    setState(() {
      _selectedSpecialization = specialization;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Врачи'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Поиск
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.lg,
              vertical: AppTokens.sm,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск по имени или специальности',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusInput),
                ),
                filled: true,
              ),
            ),
          ),
          // Фильтр по специализации
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTokens.lg),
              itemCount: _specializations.length,
              itemBuilder: (context, index) {
                final spec = _specializations[index];
                final isSelected = spec == _selectedSpecialization;
                return Padding(
                  padding: const EdgeInsets.only(right: AppTokens.sm),
                  child: FilterChip(
                    label: Text(spec),
                    selected: isSelected,
                    onSelected: (_) => _filterDoctors(spec),
                    selectedColor: theme.colorScheme.primaryContainer,
                    checkmarkColor: theme.colorScheme.primary,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppTokens.sm),
          // Список врачей
          Expanded(
            child: _filteredDoctors.isEmpty
                ? const Center(
                    child: Text('Врачи не найдены'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppTokens.lg),
                    itemCount: _filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = _filteredDoctors[index];
                      final isSelectMode =
                          ModalRoute.of(context)?.settings.arguments == 'select_doctor';
                      return _DoctorListItem(
                        doctor: doctor,
                        onTapCard: () async {
                          final result = await Navigator.push<Doctor>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoctorDetailScreen(doctor: doctor),
                            ),
                          );
                          if (result != null && mounted) {
                            if (isSelectMode) {
                              Navigator.pop(context, result);
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AppointmentScreen(selectedDoctor: result),
                                ),
                              );
                            }
                          }
                        },
                        onBook: () {
                          if (isSelectMode) {
                            Navigator.pop(context, doctor);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AppointmentScreen(selectedDoctor: doctor),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DoctorListItem extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTapCard;
  final VoidCallback onBook;

  const _DoctorListItem({
    required this.doctor,
    required this.onTapCard,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppTokens.md),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      ),
      child: InkWell(
        onTap: onTapCard,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppTokens.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppTokens.xs),
                        Text(
                          doctor.specialization,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppTokens.sm),
                        Text(
                          doctor.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppTokens.sm),
                        Row(
                          children: [
                            Icon(Icons.star_rounded, size: 18, color: AppTokens.warning),
                            const SizedBox(width: AppTokens.xs),
                            Text(
                              doctor.rating.toStringAsFixed(1),
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(width: AppTokens.lg),
                            Icon(Icons.work_rounded, size: 18, color: theme.colorScheme.outline),
                            const SizedBox(width: AppTokens.xs),
                            Text(
                              '${doctor.experienceYears} лет опыта',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.md),
              Align(
                alignment: Alignment.centerRight,
                child: AppTonalButton(
                  label: 'Записаться',
                  onPressed: onBook,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
