import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';
import 'appointment_screen.dart';
import 'doctors_screen.dart';
import 'profile_screen.dart';
import 'ai_chat_screen.dart';

/// Main shell: NavigationBar (M3) с 5 вкладками. Drawer убран — доп. разделы в Профиле.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AppointmentScreen(),
    const AIChatScreen(),
    const DoctorsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final unread = appProvider.unreadNotificationsCount;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
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
