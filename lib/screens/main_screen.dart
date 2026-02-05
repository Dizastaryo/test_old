import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/lang_service.dart';
import 'home_screen.dart';
import 'doctor_home_screen.dart';
import 'appointment_screen.dart';
import 'doctors_screen.dart';
import 'profile_screen.dart';
import 'doctor_appointments_screen.dart';
import 'admin_doctors_screen.dart';

/// Main shell: админ — Главная, Врачи, Профиль; врач — Главная, Приёмы, Профиль; пациент — Главная, Запись, Врачи, Профиль.
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
    DoctorsScreen(),
    ProfileScreen(),
  ];

  static const _doctorScreens = [
    DoctorHomeScreen(),
    DoctorAppointmentsScreen(),
    ProfileScreen(),
  ];

  static const _adminScreens = [
    HomeScreen(),
    AdminDoctorsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isAdmin = appProvider.currentUser?.isAdmin ?? false;
    final isDoctor = appProvider.currentUser?.isDoctor ?? false;
    final screens = isAdmin ? _adminScreens : (isDoctor ? _doctorScreens : _patientScreens);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex.clamp(0, screens.length - 1),
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex.clamp(0, screens.length - 1),
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: isAdmin
            ? [
                NavigationDestination(icon: const Icon(Icons.home_rounded), label: LangService.getString('nav_home')),
                NavigationDestination(icon: const Icon(Icons.medical_services_rounded), label: LangService.getString('nav_doctors')),
                NavigationDestination(icon: const Icon(Icons.person_rounded), label: LangService.getString('nav_profile')),
              ]
            : isDoctor
                ? [
                NavigationDestination(icon: const Icon(Icons.home_rounded), label: LangService.getString('nav_home')),
                NavigationDestination(icon: const Icon(Icons.event_note_rounded), label: LangService.getString('nav_appointments')),
                NavigationDestination(icon: const Icon(Icons.person_rounded), label: LangService.getString('nav_profile')),
                  ]
                : [
                    NavigationDestination(icon: const Icon(Icons.home_rounded), label: LangService.getString('nav_home')),
                    NavigationDestination(icon: const Icon(Icons.event_available_rounded), label: LangService.getString('nav_booking')),
                    NavigationDestination(icon: const Icon(Icons.groups_rounded), label: LangService.getString('nav_doctors')),
                    NavigationDestination(icon: const Icon(Icons.person_rounded), label: LangService.getString('nav_profile')),
                  ],
      ),
    );
  }
}
