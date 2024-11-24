import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';
import 'package:intl/intl.dart';
import 'appointment_details_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  static const routeName = '/appointments';

  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _workshopId;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Brak danych użytkownika';
      });
      return;
    }

    bool isMechanic = user.roles.contains('mechanic');
    bool isAssignedToWorkshop = user.employeeProfiles.isNotEmpty;

    if (isMechanic && isAssignedToWorkshop) {
      // Pobierz workshopId z employeeProfiles
      final employee = user.employeeProfiles.first;
      final workshopId = employee.workshopId;
      _workshopId = workshopId;

      try {
        final appointments = await AppointmentService.getAppointments(
          authProvider.accessToken!,
          workshopId,
        );
        setState(() {
          _appointments = appointments;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    } else {
      // Jeśli nie jest mechanikiem lub nie jest przypisany do warsztatu
      setState(() {
        _isLoading = false;
        _errorMessage = 'Nie masz uprawnień do wyświetlenia tej strony';
      });
    }
  }

  Widget _buildAppointmentItem(Appointment appointment) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.event),
        title: Text(
            'Wizyta: ${appointment.vehicle.make} ${appointment.vehicle.model}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Klient: ${appointment.client.firstName} ${appointment.client.lastName}'),
            Text(
                'Data: ${DateFormat('dd-MM-yyyy HH:mm').format(appointment.scheduledTime.toLocal())}'),
            Text('Status: ${appointment.status}'),
            Text('Notatki: ${appointment.notes ?? 'Brak'}'),
          ],
        ),
        isThreeLine: true,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Twoje Zlecenia'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : RefreshIndicator(
                  onRefresh: _fetchAppointments,
                  child: ListView.builder(
                    itemCount: _appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = _appointments[index];
                      return _buildAppointmentItem(appointment);
                    },
                  ),
                ),
    );
  }
}
