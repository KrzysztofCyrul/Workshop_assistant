import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ChangeStatusWidget extends StatelessWidget {
  final Appointment appointment;
  final String workshopId;
  final VoidCallback onStatusChanged;

  const ChangeStatusWidget({
    super.key,
    required this.appointment,
    required this.workshopId,
    required this.onStatusChanged,
  });

  Future<void> _updateAppointmentStatus(BuildContext context, String newStatus) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await AppointmentService.updateAppointmentStatus(
        appointmentId: appointment.id,
        status: newStatus,
        accessToken: authProvider.accessToken!,
        workshopId: workshopId,
      );
      onStatusChanged(); // Odświeżenie danych po zmianie statusu
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się zmienić statusu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Zmień status wizyty'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.pending, color: Colors.orange),
            title: const Text('Do wykonania'),
            onTap: () {
              _updateAppointmentStatus(context, 'pending');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.timelapse, color: Colors.blue),
            title: const Text('W trakcie'),
            onTap: () {
              _updateAppointmentStatus(context, 'in_progress');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: const Text('Zakończone'),
            onTap: () {
              _updateAppointmentStatus(context, 'completed');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.cancel, color: Colors.red),
            title: const Text('Anulowane'),
            onTap: () {
              _updateAppointmentStatus(context, 'canceled');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}