// lib/screens/appointments/appointments_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';
import 'package:intl/intl.dart';
import 'appointment_details_screen.dart';
import 'add_appointment_screen.dart';
import 'completed_appointments_screen.dart'; // Import nowego ekranu

class AppointmentsScreen extends StatefulWidget {
  static const routeName = '/appointments';

  const AppointmentsScreen({super.key});

  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  late Future<List<Appointment>> _appointmentsFuture;
  String? _workshopId;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _fetchAppointments();
  }

  Future<List<Appointment>> _fetchAppointments() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      throw Exception('Brak danych użytkownika');
    }

    bool isMechanic = user.roles.contains('mechanic') || user.roles.contains('workshop_owner');
    bool isAssignedToWorkshop = user.employeeProfiles.isNotEmpty;

    if (isMechanic && isAssignedToWorkshop) {
      // Pobierz workshopId z employeeProfiles
      final employee = user.employeeProfiles.first;
      _workshopId = employee.workshopId;

      List<Appointment> appointments = await AppointmentService.getAppointments(
        authProvider.accessToken!,
        _workshopId!,
      );

      // Filtruj tylko niezakończone wizyty
      appointments = appointments.where((appointment) => appointment.status.toLowerCase() != 'completed').toList();

      // Sortuj zlecenia zgodnie z wymaganiami
      appointments = _sortAppointments(appointments);

      return appointments;
    } else {
      throw Exception('Nie masz uprawnień do wyświetlenia tej strony');
    }
  }

  List<Appointment> _sortAppointments(List<Appointment> appointments) {
    DateTime now = DateTime.now();

    appointments.sort((a, b) {
      // Zaległe zadania
      bool aOverdue = a.scheduledTime.isBefore(now) && a.status.toLowerCase() != 'completed';
      bool bOverdue = b.scheduledTime.isBefore(now) && b.status.toLowerCase() != 'completed';

      if (aOverdue && !bOverdue) return -1;
      if (!aOverdue && bOverdue) return 1;

      // Dzisiejsze zadania
      bool aToday = _isSameDay(a.scheduledTime, now);
      bool bToday = _isSameDay(b.scheduledTime, now);

      if (aToday && !bToday) return -1;
      if (!aToday && bToday) return 1;

      // Przyszłe zadania
      return a.scheduledTime.compareTo(b.scheduledTime);
    });

    return appointments;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> _refreshAppointments() async {
    setState(() {
      _appointmentsFuture = _fetchAppointments();
    });
  }

  void _navigateToAddAppointment() async {
    final result = await Navigator.pushNamed(
      context,
      AddAppointmentScreen.routeName,
    );

    if (result == true) {
      // Jeśli zlecenie zostało dodane, odśwież listę
      _refreshAppointments();
    }
  }

  void _navigateToCompletedAppointments() {
    Navigator.pushNamed(context, CompletedAppointmentsScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zlecenia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle),
            tooltip: 'Zakończone zlecenia',
            onPressed: _navigateToCompletedAppointments,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Dodaj zlecenie',
            onPressed: _navigateToAddAppointment,
          ),
        ],
      ),
      body: FutureBuilder<List<Appointment>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _refreshAppointments,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Ponów próbę'),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Brak zleceń do wyświetlenia',
                style: TextStyle(fontSize: 16),
              ),
            );
          } else {
            final appointments = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshAppointments,
              child: ListView.separated(
                padding: const EdgeInsets.all(8.0),
                itemCount: appointments.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  return _buildAppointmentItem(appointments[index]);
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddAppointment,
        child: const Icon(Icons.add),
        tooltip: 'Dodaj zlecenie',
      ),
    );
  }

  Widget _buildAppointmentItem(Appointment appointment) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: const Icon(Icons.event, size: 40, color: Colors.blue),
        title: Text(
          'Wizyta: ${appointment.vehicle.make} ${appointment.vehicle.model}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Klient: ${appointment.client.firstName} ${appointment.client.lastName}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Data: ${DateFormat('dd-MM-yyyy HH:mm').format(appointment.scheduledTime.toLocal())}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Status: ${appointment.status}',
                style: TextStyle(
                  fontSize: 14,
                  color: _getStatusColor(appointment.status),
                ),
              ),
              Text(
                'Notatki: ${appointment.notes ?? 'Brak'}',
                style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppointmentDetailsScreen.routeName,
            arguments: {
              'workshopId': _workshopId!,
              'appointmentId': appointment.id,
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
