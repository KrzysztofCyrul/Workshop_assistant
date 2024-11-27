import 'package:flutter/material.dart';
import 'appointments_screen.dart';
import 'completed_appointments_screen.dart';

class HomeAppointmentsScreen extends StatefulWidget {
  static const routeName = '/home-appointments';

  const HomeAppointmentsScreen({super.key});

  @override
  _HomeAppointmentsScreenState createState() => _HomeAppointmentsScreenState();
}

class _HomeAppointmentsScreenState extends State<HomeAppointmentsScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AppointmentsScreen(),
    const CompletedAppointmentsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Zlecenia',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Zakończone',
          ),
        ],
      ),
    );
  }
}
