import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';

void main() {
  runApp(const QamqorClinicApp());
}

class QamqorClinicApp extends StatelessWidget {
  const QamqorClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qamqor Clinic',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade700,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const AuthScreen(),
    );
  }
}
