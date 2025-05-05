import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/appointment.dart';
import '../bloc/appointment_bloc.dart';

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

  void _updateAppointmentStatus(BuildContext context, String newStatus) {
    context.read<AppointmentBloc>().add(
      UpdateAppointmentEvent(
        workshopId: workshopId,
        appointmentId: appointment.id,
        status: newStatus,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppointmentBloc, AppointmentState>(
      listener: (context, state) {
        if (state is AppointmentOperationSuccess) {
          onStatusChanged();
          Navigator.pop(context);
        }
        if (state is AppointmentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nie udało się zmienić statusu: ${state.message}')),
          );
        }
      },
      child: AlertDialog(
        title: const Text('Zmień status wizyty'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusListTile(
              icon: Icons.pending,
              color: Colors.orange,
              title: 'Do wykonania',
              status: 'pending',
              onTap: () => _updateAppointmentStatus(context, 'pending'),
            ),
            _StatusListTile(
              icon: Icons.timelapse,
              color: Colors.blue,
              title: 'W trakcie',
              status: 'in_progress',
              onTap: () => _updateAppointmentStatus(context, 'in_progress'),
            ),
            _StatusListTile(
              icon: Icons.check_circle,
              color: Colors.green,
              title: 'Zakończone',
              status: 'completed',
              onTap: () => _updateAppointmentStatus(context, 'completed'),
            ),
            _StatusListTile(
              icon: Icons.cancel,
              color: Colors.red,
              title: 'Anulowane',
              status: 'canceled',
              onTap: () => _updateAppointmentStatus(context, 'canceled'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusListTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String status;
  final VoidCallback onTap;

  const _StatusListTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: onTap,
    );
  }
}