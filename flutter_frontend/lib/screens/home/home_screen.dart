import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../appointments/add_appointment_screen.dart';
import '../clients/clients_screen.dart';


class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  HomeScreen({Key? key}) : super(key: key);

  void _navigateToAddAppointment(BuildContext context) {
    Navigator.of(context).pushNamed(AddAppointmentScreen.routeName).then((result) {
      if (result == true) {
        // Opcjonalnie odśwież listę zleceń lub wykonaj inne działania
      }
    });
  }

  void _navigateToClients(BuildContext context) {
    Navigator.of(context).pushNamed(ClientsScreen.routeName);
  }

  void _navigateToVehicles(BuildContext context) {
    Navigator.of(context).pushNamed('/vehicles');
  }

  void _navigateToAppointments(BuildContext context) {
    Navigator.of(context).pushNamed('/appointments');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddAppointment(context),
          ),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => _navigateToClients(context), // Przycisk do klientów
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _navigateToAddAppointment(context),
              child: const Text('Dodaj Zlecenie'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToClients(context),
              child: const Text('Klienci'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToVehicles(context),
              child: const Text('Pojazdy'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToAppointments(context),
              child: const Text('Zlecenia'),
            ),
            // Add more buttons for other screens as needed
          ],
        ),
      ),
    );
  }
}
