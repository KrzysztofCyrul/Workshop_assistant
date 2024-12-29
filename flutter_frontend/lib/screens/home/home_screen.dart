import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../workshop/add_workshop_screen.dart';
import '../workshop/workshop_list_screen.dart';
import '../vehicles/add_vehicle_screen.dart';
import '../appointments/add_appointment_screen.dart';
import '../clients/clients_screen.dart';
import '../appointments/appointments_screen.dart';
import '../employee/employee_details_screen.dart';
import '../vehicles/vehicle_list_screen.dart';
import '../settings/settings_screen.dart';
import '../clients/add_client_screen.dart';
import '../clients/edit_client_screen.dart ';
import '../appointments/appointment_calendar_screen.dart';
import '../relationships/client_statistics_screen.dart';
import '../relationships/send_email_screen.dart';


class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final employeeProfiles = user.employeeProfiles;
    final isWorkshopOwner = user.roles.contains('workshop_owner');

    // Redirect logic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isWorkshopOwner && employeeProfiles.isEmpty) {
        Navigator.of(context).pushReplacementNamed(CreateWorkshopScreen.routeName);
      } else if (employeeProfiles.isEmpty) {
        Navigator.of(context).pushReplacementNamed(WorkshopListScreen.routeName);
      }
    });

    // Handle mechanics or employees with profiles
    if (employeeProfiles.isEmpty) {
      return const Scaffold(); // Prevents errors during redirection
    }

    final workshopId = employeeProfiles.first.workshopId;
    final employeeId = employeeProfiles.first.id;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => _navigateToSettings(context),
        ),
        title: const Text('Panel Główny'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _navigateToCalendar(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // ignore: unnecessary_null_comparison
        child: workshopId == null
            ? _buildNoWorkshopView(context)
            : _buildWorkshopActions(context, workshopId, employeeId),
      ),
    );
  }

  Widget _buildNoWorkshopView(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _navigateToWorkshopList(context),
        icon: const Icon(Icons.work),
        label: const Text('Lista Warsztatów'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        ),
      ),
    );
  }

  Widget _buildWorkshopActions(
      BuildContext context, String workshopId, String? employeeId) {
    final actions = [
      {
        'title': 'Dodaj Zlecenie',
        'icon': Icons.add_circle_outline,
        'action': () => _navigateToAddAppointment(context),
      },
      {
        'title': 'Zlecenia',
        'icon': Icons.assignment,
        'action': () => _navigateToAppointments(context),
      },
      {
        'title': 'Dodaj Klienta',
        'icon': Icons.person_add,
        'action': () => _navigateToAddClient(context),
      },
      {
        'title': 'Klienci',
        'icon': Icons.people,
        'action': () => _navigateToClients(context),
      },
      {
        'title': 'Dodaj Pojazd',
        'icon': Icons.directions_car,
        'action': () => _navigateToAddVehicle(context, workshopId, ''),
      },
      {
        'title': 'Lista Pojazdów',
        'icon': Icons.directions_car,
        'action': () => _navigateToVehicleList(context, workshopId),
      },
      {
        'title': 'Statystyki Klientów',
        'icon': Icons.person,
        'action': () => _navigateToClientStatistics(context),
      },
      {
        'title': 'Wyślij E-mail',
        'icon': Icons.email,
        'action': () => _navigateToSendEmail(context, workshopId),
      },
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.2,
      ),
      itemCount: actions.length,
      itemBuilder: (ctx, index) {
        final action = actions[index];
        return ElevatedButton(
          onPressed: action['action'] as void Function()?,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                action['icon'] as IconData?,
                size: 40.0,
                color: Colors.white,
              ),
              const SizedBox(height: 8.0),
              Text(
                action['title'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToWorkshopList(BuildContext context) {
    Navigator.of(context).pushNamed(WorkshopListScreen.routeName);
  }

  void _navigateToAddAppointment(BuildContext context) {
    Navigator.of(context).pushNamed(AddAppointmentScreen.routeName);
  }

  void _navigateToClients(BuildContext context) {
    Navigator.of(context).pushNamed(ClientsScreen.routeName);
  }

  void _navigateToAppointments(BuildContext context) {
    Navigator.of(context).pushNamed(AppointmentsScreen.routeName);
  }

  void _navigateToEmployeeDetails(
      BuildContext context, String workshopId, String employeeId) {
    Navigator.of(context).pushNamed(
      EmployeeDetailsScreen.routeName,
      arguments: {
        'workshopId': workshopId,
        'employeeId': employeeId,
      },
    );
  }

  void _navigateToVehicleList(BuildContext context, String workshopId) {
    Navigator.of(context).pushNamed(
      VehicleListScreen.routeName,
      arguments: {
        'workshopId': workshopId,
      },
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).pushNamed(SettingsScreen.routeName);
  }

  void _navigateToAddClient(BuildContext context) {
    Navigator.of(context).pushNamed(AddClientScreen.routeName);
  }

  void _navigateToAddVehicle(
      BuildContext context, String workshopId, String clientId) {
    Navigator.of(context).pushNamed(
      AddVehicleScreen.routeName,
      arguments: {
        'workshopId': workshopId,
        'clientId': clientId,
      },
    );
  }

  void _navigateToCalendar(BuildContext context) {
    Navigator.of(context).pushNamed(AppointmentCalendarScreen.routeName);
  }

  void _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.logout();
      Navigator.of(context).pushReplacementNamed('/login'); // Navigate to login screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd wylogowania: $e')),
      );
    }
  }

  void _navigateToClientStatistics(BuildContext context) {
    Navigator.of(context).pushNamed(ClientsStatisticsScreen.routeName);
  }

  void _navigateToSendEmail(BuildContext context, String workshopId) {
    Navigator.of(context).pushNamed(
      SendEmailScreen.routeName,
      arguments: {
        'workshopId': workshopId,
      },
    );
  }

  void _navigateToEditClient(BuildContext context, String workshopId, String clientId) {
    Navigator.of(context).pushNamed(
      EditClientScreen.routeName,
      arguments: {
        'workshopId': workshopId,
        'clientId': clientId,
      },
    );
  }
}
