import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employee_provider.dart';

class EmployeeDetailsScreen extends StatelessWidget {
  static const routeName = '/employee-details';

  final String workshopId;
  final String employeeId;

  const EmployeeDetailsScreen({Key? key, required this.workshopId, required this.employeeId}) : super(key: key);

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${employee.id}', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('Użytkownik ID: ${employee.userId}'),
                        const SizedBox(height: 8),
                        Text('Warsztat ID: ${employee.workshopId}'),
                        const SizedBox(height: 8),
                        Text('Stanowisko: ${employee.position}'),
                        const SizedBox(height: 8),
                        Text('Status: ${employee.status}'),
                        const SizedBox(height: 8),
                        Text('Data Zatrudnienia: ${employee.hireDate}'),
                        const SizedBox(height: 8),
                        Text('Wynagrodzenie: ${employee.salary ?? 'Brak'}'),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: employee.status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
                            DropdownMenuItem(value: 'APPROVED', child: Text('Approved')),
                            DropdownMenuItem(value: 'REJECTED', child: Text('Rejected')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              _updateEmployeeStatus(context, accessToken, workshopId, employeeId, value);
                            }
                          },
                        ),
                      ],
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

  Future<void> _updateEmployeeStatus(BuildContext context, String accessToken, String workshopId, String employeeId, String status) async {
    try {
      await Provider.of<EmployeeProvider>(context, listen: false).updateEmployeeStatus(
        accessToken,
        workshopId,
        employeeId,
        status,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas aktualizacji statusu: $e')),
      );
    }
  }
}