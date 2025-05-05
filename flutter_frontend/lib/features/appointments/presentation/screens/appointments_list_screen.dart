import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/screens/appointments/add_appointment_screen.dart';
import 'package:flutter_frontend/screens/appointments/appointment_details_screen.dart';
import 'package:flutter_frontend/screens/appointments/canceled_appointments_screen.dart';
import 'package:flutter_frontend/screens/appointments/completed_appointments_screen.dart';
import 'package:flutter_frontend/screens/appointments/pending_appointments_screen.dart';
import 'package:intl/intl.dart';
import '../bloc/appointment_bloc.dart';
import '../widgets/change_status_widget.dart';
import '../../domain/entities/appointment.dart';

class AppointmentsListScreen extends StatefulWidget {
  static const routeName = '/appointments';
  final String workshopId;

  const AppointmentsListScreen({
    super.key,
    required this.workshopId,
  });

  @override
  State<AppointmentsListScreen> createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadAppointments();
    });
  }

  void _loadAppointments() {
    if (!mounted) return;
    debugPrint('AppointmentListScreen - Loading appointments for workshop: ${widget.workshopId}');
    context.read<AppointmentBloc>().add(LoadAppointmentsEvent(
      workshopId: widget.workshopId,));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktualne'),
        actions: _buildAppBarActions(),
      ),
      body: BlocConsumer<AppointmentBloc, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message))
            );
          }
          if (state is AppointmentUnauthenticated) {
            // Handle logout/unauthorized access
            Navigator.of(context).pushReplacementNamed('/login');
          }
        },
        builder: (context, state) {
          return _buildBody(state);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddAppointment,
        tooltip: 'Dodaj zlecenie',
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      IconButton(
        icon: const Icon(Icons.pending),
        tooltip: 'Zaplanowane zlecenia',
        onPressed: _navigateToPendingAppointments,
      ),
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
    ];
  }

  Widget _buildBody(AppointmentState state) {
    if (state is AppointmentLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state is AppointmentsLoaded) {
      if (state.appointments.isEmpty) {
        return const Center(
          child: Text(
            'Brak zaplanowanych zleceń.',
            style: TextStyle(fontSize: 16),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => _loadAppointments(),
        child: ListView.separated(
          padding: const EdgeInsets.all(8.0),
          itemCount: state.appointments.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            return _buildAppointmentItem(state.appointments[index]);
          },
        ),
      );
    }

    if (state is AppointmentError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadAppointments,
                icon: const Icon(Icons.refresh),
                label: const Text('Ponów próbę'),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildAppointmentSubtitle(Appointment appointment) {
  final licensePlate = appointment.vehicle.licensePlate.toString();
  final firstName = appointment.client.firstName.toString();
  final lastName = appointment.client.lastName.toString();
  final status = appointment.status.toString();
  final notes = appointment.notes?.toString() ?? 'Brak notatek';
  final scheduledTime = appointment.scheduledTime;
  final formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(scheduledTime);

  return Padding(
    padding: const EdgeInsets.only(top: 4.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rejestracja: $licensePlate',
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          'Klient: $firstName $lastName',
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          'Data: $formattedDate',
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          'Status: $status',
          style: TextStyle(
            fontSize: 14,
            color: _getStatusColor(status),
          ),
        ),
        if (notes.isNotEmpty) // Only show notes if they exist
          Text(
            'Notatki: $notes',
            style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
          ),
      ],
    ),
  );
}

Widget _buildAppointmentItem(Appointment appointment) {
  // Add null checks and default values
  final make = appointment.vehicle.make.toString();
  final model = appointment.vehicle.model.toString();
  
  return Card(
    elevation: 3,
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    child: ListTile(
      leading: const Icon(Icons.event, size: 40, color: Colors.blue),
      title: Text(
        'Wizyta: $make $model',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: _buildAppointmentSubtitle(appointment),
      isThreeLine: true,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _navigateToDetails(appointment.id), // Add null check for id
      onLongPress: () => _showChangeStatusPopup(appointment),
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

  void _showChangeStatusPopup(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => ChangeStatusWidget(
        appointment: appointment,
        workshopId: widget.workshopId,
        onStatusChanged: _loadAppointments,
      ),
    );
  }

  void _navigateToDetails(String appointmentId) {
    Navigator.pushNamed(
      context,
      AppointmentDetailsScreen.routeName,
      arguments: {
        'workshopId': widget.workshopId,
        'appointmentId': appointmentId,
      },
    );
  }

  void _navigateToAddAppointment() async {
    final result = await Navigator.pushNamed(
      context,
      AddAppointmentScreen.routeName,
    );

    if (result == true) {
      _loadAppointments();
    }
  }

  void _navigateToCompletedAppointments() {
    Navigator.pushNamed(context, CompletedAppointmentsScreen.routeName);
  }

  void _navigateToCanceledAppointments() {
    Navigator.pushNamed(context, CanceledAppointmentsScreen.routeName);
  }

  void _navigateToPendingAppointments() {
    Navigator.pushNamed(context, PendingAppointmentsScreen.routeName);
  }
}