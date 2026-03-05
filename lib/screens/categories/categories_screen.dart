import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/core/api_client.dart';
import 'package:my_app/core/auth_provider.dart';
import 'package:my_app/gen_l10n/app_localizations.dart';
import 'package:my_app/screens/services/service_list_screen.dart';
import 'dart:convert';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<dynamic> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await context.read<ApiClient>().get('/categories');
    if (!mounted) return;
    setState(() {
      _loading = false;
      _categories = r.statusCode == 200 ? (jsonDecode(r.body) as List) : [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = context.watch<AuthProvider>().user?.locale ?? 'ru';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.categories)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, i) {
                final c = _categories[i] as Map<String, dynamic>;
                final name = locale == 'kk' ? (c['name_kk'] ?? c['name_ru']) : (c['name_ru'] ?? c['name_kk']);
                return Card(
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServiceListScreen(categoryId: c['id'] as int, categoryName: name as String),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.category, size: 48, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 8),
                          Text(name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
