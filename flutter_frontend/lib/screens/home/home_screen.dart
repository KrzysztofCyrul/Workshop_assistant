import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../workshop/workshop_list_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    bool isMechanic = user.roles.contains('mechanic');
    bool isAssignedToWorkshop = user.employeeProfiles.any(
   (employee) => employee.status == 'APPROVED',
    );

    if (isMechanic) {
      if (isAssignedToWorkshop) {
        // Mechanik przypisany do warsztatu - wyświetl standardowy ekran główny
        return Scaffold(
          appBar: AppBar(
            title: Text('Strona główna'),
          ),
          body: Center(
            child: Text('Witaj w aplikacji warsztatu samochodowego!'),
          ),
        );
      } else {
        // Mechanik nieprzypisany do warsztatu - wyświetl listę warsztatów
        return WorkshopListScreen();
      }
    } else {
      // Inne role - wyświetl standardowy ekran główny
      return Scaffold(
        appBar: AppBar(
          title: Text('Strona główna'),
        ),
        body: Center(
          child: Text('Witaj w aplikacji warsztatu samochodowego!'),
        ),
      );
    }
  }
}
