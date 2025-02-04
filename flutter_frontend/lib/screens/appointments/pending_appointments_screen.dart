import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';
import 'package:intl/intl.dart';
import '../../widgets/change_status_widget.dart';
import 'appointment_details_screen.dart';

class PendingAppointmentsScreen extends StatefulWidget {
  static const routeName = '/pending-appointments';

  const PendingAppointmentsScreen({super.key});

  @override
  _PendingAppointmentsScreenState createState() => _PendingAppointmentsScreenState();
}

class _PendingAppointmentsScreenState extends State<PendingAppointmentsScreen> {
  late Future<List<Appointment>> _pendingAppointmentsFuture;
  String? _workshopId;

  @override
  void initState() {
    super.initState();
    _pendingAppointmentsFuture = _fetchPendingAppointments();
  }

  Future<List<Appointment>> _fetchPendingAppointments() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      throw Exception('Brak danych użytkownika');
    }

    bool isMechanicOrWorkshopOwner = user.roles.contains('mechanic') || user.roles.contains('workshop_owner');
    bool isAssignedToWorkshop = user.employeeProfiles.isNotEmpty;

    if (isMechanicOrWorkshopOwner && isAssignedToWorkshop) {
      // Pobierz workshopId z employeeProfiles
      final employee = user.employeeProfiles.first;
      _workshopId = employee.workshopId;

      List<Appointment> appointments = await AppointmentService.getAppointments(
        authProvider.accessToken!,
        _workshopId!,
      );

      // Filtruj tylko zaplanowane wizyty
      appointments = appointments
          .where((appointment) => appointment.status.toLowerCase() == 'pending')
          .toList();

      // Sortuj według daty zakończenia (najpierw najnowsze)
      appointments.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

      return appointments;
    } else {
      throw Exception('Nie masz uprawnień do wyświetlenia tej strony');
    }
  }

  Future<void> _refreshPendingAppointments() async {
    setState(() {
      _pendingAppointmentsFuture = _fetchPendingAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zaplanowane Zlecenia'),
      ),
      body: FutureBuilder<List<Appointment>>(
        future: _pendingAppointmentsFuture,
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
                      onPressed: _refreshPendingAppointments,
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
            final pendingAppointments = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshPendingAppointments,
              child: ListView.separated(
                padding: const EdgeInsets.all(8.0),
                itemCount: pendingAppointments.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  return _buildPendingAppointmentItem(pendingAppointments[index]);
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildPendingAppointmentItem(Appointment appointment) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: const Icon(Icons.pending, size: 40, color: Colors.blue),
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
        onStatusChanged: _refreshPendingAppointments, // Odświeżenie wizyt po zmianie
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
    _refreshPendingAppointments();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Nie udało się zmienić statusu: $e')),
    );
  }
}

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'canceled':
        return Colors.green;
      case 'schedudled':
        return Colors.orange;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
