import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../employee/employee_details_screen.dart';

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      return const Center(child: Text('Brak danych użytkownika.'));
    }

    final workshopId = user.employeeProfiles.isNotEmpty
        ? user.employeeProfiles.first.workshopId
        : null;
    final employeeId = user.employeeProfiles.isNotEmpty
        ? user.employeeProfiles.first.id
        : null;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (workshopId != null && employeeId != null)
            ListTile(
              leading: const Icon(Icons.account_circle, color: Colors.purple),
              title: const Text('Pracownik'),
              subtitle: const Text('Pokaż swoje dane jako pracownik'),
              onTap: () {
                // Navigate to EmployeeDetailsScreen with current user's data
                Navigator.of(context).pushNamed(
                  EmployeeDetailsScreen.routeName,
                  arguments: {
                    'workshopId': workshopId,
                    'employeeId': employeeId,
                  },
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.blue),
            title: const Text('Informacje o aplikacji'),
            subtitle: const Text('Wersja: 1.0.0'),
            onTap: () {
              // Handle app info tap
            },
          ),
          ListTile(
            leading: const Icon(Icons.security, color: Colors.green),
            title: const Text('Polityka Prywatności'),
            subtitle: const Text('Zarządzaj swoimi danymi'),
            onTap: () {
              // Handle privacy policy tap
            },
          ),
          
        ],
      ),
    );
  }
}
