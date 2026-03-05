import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/core/api_client.dart';
import 'package:my_app/gen_l10n/app_localizations.dart';
import 'package:my_app/screens/services/service_detail_screen.dart';
import 'dart:convert';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key, this.categoryId, this.categoryName = ''});
  final int? categoryId;
  final String categoryName;

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = context.read<ApiClient>();
    final path = widget.categoryId != null
        ? '/services?category_id=${widget.categoryId}&limit=50'
        : '/services?limit=50';
    final r = await api.get(path);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _items = r.statusCode == 200 ? (jsonDecode(r.body) as List) : [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName.isNotEmpty ? widget.categoryName : l10n.service),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (context, i) {
                final s = _items[i] as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(s['name'] as String? ?? ''),
                    subtitle: Text('${s['price']} ₸ • ${s['provider_name'] ?? ''} • ${l10n.rating}: ${s['rating'] ?? 0}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServiceDetailScreen(serviceId: s['id'] as int),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
