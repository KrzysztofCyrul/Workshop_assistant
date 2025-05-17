import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_frontend/screens/appointments/add_appointment_screen.dart';
// import 'package:flutter_frontend/screens/appointments/appointment_details_screen.dart';
import 'package:flutter_frontend/features/appointments/presentation/screens/appointment_details_screen.dart';
import 'package:flutter_frontend/features/appointments/presentation/screens/add_appointment_screen.dart';
import 'package:flutter_frontend/core/widgets/add_action_button.dart';
import 'package:flutter_frontend/core/widgets/custom_app_bar.dart';

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
  String _currentFilter = 'in_progress'; // 'all', 'in_progress','pending', 'completed', 'canceled'

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
          workshopId: widget.workshopId,
        ));
  }

  List<Appointment> _filterAppointments(List<Appointment> appointments) {
    switch (_currentFilter) {
      case 'in_progress':
        return appointments.where((a) => a.status.toLowerCase() == 'in_progress').toList();
      case 'pending':
        return appointments.where((a) => a.status.toLowerCase() == 'pending').toList();
      case 'completed':
        return appointments.where((a) => a.status.toLowerCase() == 'completed').toList();
      case 'canceled':
        return appointments.where((a) => a.status.toLowerCase() == 'canceled').toList();
      default:
        return appointments;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'in_progress':
        return Icons.timelapse;
      case 'canceled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Zakończone';
      case 'pending':
        return 'Do wykonania';
      case 'in_progress':
        return 'W toku';
      case 'canceled':
        return 'Anulowane';
      default:
        return status;
    }
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      appBar: CustomAppBar(
        title: _getAppBarTitle(),
        feature: 'appointments',
        actions: _buildAppBarActions(),
      ),
      body: BlocConsumer<AppointmentBloc, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
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
      ),      floatingActionButton: AddActionButton(
        onPressed: _navigateToAddAppointment,
        tooltip: 'Dodaj zlecenie',
        labelText: 'Nowe zlecenie',
        isExtended: true,
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentFilter) {
      case 'in_progress':
        return 'Wizyty w toku';
      case 'pending':
        return 'Zaplanowane';
      case 'completed':
        return 'Zakończone';
      case 'canceled':
        return 'Anulowane';
      default:
        return 'Wszystkie zlecenia';
    }
  }

  List<Widget> _buildAppBarActions() {
    return [
      Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: PopupMenuButton<String>(
          tooltip: 'Filtruj zlecenia',
          icon: Icon(
            Icons.filter_list,
            color: Theme.of(context).colorScheme.primary,
          ),
          onSelected: (String value) {
            setState(() {
              _currentFilter = value;
            });
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            _buildFilterMenuItem('all', 'Wszystkie zlecenia', Icons.list_alt),
            _buildFilterMenuItem('in_progress', 'Wizyty w toku', Icons.timelapse),
            _buildFilterMenuItem('pending', 'Zaplanowane', Icons.pending),
            _buildFilterMenuItem('completed', 'Zakończone', Icons.check_circle),
            _buildFilterMenuItem('canceled', 'Anulowane', Icons.cancel),
          ],
        ),
      ),
    ];
  }

  PopupMenuItem<String> _buildFilterMenuItem(String value, String label, IconData icon) {
    final bool isSelected = _currentFilter == value;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            Icon(
              Icons.check,
              color: Theme.of(context).colorScheme.primary,
              size: 16,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(AppointmentState state) {
    if (state is AppointmentLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Ładowanie zleceń...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (state is AppointmentsLoaded) {
      final filteredAppointments = _filterAppointments(state.appointments);

      if (filteredAppointments.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: () async => _loadAppointments(),
        child: ListView.separated(
          padding: const EdgeInsets.all(12.0),
          itemCount: filteredAppointments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 4),
          itemBuilder: (context, index) {
            return _buildAppointmentItem(filteredAppointments[index]);
          },
        ),
      );
    }

    if (state is AppointmentError) {
      return _buildErrorState(state.message);
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildEmptyState() {
    final String message = _getEmptyListMessage();
    IconData iconData;
    
    switch (_currentFilter) {
      case 'completed':
        iconData = Icons.check_circle_outline;
        break;
      case 'canceled':
        iconData = Icons.cancel_outlined;
        break;
      case 'pending':
        iconData = Icons.pending_outlined;
        break;
      case 'in_progress':
        iconData = Icons.timelapse_outlined;
        break;
      default:
        iconData = Icons.assignment_outlined;
    }

    return Center(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                iconData,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _navigateToAddAppointment,
                icon: const Icon(Icons.add),
                label: const Text('Dodaj nowe zlecenie'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'Wystąpił błąd',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadAppointments,
                icon: const Icon(Icons.refresh),
                label: const Text('Ponów próbę'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  String _getEmptyListMessage() {
    switch (_currentFilter) {
      case 'in_progress':
        return 'Brak wizyt w toku.';
      case 'pending':
        return 'Brak zaplanowanych zleceń.';
      case 'completed':
        return 'Brak zakończonych zleceń.';
      case 'canceled':
        return 'Brak anulowanych zleceń.';
      default:
        return 'Brak zleceń.';
    }
  }
  Widget _buildAppointmentItem(Appointment appointment) {
    // Add null checks and default values
    final make = appointment.vehicle.make.toString();
    final model = appointment.vehicle.model.toString();
    final licensePlate = appointment.vehicle.licensePlate.toString();
    final firstName = appointment.client.firstName.toString();
    final lastName = appointment.client.lastName.toString();
    final status = appointment.status.toString();
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final scheduledTime = appointment.scheduledTime;
    final formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(scheduledTime);
    
    // Get initials for avatar
    String initials = '';
    if (firstName.isNotEmpty) initials += firstName[0];
    if (lastName.isNotEmpty) initials += lastName[0];
    initials = initials.toUpperCase();

    return InkWell(
      onTap: () => _navigateToDetails(appointment.id),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with vehicle and status
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$make $model',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Zaplanowano na: $formattedDate',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusLabel(status),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Divider line
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(color: Colors.grey.shade300, height: 1),
              ),
              
              // Details section
              _buildDetailRow("Rejestracja", licensePlate, Icons.car_rental),
              _buildDetailRow("Klient", "$firstName $lastName", Icons.person),
              if (appointment.notes?.isNotEmpty ?? false)
                _buildDetailRow("Notatki", appointment.notes!, Icons.note),
              
              // Action buttons
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showChangeStatusPopup(appointment),
                      icon: Icon(Icons.edit, size: 16, color: statusColor),
                      label: const Text('Zmień status'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: statusColor),
                        foregroundColor: statusColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToDetails(appointment.id),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Szczegóły'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
      arguments: {'workshopId': widget.workshopId},
    );

    if (result == true) {
      _loadAppointments();
    }
  }
}
