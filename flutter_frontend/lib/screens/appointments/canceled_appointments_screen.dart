import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/appointment.dart';
import '../../services/appointment_service.dart';
import 'package:intl/intl.dart';
import '../../widgets/change_status_widget.dart';
import 'appointment_details_screen.dart';

class CanceledAppointmentsScreen extends StatefulWidget {
  static const routeName = '/canceled-appointments';

  const CanceledAppointmentsScreen({super.key});

  @override
  _CanceledAppointmentsScreenState createState() => _CanceledAppointmentsScreenState();
}

class _CanceledAppointmentsScreenState extends State<CanceledAppointmentsScreen> {
  late Future<List<Appointment>> _canceledAppointmentsFuture;
  String? _workshopId;

  @override
  void initState() {
    super.initState();
    _canceledAppointmentsFuture = _fetchCanceledAppointments();
  }

  Future<List<Appointment>> _fetchCanceledAppointments() async {
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

      final appointmentService = AppointmentService();
      List<Appointment> appointments = await appointmentService.getAppointments(
        authProvider.accessToken!,
        _workshopId!,
      );

      // Filtruj tylko anulowane wizyty
      appointments = appointments
          .where((appointment) => appointment.status.toLowerCase() == 'canceled')
          .toList();

      // Sortuj według daty zakończenia (najpierw najnowsze)
      appointments.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

      return appointments;
    } else {
      throw Exception('Nie masz uprawnień do wyświetlenia tej strony');
    }
  }

  Future<void> _refreshCanceledAppointments() async {
    setState(() {
      _canceledAppointmentsFuture = _fetchCanceledAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anulowane Zlecenia'),
      ),
      body: FutureBuilder<List<Appointment>>(
        future: _canceledAppointmentsFuture,
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
                      onPressed: _refreshCanceledAppointments,
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
            final canceledAppointments = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshCanceledAppointments,
              child: ListView.separated(
                padding: const EdgeInsets.all(8.0),
                itemCount: canceledAppointments.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  return _buildCanceledAppointmentItem(canceledAppointments[index]);
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildCanceledAppointmentItem(Appointment appointment) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: const Icon(Icons.cancel, size: 40, color: Colors.red),
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
        onStatusChanged: _refreshCanceledAppointments, // Odświeżenie wizyt po zmianie
      );
    },
  );
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
