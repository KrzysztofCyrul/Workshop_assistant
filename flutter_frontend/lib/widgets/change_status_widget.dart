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
    Key? key,
    required this.appointment,
    required this.workshopId,
    required this.onStatusChanged,
  }) : super(key: key);

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
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            onPressed: () {
              _updateAppointmentStatus(context, 'completed');
              Navigator.pop(context);
            },
            tooltip: 'Zakończone',
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            onPressed: () {
              _updateAppointmentStatus(context, 'canceled');
              Navigator.pop(context);
            },
            tooltip: 'Anulowane',
          ),
          IconButton(
            icon: const Icon(Icons.pending, color: Colors.orange),
            onPressed: () {
              _updateAppointmentStatus(context, 'schedudled');
              Navigator.pop(context);
            },
            tooltip: 'Oczekujące',
          ),
        ],
      ),
    );
  }
}
