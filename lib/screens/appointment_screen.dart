import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/mock_data.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_buttons.dart';
import 'doctors_screen.dart';
import 'package:intl/intl.dart';

class AppointmentScreen extends StatefulWidget {
  final Doctor? selectedDoctor;

  const AppointmentScreen({super.key, this.selectedDoctor});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Doctor? _selectedDoctor;
  String? _selectedService;

  final List<String> _services = [
    'Консультация',
    'Общий осмотр',
    'Повторный приём',
    'Профилактический осмотр',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDoctor = widget.selectedDoctor;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('ru', 'RU'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitAppointment() {
    if (_selectedDate == null || _selectedTime == null ||
        _selectedDoctor == null || _selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, заполните все поля'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final userId = appProvider.currentUser?.id ?? 'user_1';

    final appointmentDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Запись подтверждена'),
        content: Text(
          'Вы записаны на:\n'
          '${DateFormat('dd.MM.yyyy').format(appointmentDateTime)} '
          'в ${_selectedTime!.format(context)}\n'
          'Врач: ${_selectedDoctor!.name}\n'
          'Услуга: $_selectedService',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _selectedDate = null;
                _selectedTime = null;
                _selectedService = null;
              });
              _tabController.animateTo(1);
            },
            child: const Text('ОК'),
          ),
        ],
      ),
    );
  }

  int get _currentStep {
    if (_selectedService == null) return 1;
    if (_selectedDoctor == null) return 2;
    if (_selectedDate == null) return 3;
    if (_selectedTime == null) return 4;
    return 5;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Запись на приём'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Новая запись'),
            Tab(text: 'Мои записи'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNewAppointmentTab(),
          _buildMyAppointmentsTab(),
        ],
      ),
    );
  }

  Widget _buildNewAppointmentTab() {
    final theme = Theme.of(context);
    final step = _currentStep;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepIndicator(currentStep: step, totalSteps: 5),
          const SizedBox(height: AppTokens.xl),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTokens.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppTokens.radiusCard),
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: AppTokens.md),
                Expanded(
                  child: Text(
                    'Выберите удобную дату и время для записи',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.xl),
          Text(
            'Врач',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTokens.md),
          InkWell(
            onTap: () async {
              final doctor = await Navigator.push<Doctor>(
                context,
                MaterialPageRoute(
                  builder: (context) => const DoctorsScreen(),
                  settings: const RouteSettings(arguments: 'select_doctor'),
                ),
              );
              if (doctor != null && mounted) {
                setState(() {
                  _selectedDoctor = doctor;
                });
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTokens.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppTokens.radiusInput),
                border: Border.all(
                  color: _selectedDoctor != null
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: AppTokens.md),
                  Expanded(
                    child: Text(
                      _selectedDoctor?.name ?? 'Выберите врача',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: _selectedDoctor != null
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.outline,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 16, color: theme.colorScheme.outline),
                ],
              ),
            ),
          ),

          if (_selectedDoctor != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: AppTokens.lg),
              child: Text(
                _selectedDoctor!.specialization,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppTokens.xl),
          Text(
            'Дата',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTokens.md),
          InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTokens.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppTokens.radiusInput),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: AppTokens.md),
                  Text(
                    _selectedDate == null
                        ? 'Выберите дату'
                        : DateFormat('dd.MM.yyyy').format(_selectedDate!),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _selectedDate == null
                          ? theme.colorScheme.outline
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 16, color: theme.colorScheme.outline),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTokens.xl),
          Text(
            'Время',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTokens.md),
          InkWell(
            onTap: () => _selectTime(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTokens.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppTokens.radiusInput),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: AppTokens.md),
                  Text(
                    _selectedTime == null
                        ? 'Выберите время'
                        : _selectedTime!.format(context),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _selectedTime == null
                          ? theme.colorScheme.outline
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 16, color: theme.colorScheme.outline),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTokens.xl),
          Text(
            'Услуга',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTokens.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTokens.radiusInput),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: DropdownButton<String>(
              value: _selectedService,
              isExpanded: true,
              underline: const SizedBox(),
              hint: const Text('Выберите услугу'),
              items: _services.map((service) {
                return DropdownMenuItem(
                  value: service,
                  child: Text(service),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedService = value;
                });
              },
            ),
          ),
          const SizedBox(height: AppTokens.xxl),
          AppPrimaryButton(
            label: 'Записаться',
            onPressed: _submitAppointment,
          ),
        ],
      ),
    );
  }

  Widget _buildMyAppointmentsTab() {
    final appProvider = Provider.of<AppProvider>(context);
    final userId = appProvider.currentUser?.id ?? 'user_1';
    final appointments = MockData.getAppointments(userId);

    if (appointments.isEmpty) {
      return const Center(
        child: Text('У вас нет записей'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTokens.lg),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return _AppointmentCard(appointment: appointment);
      },
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: List.generate(totalSteps * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              color: (i ~/ 2) + 1 < currentStep
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
            ),
          );
        }
        final step = (i ~/ 2) + 1;
        final isActive = step <= currentStep;
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: isActive ? theme.colorScheme.primary : theme.colorScheme.outline,
              width: 1.5,
            ),
          ),
          child: Center(
            child: isActive
                ? Icon(Icons.check_rounded, size: 16, color: theme.colorScheme.onPrimary)
                : Text(
                    '$step',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        );
      }),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final statusColors = {
      'scheduled': theme.colorScheme.primary,
      'completed': AppTokens.success,
      'cancelled': AppTokens.error,
    };
    final statusNames = {
      'scheduled': 'Подтверждена',
      'completed': 'Завершено',
      'cancelled': 'Отменена',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: AppTokens.md),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppTokens.xs),
                      Text(
                        appointment.doctorSpecialization,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.md,
                    vertical: AppTokens.sm,
                  ),
                  decoration: BoxDecoration(
                    color: (statusColors[appointment.status] ?? theme.colorScheme.outline)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppTokens.radiusChip),
                  ),
                  child: Text(
                    statusNames[appointment.status] ?? appointment.status,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColors[appointment.status],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.md),
            Row(
              children: [
                Icon(Icons.event_note_rounded, size: 18, color: theme.colorScheme.outline),
                const SizedBox(width: AppTokens.sm),
                Text(
                  dateFormat.format(appointment.dateTime),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (appointment.notes != null) ...[
              const SizedBox(height: AppTokens.sm),
              Text(
                'Примечание: ${appointment.notes}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
