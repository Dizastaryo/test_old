import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/core/api_client.dart';
import 'package:my_app/gen_l10n/app_localizations.dart';
import 'dart:convert';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final r = await context.read<ApiClient>().get('/bookings/my');
    if (!mounted) return;
    setState(() {
      _loading = false;
      _bookings = r.statusCode == 200 ? (jsonDecode(r.body) as List) : [];
    });
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'pending': return 'Ожидает';
      case 'confirmed': return 'Подтверждена';
      case 'completed': return 'Завершена';
      case 'cancelled': return 'Отменена';
      default: return status ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final upcoming = _bookings.where((b) => ['pending', 'confirmed'].contains(b['status'])).toList();
    final past = _bookings.where((b) => b['status'] == 'completed').toList();
    final cancelled = _bookings.where((b) => b['status'] == 'cancelled').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myBookings),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.upcoming),
            Tab(text: l10n.past),
            Tab(text: l10n.cancelled),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _list(upcoming, l10n),
                _list(past, l10n),
                _list(cancelled, l10n),
              ],
            ),
    );
  }

  Widget _list(List<dynamic> items, AppLocalizations l10n) {
    if (items.isEmpty) return Center(child: Text(l10n.loading));
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final b = items[i] as Map<String, dynamic>;
          final dt = b['datetime_start'];
          final dateStr = dt != null ? dt.toString().substring(0, 16) : '';
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(b['service_name'] as String? ?? ''),
              subtitle: Text('$dateStr • ${_statusLabel(b['status'] as String?)} • ${b['total_price']} ₸'),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
