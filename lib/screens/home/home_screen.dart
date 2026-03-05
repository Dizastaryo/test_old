import 'package:flutter/material.dart';
import 'package:my_app/gen_l10n/app_localizations.dart';
import 'package:my_app/screens/categories/categories_screen.dart';
import 'package:my_app/screens/bookings/my_bookings_screen.dart';
import 'package:my_app/screens/profile/profile_screen.dart';
import 'package:my_app/screens/home/home_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _tabs = [
    HomeTab(),
    CategoriesScreen(),
    MyBookingsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home), label: l10n.home),
          NavigationDestination(icon: const Icon(Icons.category), label: l10n.categories),
          NavigationDestination(icon: const Icon(Icons.book_online), label: l10n.myBookings),
          NavigationDestination(icon: const Icon(Icons.person), label: l10n.profile),
        ],
      ),
    );
  }
}
