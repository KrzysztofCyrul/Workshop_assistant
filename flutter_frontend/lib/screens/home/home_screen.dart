import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../appointments/appointments_screen.dart';
import '../workshop/workshop_list_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null) {
      bool isMechanic = user.roles.contains('mechanic');
      bool isAssignedToWorkshop = user.employeeProfiles.any(
        (employee) => employee.status == 'APPROVED',
      );

      if (isMechanic) {
        if (isAssignedToWorkshop) {
          // Mechanik przypisany do warsztatu - przekieruj na ekran zleceń
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(
                context, AppointmentsScreen.routeName);
          });
        } else {
          // Mechanik nieprzypisany do warsztatu - przekieruj do listy warsztatów
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(
                context, WorkshopListScreen.routeName);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Możesz zwrócić pusty Scaffold lub ekran ładowania
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
