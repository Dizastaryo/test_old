import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';
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
    HomeScreen(),
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
                const NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Главная'),
                const NavigationDestination(icon: Icon(Icons.medical_services_rounded), label: 'Врачи'),
                const NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Профиль'),
              ]
            : isDoctor
                ? [
                const NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Главная'),
                const NavigationDestination(icon: Icon(Icons.event_note_rounded), label: 'Приёмы'),
                const NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Профиль'),
                  ]
                : [
                    const NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Главная'),
                    const NavigationDestination(icon: Icon(Icons.event_available_rounded), label: 'Запись'),
                    const NavigationDestination(icon: Icon(Icons.groups_rounded), label: 'Врачи'),
                    const NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Профиль'),
                  ],
      ),
    );
  }
}
