import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../services/lang_service.dart';
import '../theme/app_tokens.dart';
import '../widgets/hero_header.dart';

String _t(String key) => LangService.getString(key);

/// Главный экран для врача: приветствие и сводка по приёмам на сегодня.
class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _todayCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTodayCount());
  }

  Future<void> _loadTodayCount() async {
    if (!mounted) return;
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final userId = appProvider.currentUser?.id;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    final uid = int.tryParse(userId) ?? 0;
    try {
      final doctor = await ApiService.medkEnsureDoctor(
        userId: uid,
        fullName: appProvider.currentUser?.name ?? 'Врач',
      );
      final doctorId = doctor['id'] as int?;
      if (doctorId == null) {
        setState(() => _loading = false);
        return;
      }
      final list = await ApiService.medkListAppointments(doctorId: doctorId);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      int count = 0;
      for (final e in list) {
        final a = e as Map<String, dynamic>;
        final at = a['scheduled_at'];
        if (at != null) {
          try {
            final dt = DateTime.parse(at.toString());
            if (DateTime(dt.year, dt.month, dt.day) == today &&
                (a['status'] == 'scheduled' || a['status'] == 'in_progress')) {
              count++;
            }
          } catch (_) {}
        }
      }
      if (mounted) setState(() {
        _todayCount = count;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final user = appProvider.currentUser;
    final name = user?.name.split(' ').first ?? 'Врач';
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          HeroHeader(
            expandedHeight: 140,
            title: '${_t('home_welcome')}$name!',
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppTokens.lg),
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(AppTokens.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('home_doctor_today'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_loading)
                            const SizedBox(
                              height: 32,
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          else
                            Text(
                              '$_todayCount ${_t('home_doctor_appointments_count')}',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTokens.primary,
                              ),
                            ),
                          const SizedBox(height: 16),
                          Text(
                            _t('home_doctor_go_appointments'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
