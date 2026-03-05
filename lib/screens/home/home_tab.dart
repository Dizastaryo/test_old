import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/core/auth_provider.dart';
import 'package:my_app/core/api_client.dart';
import 'package:my_app/gen_l10n/app_localizations.dart';
import 'package:my_app/screens/services/service_list_screen.dart';
import 'dart:convert';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<dynamic> _categories = [];
  List<dynamic> _recommended = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = context.read<ApiClient>();
    try {
      final cr = await api.get('/categories');
      final sr = await api.get('/services?sort=rating&limit=5');
      if (!mounted) return;
      setState(() {
        _categories = cr.statusCode == 200 ? (jsonDecode(cr.body) as List) : [];
        _recommended = sr.statusCode == 200 ? (jsonDecode(sr.body) as List) : [];
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().user;
    final locale = user?.locale ?? 'ru';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (user != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text('${locale == 'kk' ? 'Сәлем' : 'Привет'}, ${user.name ?? user.phone ?? ""}',
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                    Text(l10n.categories, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, i) {
                          final c = _categories[i] as Map<String, dynamic>;
                          final name = locale == 'kk' ? (c['name_kk'] ?? c['name_ru']) : (c['name_ru'] ?? c['name_kk']);
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ServiceListScreen(categoryId: c['id'] as int, categoryName: name as String),
                                ),
                              ),
                              child: Card(
                                child: Container(
                                  width: 100,
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.category, color: Theme.of(context).colorScheme.primary),
                                      const SizedBox(height: 4),
                                      Text(name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.recommended, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    ...(_recommended.map((s) {
                      final m = s as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(m['name'] as String? ?? ''),
                          subtitle: Text('${m['price']} ₸ • ${m['provider_name'] ?? ''}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {},
                        ),
                      );
                    })),
                  ],
                ),
              ),
            ),
    );
  }
}
