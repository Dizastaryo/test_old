import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/core/api_client.dart';
import 'package:my_app/core/auth_provider.dart';
import 'package:my_app/app.dart';
import 'package:my_app/gen_l10n/app_localizations.dart';

void main() {
  runApp(const BookingApp());
}

class BookingApp extends StatelessWidget {
  const BookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiClient(baseUrl: 'http://10.0.2.2:8000');
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: api),
        ChangeNotifierProvider(create: (_) => AuthProvider(api)),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final locale = auth.locale();
          return MaterialApp(
            title: 'Жергілікті қызметтер',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
              useMaterial3: true,
            ),
            darkTheme: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(primary: Colors.teal.shade300),
            ),
            locale: locale == 'kk' ? const Locale('kk') : const Locale('ru'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
