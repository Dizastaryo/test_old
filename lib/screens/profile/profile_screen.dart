import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/core/auth_provider.dart';
import 'package:my_app/gen_l10n/app_localizations.dart';
import 'package:my_app/screens/auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const Scaffold(body: Center(child: Text('Not logged in')));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(user.name ?? user.phone ?? ''),
            subtitle: Text(user.phone ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.stars),
            title: Text(l10n.bonusPoints),
            trailing: Text('${user.bonusPoints}'),
          ),
          const Divider(),
          ListTile(leading: const Icon(Icons.language), title: Text(l10n.language), trailing: Text(user.locale == 'kk' ? 'Қазақша' : 'Русский')),
          ListTile(leading: const Icon(Icons.dark_mode), title: Text(l10n.darkTheme)),
          ListTile(leading: const Icon(Icons.notifications), title: Text(l10n.notifications)),
          ListTile(leading: const Icon(Icons.help), title: Text(l10n.support)),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n.logout),
            onTap: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (r) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
