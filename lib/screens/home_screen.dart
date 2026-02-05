import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../services/lang_service.dart';
import '../models/promotion.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../theme/app_tokens.dart';
import '../widgets/hero_header.dart';
import '../widgets/app_cards.dart';
import 'appointment_screen.dart';
import 'medical_history_screen.dart';
import 'doctors_screen.dart';
import 'contact_screen.dart';
import 'package:intl/intl.dart';

String _t(String key) => LangService.getString(key);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Doctor> _doctors = [];
  List<Appointment> _appointments = [];
  List<Promotion> _promotions = [];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
    _loadPromotions();
    _loadAppointments();
  }

  Future<void> _loadDoctors() async {
    try {
      final list = await ApiService.medkListDoctors();
      if (mounted) {
        setState(() {
          _doctors = list.map((e) => Doctor.fromMedkJson(Map<String, dynamic>.from(e as Map))).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _loadPromotions() async {
    try {
      final list = await LangService.getPromotions();
      if (mounted) setState(() => _promotions = list);
    } catch (_) {}
  }

  Future<void> _loadAppointments() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final user = appProvider.currentUser;
    if (user == null) return;
    final userId = int.tryParse(user.id);
    if (userId == null) return;
    try {
      Map<String, dynamic>? patient = await ApiService.medkGetPatientByUser(userId);
      patient ??= await ApiService.medkEnsurePatient(userId: userId, fullName: user.name);
      final patientId = patient['id'] is int ? patient['id'] as int : int.tryParse(patient['id']?.toString() ?? '');
      if (patientId == null) return;
      final list = await ApiService.medkListAppointments(patientId: patientId);
      if (mounted) {
        setState(() {
          _appointments = list
              .map((e) => Appointment.fromMedkJson(Map<String, dynamic>.from(e as Map), userId: user.id))
              .toList();
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final user = appProvider.currentUser;
    final nextAppointment = _appointments
        .where((a) => a.status == 'scheduled' && a.dateTime.isAfter(DateTime.now()))
        .isEmpty
        ? null
        : _appointments
            .where((a) => a.status == 'scheduled' && a.dateTime.isAfter(DateTime.now()))
            .reduce((a, b) => a.dateTime.isBefore(b.dateTime) ? a : b);
    final promotionsActive = _promotions.where((p) => p.isActive).toList();
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          HeroHeader(
            expandedHeight: 120,
            title: user != null
                ? '${_t('home_welcome')}${user.name.split(' ').first}!'
                : _t('home_welcome_guest'),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Next Appointment Card
                if (nextAppointment != null) ...[
                  const SizedBox(height: AppTokens.lg),
                  _NextAppointmentCard(appointment: nextAppointment),
                  const SizedBox(height: AppTokens.xl),
                ],

                // Promo carousel (из lang/ru.json)
                if (promotionsActive.isNotEmpty) ...[
                  const SizedBox(height: AppTokens.lg),
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      itemCount: promotionsActive.length,
                      itemBuilder: (context, index) {
                        final p = promotionsActive[index];
                        return AppPromoCard(
                          title: p.title,
                          description: p.description,
                          discountPercent: p.discount?.toInt(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppTokens.xl),
                ],

                // Quick Actions 2×2
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTokens.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t('home_quick_actions'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppTokens.lg),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: AppTokens.md,
                        mainAxisSpacing: AppTokens.md,
                        childAspectRatio: 1.2,
                        children: [
                          AppActionCard(
                            icon: Icons.add_circle_rounded,
                            title: _t('home_booking'),
                            color: AppTokens.primary,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AppointmentScreen(),
                              ),
                            ),
                          ),
                          AppActionCard(
                            icon: Icons.groups_rounded,
                            title: _t('home_doctors'),
                            color: AppTokens.secondary,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DoctorsScreen(),
                              ),
                            ),
                          ),
                          AppActionCard(
                            icon: Icons.science_rounded,
                            title: _t('home_analyses'),
                            color: AppTokens.info,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MedicalHistoryScreen(initialTab: 1),
                              ),
                            ),
                          ),
                          AppActionCard(
                            icon: Icons.call_rounded,
                            title: _t('home_contacts'),
                            color: AppTokens.warning,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ContactScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.xl),

                // Рекомендуемые врачи
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTokens.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _t('home_recommended_doctors'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DoctorsScreen(),
                          ),
                        ),
                        child: Text(_t('home_all_doctors')),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.md),
                SizedBox(
                  height: 128,
                  child: _doctors.isEmpty
                      ? Center(child: Text(_t('home_loading_doctors')))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: AppTokens.lg),
                          itemCount: _doctors.length > 4 ? 4 : _doctors.length,
                          itemBuilder: (context, index) {
                            final doctor = _doctors[index];
                            return _DoctorMiniCard(doctor: doctor);
                          },
                        ),
                ),
                const SizedBox(height: AppTokens.xl),

                // Услуги
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTokens.lg),
                  child: Text(
                    _t('home_our_services'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppTokens.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTokens.lg),
                  child: Column(
                    children: [
                      _ServiceTile(
                        icon: Icons.medical_services_rounded,
                        title: _t('home_service_consultation'),
                        subtitle: _t('home_service_consultation_sub'),
                      ),
                      const SizedBox(height: AppTokens.md),
                      _ServiceTile(
                        icon: Icons.health_and_safety_rounded,
                        title: _t('home_service_diagnostics'),
                        subtitle: _t('home_service_diagnostics_sub'),
                      ),
                      const SizedBox(height: AppTokens.md),
                      _ServiceTile(
                        icon: Icons.local_pharmacy_rounded,
                        title: _t('home_service_treatment'),
                        subtitle: _t('home_service_treatment_sub'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextAppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const _NextAppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.lg),
      child: Material(
        color: theme.brightness == Brightness.dark ? AppTokens.surface2Dark : AppTokens.surface2,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AppointmentScreen(),
            ),
          ),
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTokens.md),
                  decoration: BoxDecoration(
                    color: AppTokens.primaryContainer,
                    borderRadius:
                        BorderRadius.circular(AppTokens.radiusInput),
                  ),
                  child: const Icon(
                    Icons.event_rounded,
                    color: AppTokens.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppTokens.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t('home_next_appointment'),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppTokens.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppTokens.xs),
                      Text(
                        appointment.doctorName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM, HH:mm').format(appointment.dateTime),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DoctorMiniCard extends StatelessWidget {
  final Doctor doctor;

  const _DoctorMiniCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: AppTokens.md),
      padding: const EdgeInsets.all(AppTokens.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        border: Border.all(color: AppTokens.outline.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTokens.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppTokens.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name.split(' ').take(2).join(' '),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      doctor.specialization,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.sm),
          Row(
            children: [
              Icon(Icons.star_rounded, size: 16, color: AppTokens.warning),
              const SizedBox(width: 4),
              Text(
                doctor.rating.toStringAsFixed(1),
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ServiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppTokens.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        border: Border.all(color: AppTokens.outline.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTokens.md),
            decoration: BoxDecoration(
              color: AppTokens.primaryContainer,
              borderRadius:
                  BorderRadius.circular(AppTokens.radiusInput),
            ),
            child: Icon(icon, color: AppTokens.primary, size: 24),
          ),
          const SizedBox(width: AppTokens.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
