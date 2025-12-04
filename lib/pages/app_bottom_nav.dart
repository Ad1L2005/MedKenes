// lib/pages/app_bottom_nav.dart
import 'package:flutter/material.dart';
import 'home_main_page.dart';
import 'health_home_page.dart';
import 'services_home_page.dart';
import 'profile_home_page.dart';

class AppBottomNav extends StatefulWidget {
  const AppBottomNav({super.key});
  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeMainPage(),
    HealthHomePage(),
    ServicesHomePage(),
    ProfileHomePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 20)],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF06B6D4),
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Басты"),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Денсаулық"),
            BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: "Қызметтер"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Профиль"),
          ],
        ),
      ),
    );
  }
}