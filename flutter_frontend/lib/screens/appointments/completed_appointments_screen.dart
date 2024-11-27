import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';
import 'package:intl/intl.dart';
import 'appointment_details_screen.dart';

class CompletedAppointmentsScreen extends StatefulWidget {
  static const routeName = '/completed-appointments';

  const CompletedAppointmentsScreen({super.key});

  @override
  _CompletedAppointmentsScreenState createState() => _CompletedAppointmentsScreenState();
}

class _CompletedAppointmentsScreenState extends State<CompletedAppointmentsScreen> {
  late Future<List<Appointment>> _completedAppointmentsFuture;
  String? _workshopId;

  @override
  void initState() {
    super.initState();
    _completedAppointmentsFuture = _fetchCompletedAppointments();
  }

  Future<List<Appointment>> _fetchCompletedAppointments() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      throw Exception('Brak danych użytkownika');
    }

    bool isMechanic = user.roles.contains('mechanic');
    bool isAssignedToWorkshop = user.employeeProfiles.isNotEmpty;

    if (isMechanic && isAssignedToWorkshop) {
      // Pobierz workshopId z employeeProfiles
      final employee = user.employeeProfiles.first;
      _workshopId = employee.workshopId;

      List<Appointment> appointments = await AppointmentService.getAppointments(
        authProvider.accessToken!,
        _workshopId!,
      );

      // Filtruj tylko zakończone wizyty
      appointments = appointments
          .where((appointment) => appointment.status.toLowerCase() == 'completed')
          .toList();

      // Sortuj według daty zakończenia (najpierw najnowsze)
      appointments.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

      return appointments;
    } else {
      throw Exception('Nie masz uprawnień do wyświetlenia tej strony');
    }
  }

  Future<void> _refreshCompletedAppointments() async {
    setState(() {
      _completedAppointmentsFuture = _fetchCompletedAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zakończone Zlecenia'),
      ),
      body: FutureBuilder<List<Appointment>>(
        future: _completedAppointmentsFuture,
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
                      onPressed: _refreshCompletedAppointments,
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
                'Brak zakończonych zleceń do wyświetlenia',
                style: TextStyle(fontSize: 16),
              ),
            );
          } else {
            final completedAppointments = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshCompletedAppointments,
              child: ListView.separated(
                padding: const EdgeInsets.all(8.0),
                itemCount: completedAppointments.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  return _buildCompletedAppointmentItem(completedAppointments[index]);
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildCompletedAppointmentItem(Appointment appointment) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: const Icon(Icons.check_circle, size: 40, color: Colors.green),
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
