import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../workshop/workshop_list_screen.dart';
import '../appointments/add_appointment_screen.dart';
import '../clients/clients_screen.dart';
import '../appointments/appointments_screen.dart';
import '../employee/employee_details_screen.dart';
import '../vehicles/vehicle_list_screen.dart';
import '../vehicles/client_vehicle_list_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final workshopId = authProvider.user?.employeeProfiles.first.workshopId;
    final employeeId = authProvider.user?.employeeProfiles.first.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Główny'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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

  Widget _buildWorkshopActions(BuildContext context, String workshopId, String? employeeId) {
    final actions = [
      {
        'title': 'Dodaj Zlecenie',
        'icon': Icons.add_circle_outline,
        'action': () => _navigateToAddAppointment(context),
      },
      {
        'title': 'Klienci',
        'icon': Icons.people,
        'action': () => _navigateToClients(context),
      },
      {
        'title': 'Zlecenia',
        'icon': Icons.assignment,
        'action': () => _navigateToAppointments(context),
      },
      {
        'title': 'Szczegóły Pracownika',
        'icon': Icons.person,
        'action': employeeId != null
            ? () => _navigateToEmployeeDetails(context, workshopId, employeeId)
            : null,
      },
      {
        'title': 'Lista Pojazdów',
        'icon': Icons.directions_car,
        'action': () => _navigateToVehicleList(context, workshopId),
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

  void _navigateToEmployeeDetails(BuildContext context, String workshopId, String employeeId) {
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

  void _navigateToClientVehicleList(BuildContext context, String workshopId, String clientId) {
    Navigator.of(context).pushNamed(
      ClientVehicleListScreen.routeName,
      arguments: {
        'workshopId': workshopId,
        'clientId': clientId,
      },
    );
  }
}