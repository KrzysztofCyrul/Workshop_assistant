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
    if (appointment.status == newStatus) {
      Navigator.pop(context);
      return;
    }

    context.read<AppointmentBloc>().add(
          UpdateAppointmentStatusEvent(
            workshopId: workshopId,
            appointmentId: appointment.id,
            status: newStatus,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppointmentBloc, AppointmentState>(
      listener: (context, state) {
        if (state is AppointmentOperationSuccess) {
          onStatusChanged();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state is AppointmentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (state is AppointmentUnauthenticated) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      builder: (context, state) {
        return AlertDialog(
          title: const Text('Zmień status wizyty'),
          content: state is AppointmentLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StatusListTile(
                      icon: Icons.pending,
                      color: Colors.orange,
                      title: 'Do wykonania',
                      status: 'pending',
                      isSelected: appointment.status == 'pending',
                      onTap: () => _updateAppointmentStatus(context, 'pending'),
                    ),
                    _StatusListTile(
                      icon: Icons.timelapse,
                      color: Colors.blue,
                      title: 'W trakcie',
                      status: 'in_progress',
                      isSelected: appointment.status == 'in_progress',
                      onTap: () => _updateAppointmentStatus(context, 'in_progress'),
                    ),
                    _StatusListTile(
                      icon: Icons.check_circle,
                      color: Colors.green,
                      title: 'Zakończone',
                      status: 'completed',
                      isSelected: appointment.status == 'completed',
                      onTap: () => _updateAppointmentStatus(context, 'completed'),
                    ),
                    _StatusListTile(
                      icon: Icons.cancel,
                      color: Colors.red,
                      title: 'Anulowane',
                      status: 'canceled',
                      isSelected: appointment.status == 'canceled',
                      onTap: () => _updateAppointmentStatus(context, 'canceled'),
                    ),
                  ],
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anuluj'),
            ),
          ],
        );
      },
    );
  }
}

class _StatusListTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String status;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusListTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      selected: isSelected,
      selectedTileColor: Colors.grey.withOpacity(0.2),
      onTap: onTap,
      trailing: isSelected ? const Icon(Icons.check) : null,
    );
  }
}