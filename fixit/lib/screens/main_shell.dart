import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'bookings_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  final String city;
  final int initialIndex;

  const MainShell({
    super.key,
    required this.city,
    this.initialIndex = 0,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;
  late String _currentCity;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _currentCity = widget.city;
  }

  void onCityChanged(String newCity) {
    setState(() {
      _currentCity = newCity;
    });
  }

  void switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            city: _currentCity,
            onCityChanged: onCityChanged,
            onGoToBookings: () => switchTab(1),
          ),
          BookingsScreen(
            city: _currentCity,
            onExploreServices: () => switchTab(0),
          ),
          ProfileScreen(
            city: _currentCity,
            onCityChanged: onCityChanged,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: switchTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
