import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';
import 'package:intl/intl.dart';
import '../../widgets/change_status_widget.dart';
import 'appointment_details_screen.dart';
import 'add_appointment_screen.dart';
import 'completed_appointments_screen.dart';
import 'canceled_appointments_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  static const routeName = '/appointments';

  const AppointmentsScreen({super.key});

  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  late Future<List<Appointment>> _scheduledAppointmentsFuture;
  String? _workshopId;

  @override
  void initState() {
    super.initState();
    _scheduledAppointmentsFuture = _fetchScheduledAppointments();
  }

  Future<List<Appointment>> _fetchScheduledAppointments() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      throw Exception('Brak danych użytkownika');
    }

    bool isMechanic = user.roles.contains('mechanic') || user.roles.contains('workshop_owner');
    bool isAssignedToWorkshop = user.employeeProfiles.isNotEmpty;

    if (isMechanic && isAssignedToWorkshop) {
      final employee = user.employeeProfiles.first;
      _workshopId = employee.workshopId;

      List<Appointment> appointments = await AppointmentService.getAppointments(
        authProvider.accessToken!,
        _workshopId!,
      );

      appointments = appointments.where((appointment) => appointment.status.toLowerCase() == 'scheduled').toList();
      appointments.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

      return appointments;
    } else {
      throw Exception('Nie masz uprawnień do wyświetlenia tej strony');
    }
  }

  Future<void> _refreshScheduledAppointments() async {
    setState(() {
      _scheduledAppointmentsFuture = _fetchScheduledAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktualne'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle),
            tooltip: 'Zakończone zlecenia',
            onPressed: _navigateToCompletedAppointments,
          ),
          IconButton(
            icon: const Icon(Icons.cancel),
            tooltip: 'Anulowane zlecenia',
            onPressed: _navigateToCanceledAppointments,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Dodaj zlecenie',
            onPressed: _navigateToAddAppointment,
          ),
        ],
      ),
      body: FutureBuilder<List<Appointment>>(
        future: _scheduledAppointmentsFuture,
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
                      onPressed: _refreshScheduledAppointments,
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
                'Brak zaplanowanych zleceń.',
                style: TextStyle(fontSize: 16),
              ),
            );
          } else {
            final appointments = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshScheduledAppointments,
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
                'Rejestracja: ${appointment.vehicle.licensePlate}',
                style: const TextStyle(fontSize: 16),
              ),
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
        onLongPress: () => _showChangeStatusPopup(appointment),
      ),
    );
  }

  void _showChangeStatusPopup(Appointment appointment) {
  showDialog(
    context: context,
    builder: (context) {
      return ChangeStatusWidget(
        appointment: appointment,
        workshopId: _workshopId!,
        onStatusChanged: _refreshScheduledAppointments,
      );
    },
  );
}


 void _updateAppointmentStatus(Appointment appointment, String newStatus) async {
  try {
    await AppointmentService.updateAppointmentStatus(
      appointmentId: appointment.id,
      status: newStatus,
      accessToken: Provider.of<AuthProvider>(context, listen: false).accessToken!,
      workshopId: _workshopId!,
    );
    _refreshScheduledAppointments();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Nie udało się zmienić statusu: $e')),
    );
  }
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

  void _navigateToAddAppointment() async {
    final result = await Navigator.pushNamed(
      context,
      AddAppointmentScreen.routeName,
    );

    if (result == true) {
      _refreshScheduledAppointments();
    }
  }

  void _navigateToCompletedAppointments() {
    Navigator.pushNamed(context, CompletedAppointmentsScreen.routeName);
  }

  void _navigateToCanceledAppointments() {
    Navigator.pushNamed(context, CanceledAppointmentsScreen.routeName);
  }
}