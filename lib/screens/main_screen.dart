import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';
import 'appointment_screen.dart';
import 'doctors_screen.dart';
import 'profile_screen.dart';
import 'ai_chat_screen.dart';
import 'doctor_model_predict_screen.dart';

/// Main shell: для врача — Главная, Модель, Профиль; для пациента — 5 вкладок (Чат на заглушке).
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const _patientScreens = [
    HomeScreen(),
    AppointmentScreen(),
    AIChatScreen(),
    DoctorsScreen(),
    ProfileScreen(),
  ];

  static const _doctorScreens = [
    HomeScreen(),
    DoctorModelPredictScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDoctor = appProvider.currentUser?.isDoctor ?? false;
    final screens = isDoctor ? _doctorScreens : _patientScreens;
    final unread = appProvider.unreadNotificationsCount;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex.clamp(0, screens.length - 1),
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex.clamp(0, screens.length - 1),
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: isDoctor
            ? [
                const NavigationDestination(
                  icon: Icon(Icons.home_rounded),
                  label: 'Главная',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.psychology_rounded),
                  label: 'Модель',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_rounded),
                  label: 'Профиль',
                ),
              ]
            : [
                const NavigationDestination(
                  icon: Icon(Icons.home_rounded),
                  label: 'Главная',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.event_available_rounded),
                  label: 'Запись',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: false,
                    child: const Icon(Icons.chat_bubble_rounded),
                  ),
                  label: 'Чат',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.groups_rounded),
                  label: 'Врачи',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_rounded),
                  label: 'Профиль',
                ),
              ],
      ),
    );
  }
}
