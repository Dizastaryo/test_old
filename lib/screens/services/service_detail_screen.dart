import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/core/api_client.dart';
import 'package:my_app/core/auth_provider.dart';
import 'package:my_app/gen_l10n/app_localizations.dart';
import 'package:my_app/screens/booking/checkout_screen.dart';
import 'dart:convert';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({super.key, required this.serviceId});
  final int serviceId;

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  Map<String, dynamic>? _service;
  String? _selectedDate;
  String? _selectedSlot;
  bool _loading = true;
  List<dynamic> _slots = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await context.read<ApiClient>().get('/services/${widget.serviceId}');
    if (!mounted) return;
    setState(() {
      _loading = false;
      _service = r.statusCode == 200 ? (jsonDecode(r.body) as Map<String, dynamic>) : null;
    });
  }

  Future<void> _loadSlots(String date) async {
    final r = await context.read<ApiClient>().get('/services/${widget.serviceId}/availability?date=$date');
    if (!mounted) return;
    final data = r.statusCode == 200 ? jsonDecode(r.body) as Map<String, dynamic> : null;
    setState(() {
      _selectedDate = date;
      _slots = (data?['slots'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading || _service == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }
    final s = _service!;
    final locale = context.watch<AuthProvider>().user?.locale ?? 'ru';

    return Scaffold(
      appBar: AppBar(title: Text(s['name'] as String? ?? '')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${s['price']} ₸', style: Theme.of(context).textTheme.headlineSmall),
            if (s['duration_min'] != null) Text('${l10n.duration}: ${s['duration_min']} ${l10n.min}'),
            Text('${l10n.rating}: ${s['rating'] ?? 0} • ${s['review_count'] ?? 0} ${l10n.reviews}'),
            if (s['description'] != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(s['description'] as String)),
            const SizedBox(height: 16),
            Text(l10n.chooseDate, style: Theme.of(context).textTheme.titleMedium),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(7, (i) {
                  final d = DateTime.now().add(Duration(days: i));
                  final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('${d.day}.${d.month}'),
                      selected: _selectedDate == dateStr,
                      onSelected: (_) => _loadSlots(dateStr),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedDate != null) ...[
              Text(l10n.chooseTime, style: Theme.of(context).textTheme.titleMedium),
              Wrap(
                spacing: 8,
                children: (_slots as List<dynamic>).map((slot) {
                  final m = slot as Map<String, dynamic>;
                  final start = m['start_time'] as String? ?? '';
                  final available = m['available'] as bool? ?? false;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 8),
                    child: FilterChip(
                      label: Text(start),
                      selected: _selectedSlot == start,
                      onSelected: available ? (_) => setState(() => _selectedSlot = start) : null,
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _selectedDate != null && _selectedSlot != null
                  ? () {
                      final dtStart = '$_selectedDate $_selectedSlot:00';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(
                            serviceId: widget.serviceId,
                            service: s,
                            datetimeStart: dtStart,
                          ),
                        ),
                      );
                    }
                  : null,
              child: Text(l10n.book),
            ),
          ],
        ),
      ),
    );
  }
}
