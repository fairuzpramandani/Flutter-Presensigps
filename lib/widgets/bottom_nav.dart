import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final List<String> routes = const [
    '/',
    '/presensi/histori',
    '/izin/list',
    '/settings',
  ];

  const BottomNavigation({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed, 
      
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Histori'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Izin'), 
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'), 
      ],
      
      onTap: (index) {
        if (index != currentIndex) {
          Navigator.pushNamed(context, routes[index]);
        }
      },
    );
  }
}