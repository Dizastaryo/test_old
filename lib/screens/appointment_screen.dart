import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import '../services/lang_service.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_buttons.dart';
import 'doctors_screen.dart';
import 'package:intl/intl.dart';

String _t(String key) => LangService.getString(key);

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
  List<Appointment> _myAppointments = [];
  bool _loadingAppointments = true;

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMyAppointments());
  }

  Future<void> _loadMyAppointments() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final user = appProvider.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loadingAppointments = false);
      return;
    }
    final userId = int.tryParse(user.id);
    if (userId == null) {
      if (mounted) setState(() => _loadingAppointments = false);
      return;
    }
    try {
      Map<String, dynamic>? patient = await ApiService.medkGetPatientByUser(userId);
      patient ??= await ApiService.medkEnsurePatient(userId: userId, fullName: user.name);
      final patientId = patient['id'] is int ? patient['id'] as int : int.tryParse(patient['id']?.toString() ?? '');
      if (patientId == null) {
        if (mounted) setState(() => _loadingAppointments = false);
        return;
      }
      final list = await ApiService.medkListAppointments(patientId: patientId);
      if (mounted) {
        setState(() {
          _myAppointments = list
              .map((e) => Appointment.fromMedkJson(Map<String, dynamic>.from(e as Map), userId: user.id))
              .toList();
          _loadingAppointments = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingAppointments = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDateAndTime(BuildContext context) async {
    if (_selectedDoctor == null) return;
    final doctorId = int.tryParse(_selectedDoctor!.id) ?? 1;
    final DateTime? picked = await Navigator.of(context).push<DateTime>(
      MaterialPageRoute(
        builder: (context) => CalendarTimePickerScreen(doctorId: doctorId),
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
        _selectedTime = TimeOfDay(hour: picked.hour, minute: picked.minute);
      });
    }
  }

  Future<void> _submitAppointment() async {
    if (_selectedDate == null || _selectedTime == null ||
        _selectedDoctor == null || _selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_t('appointment_fill_all')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final userId = appProvider.currentUser?.id ?? 'stub';
    final patientUserId = (userId == 'stub' ? 0 : int.tryParse(userId) ?? 0);
    final doctorId = int.tryParse(_selectedDoctor!.id) ?? 1;

    final appointmentDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    try {
      final patient = await ApiService.medkEnsurePatient(
        userId: patientUserId,
        fullName: appProvider.currentUser?.name ?? 'Пациент',
      );
      final patientId = patient['id'] as int?;
      if (patientId == null) throw ApiException(500, 'Нет patient_id');
      await ApiService.medkCreateAppointment(
        patientId: patientId,
        doctorId: doctorId,
        scheduledAt: appointmentDateTime,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is ApiException ? e.message : e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_t('appointment_confirmed')),
        content: Text(
          '${_t('appointment_confirmed_msg')}\n'
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
            child: Text(_t('appointment_ok')),
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
    Provider.of<AppProvider>(context); // перестройка при смене языка
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('appointment_title')),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: cs.onPrimary,
          labelColor: cs.onPrimary,
          unselectedLabelColor: cs.onPrimary.withOpacity(0.8),
          tabs: [
            Tab(text: _t('appointment_new')),
            Tab(text: _t('appointment_my')),
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
                    _t('appointment_select_date_time'),
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
            _t('appointment_doctor'),
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
                      _selectedDoctor?.name ?? _t('appointment_select_doctor'),
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
            _t('appointment_date_time'),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTokens.sm),
          Text(
            _t('appointment_slots_hint'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.md),
          InkWell(
            onTap: _selectedDoctor != null ? () => _selectDateAndTime(context) : null,
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
                  Expanded(
                    child: Text(
                      _selectedDate == null || _selectedTime == null
                          ? _t('appointment_select_slot')
                          : '${DateFormat('dd.MM.yyyy').format(_selectedDate!)} в ${_selectedTime!.format(context)}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: _selectedDate == null
                            ? theme.colorScheme.outline
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 16, color: theme.colorScheme.outline),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTokens.xl),
          Text(
            _t('appointment_service'),
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
              hint: Text(_t('appointment_select_service')),
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
            label: _t('appointment_book_btn'),
            onPressed: _submitAppointment,
          ),
        ],
      ),
    );
  }

  Widget _buildMyAppointmentsTab() {
    if (_loadingAppointments) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_myAppointments.isEmpty) {
      return Center(
        child: Text(_t('appointment_no_records')),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMyAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTokens.lg),
        itemCount: _myAppointments.length,
        itemBuilder: (context, index) {
          final appointment = _myAppointments[index];
          return _AppointmentCard(appointment: appointment);
        },
      ),
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
                : (theme.brightness == Brightness.dark ? AppTokens.surface2Dark : AppTokens.surface2),
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

/// Экран выбора даты и времени: календарь (зелёный — свободный день, красный — занят)
/// и слоты времени (зелёный — свободно, красный — занято).
class CalendarTimePickerScreen extends StatefulWidget {
  final int doctorId;

  const CalendarTimePickerScreen({super.key, required this.doctorId});

  @override
  State<CalendarTimePickerScreen> createState() => _CalendarTimePickerScreenState();
}

class _CalendarTimePickerScreenState extends State<CalendarTimePickerScreen> {
  static const int _slotMinutes = 30;
  static const int _startHour = 9;
  static const int _endHour = 18;

  Set<DateTime> _busySlots = {};
  bool _loading = true;
  String? _error;
  DateTime? _selectedDay;
  final DateTime _today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ApiService.medkListAppointments(doctorId: widget.doctorId);
      final busy = <DateTime>{};
      for (final a in list) {
        final map = a as Map<String, dynamic>;
        final s = map['scheduled_at']?.toString();
        if (s == null) continue;
        try {
          final dt = DateTime.parse(s);
          final slot = _slotStart(dt);
          if (slot != null) busy.add(slot);
        } catch (_) {}
      }
      setState(() {
        _busySlots = busy;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e is ApiException ? e.message : e.toString();
        _loading = false;
      });
    }
  }

  DateTime? _slotStart(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute;
    if (h < _startHour || h >= _endHour) return null;
    final slotM = (m ~/ _slotMinutes) * _slotMinutes;
    return DateTime(dt.year, dt.month, dt.day, h, slotM, 0);
  }

  List<DateTime> _getSlotsForDay(DateTime day) {
    final slots = <DateTime>[];
    for (int h = _startHour; h < _endHour; h++) {
      for (int m = 0; m < 60; m += _slotMinutes) {
        if (h == _endHour - 1 && m > 0) break;
        slots.add(DateTime(day.year, day.month, day.day, h, m, 0));
      }
    }
    return slots;
  }

  bool _isSlotFree(DateTime slot) {
    if (slot.isBefore(DateTime.now().add(const Duration(minutes: 1)))) return false;
    return !_busySlots.contains(slot);
  }

  bool _dayHasFreeSlot(DateTime day) {
    if (day.isBefore(_today)) return false;
    for (final slot in _getSlotsForDay(day)) {
      if (_isSlotFree(slot)) return true;
    }
    return false;
  }

  bool _isDayPast(DateTime day) => day.isBefore(_today);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('appointment_select_date_time_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadAppointments,
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
                        ElevatedButton(onPressed: _loadAppointments, child: Text(_t('doctors_retry'))),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTokens.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t('appointment_calendar'),
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _t('appointment_calendar_hint'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCalendarGrid(theme),
                      if (_selectedDay != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          '${_t('appointment_time_on')}${DateFormat('dd.MM.yyyy').format(_selectedDay!)}',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _t('appointment_slots_hint'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                        const SizedBox(height: 12),
                        _buildTimeSlots(theme),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildCalendarGrid(ThemeData theme) {
    const int daysCount = 35;
    final firstDay = _today;
    return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.9,
          ),
          itemCount: daysCount,
          itemBuilder: (context, index) {
            final day = firstDay.add(Duration(days: index));
            final isPast = _isDayPast(day);
            final hasFree = _dayHasFreeSlot(day);
            final isSelected = _selectedDay != null &&
                _selectedDay!.year == day.year &&
                _selectedDay!.month == day.month &&
                _selectedDay!.day == day.day;
            Color bg;
            if (isPast) {
              bg = theme.colorScheme.surfaceVariant.withOpacity(0.5);
            } else if (hasFree) {
              bg = AppTokens.success.withOpacity(0.25);
            } else {
              bg = AppTokens.error.withOpacity(0.25);
            }
            return InkWell(
              onTap: isPast ? null : () => setState(() => _selectedDay = day),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: theme.colorScheme.primary, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : null,
                      color: isPast ? theme.colorScheme.onSurface.withOpacity(0.4) : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            );
          },
        );
  }

  Widget _buildTimeSlots(ThemeData theme) {
    if (_selectedDay == null) return const SizedBox.shrink();
    final slots = _getSlotsForDay(_selectedDay!);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((slot) {
        final free = _isSlotFree(slot);
        return InkWell(
          onTap: free
              ? () => Navigator.of(context).pop(slot)
              : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: free
                  ? AppTokens.success.withOpacity(0.25)
                  : AppTokens.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: free ? AppTokens.success : AppTokens.error.withOpacity(0.6),
              ),
            ),
            child: Center(
              child: Text(
                '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: free ? AppTokens.success : theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: free ? FontWeight.w600 : null,
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
      'scheduled': _t('appointment_status_scheduled'),
      'completed': _t('appointment_status_completed'),
      'cancelled': _t('appointment_status_cancelled'),
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
                '${_t('appointment_note')}${appointment.notes}',
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
