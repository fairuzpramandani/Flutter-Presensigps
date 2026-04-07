import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final List<String> routes = const [
    '/dashboard',
    '/presensi/histori',
    '/izin/list', 
    '/profile',
  ];

  const BottomNavigation({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed, 
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Histori'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Izin'), 
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ), 
      ],
      
      onTap: (index) {
        if (index != currentIndex) {
          Navigator.pushReplacementNamed(context, routes[index]);
        }
      },
    );
  }
}