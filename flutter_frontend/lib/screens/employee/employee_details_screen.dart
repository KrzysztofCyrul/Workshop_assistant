import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employee_provider.dart';

class EmployeeDetailsScreen extends StatelessWidget {
  static const routeName = '/employee-details';

  final String workshopId;
  final String employeeId;

  const EmployeeDetailsScreen({
    super.key,
    required this.workshopId,
    required this.employeeId,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;

    if (accessToken == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Szczegóły Pracownika'),
        ),
        body: const Center(
          child: Text('Brak dostępu do danych użytkownika.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły Pracownika'),
      ),
      body: FutureBuilder(
        future: Provider.of<EmployeeProvider>(context, listen: false).fetchEmployeeDetails(
          accessToken,
          workshopId,
          employeeId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          } else {
            return Consumer<EmployeeProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (provider.errorMessage != null) {
                  return Center(child: Text(provider.errorMessage!));
                } else if (provider.employee == null) {
                  return const Center(child: Text('Nie znaleziono pracownika.'));
                } else {
                  final employee = provider.employee!;
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Szczegóły Pracownika',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const Divider(),
                            _buildDetailRow('ID', employee.id),
                            _buildDetailRow('Użytkownik ID', employee.userId),
                            _buildDetailRow('Warsztat ID', employee.workshopId),
                            _buildDetailRow('Stanowisko', employee.position),
                            _buildDetailRow('Status', employee.status),
                            _buildDetailRow('Data Zatrudnienia', employee.hireDate),
                            _buildDetailRow(
                              'Wynagrodzenie',
                              employee.salary != null ? '${employee.salary} PLN' : 'Brak',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
