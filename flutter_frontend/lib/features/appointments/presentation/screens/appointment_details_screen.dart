import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/appointment_bloc.dart';
import '../widgets/parts_suggestion_field.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/part.dart';
import '../../domain/entities/repair_item.dart';
import '../../domain/services/appointment_pdf_generator.dart';
import 'package:flutter_frontend/features/vehicles/presentation/screens/service_history_screen.dart';
import 'package:flutter_frontend/features/vehicles/domain/entities/vehicle.dart';
import 'package:flutter_frontend/features/clients/domain/entities/client.dart';
// Constants
class AppointmentStatus {
  static const String pending = 'pending';
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';
  static const String canceled = 'canceled';

  static String getLabel(String status) {
    switch (status) {
      case pending:
        return 'Do wykonania';
      case inProgress:
        return 'W trakcie';
      case completed:
        return 'Zakończone';
      case canceled:
        return 'Anulowane';
      default:
        return status;
    }
  }
  
  static IconData getIcon(String status) {
    switch (status) {
      case pending:
        return Icons.pending;
      case inProgress:
        return Icons.timelapse;
      case completed:
        return Icons.check_circle;
      case canceled:
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  static Color getColor(String status) {
    switch (status) {
      case pending:
        return Colors.orange;
      case inProgress:
        return Colors.blue;
      case completed:
        return Colors.green;
      case canceled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

mixin FormValidatorMixin {
  String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName nie może być puste';
    }
    return null;
  }

  String? validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName nie może być puste';
    }
    if (double.tryParse(value) == null) {
      return '$fieldName musi być liczbą';
    }
    return null;
  }

  String? validatePositiveNumber(String? value, String fieldName) {
    final numberError = validateNumber(value, fieldName);
    if (numberError != null) {
      return numberError;
    }
    if (double.parse(value!) <= 0) {
      return '$fieldName musi być większe od zera';
    }
    return null;
  }
}

class AppointmentDetailsScreen extends StatefulWidget {
  static const String routeName = '/appointment-details';

  final String workshopId;
  final String appointmentId;

  const AppointmentDetailsScreen({
    super.key,
    required this.workshopId,
    required this.appointmentId,
  });
  @override
  State<AppointmentDetailsScreen> createState() => _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> with FormValidatorMixin {
  // Form controllers
  final _partNameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _partCostController = TextEditingController(text: '0.0');
  final _serviceCostController = TextEditingController(text: '0.0');
  final _buyCostPartController = TextEditingController(text: '0.0');
  final _repairDescriptionController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Pomocnicze metody
  String _getInitials(String firstName, String lastName) {
    String initials = '';
    
    if (firstName.isNotEmpty) {
      initials += firstName[0];
    }
    
    if (lastName.isNotEmpty) {
      initials += lastName[0];
    }
    
    return initials.isNotEmpty ? initials.toUpperCase() : '?';
  }

  @override
  void initState() {
    super.initState();
    context.read<AppointmentBloc>().add(
          LoadAppointmentDetailsEvent(
            workshopId: widget.workshopId,
            appointmentId: widget.appointmentId,
          ),
        );
  }

  @override
  void dispose() {
    _partNameController.dispose();
    _quantityController.dispose();
    _partCostController.dispose();
    _serviceCostController.dispose();
    _buyCostPartController.dispose();
    _repairDescriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _AppBarBuilder(
        appointment: null,
        onPrintPressed: _onPrintButtonPressed,
      ),
      body: _buildBody(),
    );
  }  void _onPrintButtonPressed(Appointment appointment) {
    final pdfGenerator = AppointmentPdfGenerator();
    pdfGenerator.generateAndPrint(
      appointment,
      appointment.parts,
      appointment.repairItems,
    );
  }
  
  Future<void> _confirmDeletePartItem(Part part, Appointment appointment) async {
    // Wyświetl dialog z potwierdzeniem usunięcia
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Potwierdzenie usunięcia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Czy na pewno chcesz usunąć tę część?'),
              const SizedBox(height: 8),
              Text(
                'Nazwa: ${part.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Ilość: ${part.quantity}'),
              Text('Cena: ${part.costPart.toStringAsFixed(2)} PLN'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Anuluj'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Usuń'),
            ),
          ],
        );
      },
    );
    
    // Jeśli użytkownik potwierdził usunięcie
    if (shouldDelete == true) {
      if (!mounted) return;
      
      // Wyślij event do BloC
      context.read<AppointmentBloc>().add(DeletePartEvent(
        workshopId: appointment.workshopId,
        appointmentId: appointment.id,
        partId: part.id,
      ));
    }
  }
  Widget _buildBody() {
    return BlocConsumer<AppointmentBloc, AppointmentState>(
      listener: (context, state) {
        if (state is AppointmentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is AppointmentOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          // Reload appointment details after successful operation
          context.read<AppointmentBloc>().add(LoadAppointmentDetailsEvent(
            workshopId: widget.workshopId,
            appointmentId: widget.appointmentId,
          ));
        } else if (state is AppointmentOperationSuccessWithDetails) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        }
      },      buildWhen: (previous, current) {
        // Only rebuild for states that affect the UI
        return current is AppointmentLoading || 
               current is AppointmentDetailsLoaded || 
               current is AppointmentOperationSuccessWithDetails ||
               current is AppointmentError;
      },
      builder: (context, state) {
        if (state is AppointmentLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AppointmentError) {
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
                    onPressed: () {
                      context.read<AppointmentBloc>().add(LoadAppointmentDetailsEvent(
                        workshopId: widget.workshopId,
                        appointmentId: widget.appointmentId,
                      ));
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Ponów próbę'),
                  ),
                ],
              ),
            ),
          );
        } else if (state is AppointmentDetailsLoaded) {
          return _buildContent(context, state.appointment);
        } else if (state is AppointmentOperationSuccessWithDetails) {
          return _buildContent(context, state.appointment);
        } else {
          return const Center(child: Text('Nie znaleziono zlecenia'));
        }
      },
    );
  }

  Widget _buildContent(BuildContext context, Appointment appointment) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppointmentDetailsCard(context, appointment),
          const SizedBox(height: 16.0),
          _buildVehicleDetailsCard(appointment.vehicle),
          const SizedBox(height: 16.0),
          _buildClientDetailsCard(appointment.client),
          const SizedBox(height: 16.0),
          _buildRepairSection(context, appointment),
          const SizedBox(height: 16.0),
          _buildPartsSection(context, appointment),
          const SizedBox(height: 16.0),
          _buildCostSummary(appointment),
        ],
      ),
    );
  }
  Widget _buildAppointmentDetailsCard(BuildContext context, Appointment appointment) {
    Widget buildDetailRow(String label, String value, {IconData? icon, Color? iconColor}) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(right: 12.0),
                decoration: BoxDecoration(
                  color: (iconColor ?? Colors.blue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(icon, size: 20, color: iconColor ?? Colors.blue),
              ),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
              ),
            ),
          ],
        ),
      );
    }

    final statusColor = AppointmentStatus.getColor(appointment.status);
    final statusIcon = AppointmentStatus.getIcon(appointment.status);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: const Icon(Icons.assignment, color: Colors.blue),
        ),
        title: const Text(
          'Szczegóły Zlecenia',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          AppointmentStatus.getLabel(appointment.status),
          style: TextStyle(color: statusColor, fontWeight: FontWeight.w500),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildDetailRow(
                  'Data',
                  DateFormat('dd-MM-yyyy HH:mm').format(appointment.scheduledTime.toLocal()),
                  icon: Icons.calendar_today,
                  iconColor: Colors.orange,
                ),
                buildDetailRow(
                  'Status',
                  AppointmentStatus.getLabel(appointment.status),
                  icon: statusIcon,
                  iconColor: statusColor,
                ),
                buildDetailRow(
                  'Przebieg',
                  '${appointment.mileage} km',
                  icon: Icons.speed,
                  iconColor: Colors.green,
                ),
                const SizedBox(height: 12.0),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.note, size: 18, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            'Notatki:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Builder(
                        builder: (context) {
                          final controller = TextEditingController(text: appointment.notes ?? '');
                          return TextFormField(
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: 'Dodaj notatki...',
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontStyle: FontStyle.italic),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            maxLines: 3,
                            style: const TextStyle(fontSize: 14),
                            onFieldSubmitted: (newValue) {
                              context.read<AppointmentBloc>().add(EditNotesValueEvent(
                                workshopId: appointment.workshopId,
                                appointmentId: appointment.id,
                                newNotes: newValue,
                              ));
                            },
                            onTapOutside: (_) {
                              if (FocusScope.of(context).hasFocus) {
                                context.read<AppointmentBloc>().add(EditNotesValueEvent(
                                  workshopId: appointment.workshopId,
                                  appointmentId: appointment.id,
                                  newNotes: controller.text,
                                ));
                                FocusManager.instance.primaryFocus?.unfocus();
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildVehicleDetailsCard(Vehicle vehicle) {
    Widget buildDetailRow(String label, String value, {IconData? icon, Color iconColor = Colors.teal}) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(right: 12.0),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.teal.shade100,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: const Icon(Icons.directions_car, color: Colors.teal),
        ),
        title: const Text(
          'Szczegóły Pojazdu',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '${vehicle.make} ${vehicle.model}',
          style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.w500),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildDetailRow('Marka', vehicle.make, icon: Icons.category, iconColor: Colors.teal.shade700),
                buildDetailRow('Model', vehicle.model, icon: Icons.style, iconColor: Colors.teal.shade600),
                buildDetailRow('Rok', vehicle.year.toString(), icon: Icons.date_range, iconColor: Colors.teal.shade500),
                buildDetailRow('VIN', vehicle.vin, icon: Icons.tag, iconColor: Colors.teal.shade700),
                buildDetailRow('Rejestracja', vehicle.licensePlate, icon: Icons.badge, iconColor: Colors.teal.shade600),
                
                const SizedBox(height: 12.0),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.teal.shade100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.directions_car, 
                          size: 32, 
                          color: Colors.teal.shade700
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${vehicle.make} ${vehicle.model} (${vehicle.year})', 
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 18,
                                color: Colors.teal.shade900,
                              ),
                            ),
                            Text(
                              'Nr rejestracyjny: ${vehicle.licensePlate}', 
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 14
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildClientDetailsCard(Client client) {
    Widget buildDetailRow(String label, String value, {IconData? icon, Color iconColor = Colors.purple}) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(right: 12.0),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
              ),
            ),
          ],
        ),
      );
    }

    Widget buildContactButton({
      required IconData icon,
      required String label,
      required String value,
      required Color color,
      required VoidCallback onPressed,
    }) {
      return Container(
        margin: const EdgeInsets.only(right: 8.0),
        child: ElevatedButton.icon(
          icon: Icon(icon, size: 16),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withOpacity(0.1),
            foregroundColor: color,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: color.withOpacity(0.2)),
            ),
          ),
          onPressed: onPressed,
        ),
      );
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.purple.shade100,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: const Icon(Icons.person, color: Colors.purple),
        ),
        title: const Text(
          'Szczegóły Klienta',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '${client.firstName} ${client.lastName}',
          style: TextStyle(color: Colors.purple.shade700, fontWeight: FontWeight.w500),
        ),        trailing: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              _getInitials(client.firstName, client.lastName),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple.shade100),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.purple, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                _getInitials(client.firstName, client.lastName),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: Colors.purple.shade700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${client.firstName} ${client.lastName}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.purple.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (client.phone != null)
                                  Text(
                                    client.phone!,
                                    style: TextStyle(
                                      color: Colors.purple.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),                      Row(
                        children: [
                          if (client.phone != null && client.phone!.isNotEmpty)
                            buildContactButton(
                              icon: Icons.phone,
                              label: 'Zadzwoń',
                              value: client.phone!,
                              color: Colors.green,
                              onPressed: () {
                                // Implement call functionality
                                try {
                                  final uri = Uri.parse('tel:${client.phone}');
                                  launchUrl(uri);
                                } catch (e) {
                                  // Obsługa błędu
                                  debugPrint('Nie można wykonać połączenia: $e');
                                }
                              },
                            ),
                          if (client.email.isNotEmpty)
                            buildContactButton(
                              icon: Icons.email,
                              label: 'Email',
                              value: client.email,
                              color: Colors.orange,
                              onPressed: () {
                                // Implement email functionality
                                try {
                                  final uri = Uri.parse('mailto:${client.email}');
                                  launchUrl(uri);
                                } catch (e) {
                                  // Obsługa błędu
                                  debugPrint('Nie można wysłać email: $e');
                                }
                              },
                            ),
                          if (client.address != null && client.address!.isNotEmpty)
                            buildContactButton(
                              icon: Icons.map,
                              label: 'Mapa',
                              value: client.address!,
                              color: Colors.blue,
                              onPressed: () {
                                // Implement map functionality
                                try {
                                  final encodedAddress = Uri.encodeComponent(client.address!);
                                  final uri = Uri.parse('https://maps.google.com/?q=$encodedAddress');
                                  launchUrl(uri, mode: LaunchMode.externalApplication);
                                } catch (e) {
                                  // Obsługa błędu
                                  debugPrint('Nie można otworzyć mapy: $e');
                                }
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                buildDetailRow(
                  'Imię i nazwisko',
                  '${client.firstName} ${client.lastName}',
                  icon: Icons.person,
                  iconColor: Colors.purple,
                ),
                buildDetailRow(
                  'Email',
                  client.email,
                  icon: Icons.email,
                  iconColor: Colors.orange,
                ),
                buildDetailRow(
                  'Telefon',
                  client.phone ?? 'Brak',
                  icon: Icons.phone,
                  iconColor: Colors.green,
                ),
                if (client.address != null) 
                  buildDetailRow(
                    'Adres',
                    client.address!,
                    icon: Icons.home,
                    iconColor: Colors.blue,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairSection(BuildContext context, Appointment appointment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Do naprawy',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        _buildAddRepairItemForm(context, appointment),
        const SizedBox(height: 16.0),
        _buildRepairItemsTable(context, appointment),
      ],
    );
  }
  Widget _buildAddRepairItemForm(BuildContext context, Appointment appointment) {
    final TextEditingController repairDescriptionController = TextEditingController();

    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: TextField(
                    controller: repairDescriptionController,
                    decoration: InputDecoration(
                      labelText: 'Opis naprawy',
                      hintText: 'Wprowadź opis zadania do wykonania',
                      prefixIcon: const Icon(Icons.build),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Dodaj'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    if (repairDescriptionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Wprowadź opis naprawy'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    context.read<AppointmentBloc>().add(AddRepairItemEvent(
                      workshopId: appointment.workshopId,
                      appointmentId: appointment.id,
                      description: repairDescriptionController.text,
                      status: 'pending',
                      order: appointment.repairItems.length + 1,
                    ));

                    repairDescriptionController.clear();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildRepairItemsTable(BuildContext context, Appointment appointment) {
    void updateRepairItemStatus(RepairItem item, String newStatus) {
      context.read<AppointmentBloc>().add(UpdateRepairItemEvent(
        workshopId: appointment.workshopId,
        appointmentId: appointment.id,
        repairItemId: item.id,
        description: item.description ?? '',
        status: newStatus,
        order: item.order,
        isCompleted: newStatus == 'completed',
      ));
    }

    void showStatusChangeDialog(RepairItem item) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Zmień status'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(AppointmentStatus.getIcon(AppointmentStatus.pending), color: AppointmentStatus.getColor(AppointmentStatus.pending)),
                  title: const Text('Do wykonania'),
                  onTap: () {
                    updateRepairItemStatus(item, AppointmentStatus.pending);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(AppointmentStatus.getIcon(AppointmentStatus.inProgress), color: AppointmentStatus.getColor(AppointmentStatus.inProgress)),
                  title: const Text('W trakcie'),
                  onTap: () {
                    updateRepairItemStatus(item, AppointmentStatus.inProgress);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(AppointmentStatus.getIcon(AppointmentStatus.completed), color: AppointmentStatus.getColor(AppointmentStatus.completed)),
                  title: const Text('Zakończone'),
                  onTap: () {
                    updateRepairItemStatus(item, AppointmentStatus.completed);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(AppointmentStatus.getIcon(AppointmentStatus.canceled), color: AppointmentStatus.getColor(AppointmentStatus.canceled)),
                  title: const Text('Anulowane'),
                  onTap: () {
                    updateRepairItemStatus(item, AppointmentStatus.canceled);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      );
    }
    
    Future<void> _confirmDeleteRepairItem(RepairItem item) async {
      // Wyświetl dialog z potwierdzeniem usunięcia
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Potwierdzenie usunięcia'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Czy na pewno chcesz usunąć ten element naprawy?'),
                const SizedBox(height: 8),
                Text(
                  'Opis: ${item.description ?? "Brak opisu"}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Status: ${AppointmentStatus.getLabel(item.status)}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Anuluj'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Usuń'),
              ),
            ],
          );
        },
      );
      
      // Jeśli użytkownik potwierdził usunięcie
      if (shouldDelete == true) {
        if (!mounted) return;
        
        // Wyślij event do BloC
        context.read<AppointmentBloc>().add(DeleteRepairItemEvent(
          workshopId: appointment.workshopId,
          appointmentId: appointment.id,
          repairItemId: item.id,
        ));
      }
    }

    // Obsługa pustej listy
    if (appointment.repairItems.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        elevation: 2,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'Brak elementów naprawy',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: SizedBox(
                width: constraints.maxWidth,
                child: DataTable(
                  columnSpacing: 16.0,
                  horizontalMargin: 16.0,
                  headingRowHeight: 48.0,
                  dataRowHeight: 56.0,
                  border: TableBorder.all(
                    color: Colors.grey.shade300,
                    width: 1,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  headingRowColor: WidgetStateProperty.resolveWith(
                    (states) => Colors.blue.shade100,
                  ),
                  dataRowColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.blue.shade50;
                    }
                    return states.any((element) => element == MaterialState.hovered) 
                        ? Colors.grey.shade200 
                        : Colors.grey.shade50;
                  }),
                  columns: [
                    DataColumn(
                      label: Expanded(
                        child: Center(
                          child: Text(
                            'Opis',
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Center(
                          child: Text(
                            'Status',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Center(
                          child: Text(
                            'Akcje',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                  rows: appointment.repairItems.map((item) {
                    return DataRow(
                      color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.blue.shade50;
                        }
                        return states.any((element) => element == MaterialState.hovered) 
                            ? Colors.grey.shade200 
                            : null; // Use the default value.
                      }),
                      cells: [
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: TextFormField(
                              initialValue: item.description ?? 'Brak opisu',
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 14),
                              maxLines: null,
                              onFieldSubmitted: (newValue) {
                                context.read<AppointmentBloc>().add(UpdateRepairItemEvent(
                                  workshopId: appointment.workshopId,
                                  appointmentId: appointment.id,
                                  repairItemId: item.id,
                                  description: newValue,
                                  status: item.status,
                                  order: item.order,
                                  isCompleted: item.isCompleted,
                                ));
                              },                        onTapOutside: (_) {
                                final value = FocusScope.of(context).focusedChild?.context?.widget;
                                if (value != null && value is TextFormField) {
                                  context.read<AppointmentBloc>().add(UpdateRepairItemEvent(
                                    workshopId: appointment.workshopId,
                                    appointmentId: appointment.id,
                                    repairItemId: item.id,
                                    description: value.controller?.text ?? value.initialValue ?? '',
                                    status: item.status,
                                    order: item.order,
                                    isCompleted: item.isCompleted,
                                  ));
                                  FocusManager.instance.primaryFocus?.unfocus();
                                }
                              },
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: GestureDetector(
                              onTap: () => showStatusChangeDialog(item),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: AppointmentStatus.getColor(item.status).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(color: AppointmentStatus.getColor(item.status)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      AppointmentStatus.getIcon(item.status),
                                      color: AppointmentStatus.getColor(item.status),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppointmentStatus.getLabel(item.status),
                                      style: TextStyle(
                                        color: AppointmentStatus.getColor(item.status),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () => _confirmDeleteRepairItem(item),
                                  tooltip: 'Usuń element naprawy',
                                  splashRadius: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPartsSection(BuildContext context, Appointment appointment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Części',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        _buildAddPartForm(context, appointment),
        const SizedBox(height: 16.0),
        _buildPartsTable(context, appointment),
      ],
    );
  }
  Widget _buildAddPartForm(BuildContext context, Appointment appointment) {
    final TextEditingController partNameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController(text: '1');
    final TextEditingController partCostController = TextEditingController(text: '0.0');
    final TextEditingController serviceCostController = TextEditingController(text: '0.0');
    final TextEditingController buyCostPartController = TextEditingController(text: '0.0');

    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PartsSuggestionField(
                        controller: partNameController,
                        label: 'Nazwa części',
                        onChanged: (value) {
                          partNameController.text = value;
                        }
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: 'Ilość',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: buyCostPartController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          labelText: 'Cena Hurtowa',
                          prefixIcon: const Icon(Icons.money_off),
                          suffixText: 'PLN',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: partCostController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          labelText: 'Cena detaliczna',
                          prefixIcon: const Icon(Icons.shopping_cart),
                          suffixText: 'PLN',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: serviceCostController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          labelText: 'Koszt usługi',
                          prefixIcon: const Icon(Icons.build),
                          suffixText: 'PLN',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Dodaj część'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        if (partNameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Wprowadź nazwę części'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        context.read<AppointmentBloc>().add(AddPartEvent(
                          workshopId: appointment.workshopId,
                          appointmentId: appointment.id,
                          name: partNameController.text,
                          description: '',
                          quantity: int.tryParse(quantityController.text) ?? 1,
                          costPart: double.tryParse(partCostController.text) ?? 0.0,
                          costService: double.tryParse(serviceCostController.text) ?? 0.0,
                          buyCostPart: double.tryParse(buyCostPartController.text) ?? 0.0,
                        ));

                        partNameController.clear();
                        quantityController.text = '1';
                        partCostController.text = '0.0';
                        serviceCostController.text = '0.0';
                        buyCostPartController.text = '0.0';
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }Widget _buildPartsTable(BuildContext context, Appointment appointment) {
    void editPartValue(Part part, String field, dynamic newValue) {
      context.read<AppointmentBloc>().add(UpdatePartEvent(
        workshopId: appointment.workshopId,
        appointmentId: appointment.id,
        partId: part.id,
        name: field == 'name' ? newValue : part.name,
        description: part.description,
        quantity: field == 'quantity' ? newValue : part.quantity,
        costPart: field == 'costPart' ? newValue : part.costPart,
        costService: field == 'costService' ? newValue : part.costService,
        buyCostPart: field == 'buyCostPart' ? newValue : part.buyCostPart,
      ));
    }
    
    DataCell buildEditableCell(
      String initialValue, 
      String fieldName, 
      Part part, 
      {TextInputType keyboardType = TextInputType.text, 
      bool isNumber = false,
      bool alignCenter = false}
    ) {
      final controller = TextEditingController(text: initialValue);
      return DataCell(
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
            isDense: true,
          ),
          textAlign: alignCenter ? TextAlign.center : TextAlign.start,
          style: const TextStyle(fontSize: 14),
          onFieldSubmitted: (newValue) {
            dynamic value = newValue;
            if (isNumber) {
              if (fieldName == 'quantity') {
                value = int.tryParse(newValue) ?? part.quantity;
              } else {
                value = double.tryParse(newValue) ?? 0.0;
              }
            }
            editPartValue(part, fieldName, value);
          },
          onTapOutside: (_) {
            if (FocusScope.of(context).hasFocus) {
              dynamic value = controller.text;
              if (isNumber) {
                if (fieldName == 'quantity') {
                  value = int.tryParse(controller.text) ?? part.quantity;
                } else {
                  value = double.tryParse(controller.text) ?? 0.0;
                }
              }
              editPartValue(part, fieldName, value);
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
        ),
      );
    }

    // Obsługa pustej listy
    if (appointment.parts.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        elevation: 2,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'Brak dodanych części',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: SizedBox(
                width: constraints.maxWidth,
                child: DataTable(
                  columnSpacing: 16.0,
                  horizontalMargin: 16.0,
                  headingRowHeight: 48.0,
                  dataRowHeight: 56.0,
                  border: TableBorder.all(
                    color: Colors.grey.shade300,
                    width: 1,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  headingRowColor: MaterialStateProperty.resolveWith(
                    (states) => Colors.green.shade100,
                  ),
                  dataRowColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.green.shade50;
                    }
                    return states.any((element) => element == MaterialState.hovered) 
                        ? Colors.grey.shade200 
                        : Colors.grey.shade50;
                  }),
                  columns: const [
                    DataColumn(
                      label: Expanded(
                        child: Center(
                          child: Text(
                            'Część',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Center(
                          child: Text(
                            'Ilość',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Center(
                          child: Text(
                            'Hurtowa',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Center(
                          child: Text(
                            'Części',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Center(
                          child: Text(
                            'Suma',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Center(
                          child: Text(
                            'Usługa',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Center(
                          child: Text(
                            'Akcje',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                  rows: appointment.parts.map((part) {
                    return DataRow(
                      cells: [
                        buildEditableCell(part.name, 'name', part),
                        buildEditableCell(part.quantity.toString(), 'quantity', part,
                          keyboardType: TextInputType.number, isNumber: true, alignCenter: true),
                        buildEditableCell(part.buyCostPart.toStringAsFixed(2), 'buyCostPart', part,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true), 
                          isNumber: true, 
                          alignCenter: true),
                        buildEditableCell(part.costPart.toStringAsFixed(2), 'costPart', part,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true), 
                          isNumber: true,
                          alignCenter: true),
                        DataCell(
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Text(
                                (part.costPart * part.quantity).toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        buildEditableCell(part.costService.toStringAsFixed(2), 'costService', part,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          isNumber: true,
                          alignCenter: true),
                        DataCell(
                          Center(
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () => _confirmDeletePartItem(part, appointment),
                              tooltip: 'Usuń część',
                              splashRadius: 20,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  Widget _buildCostSummary(Appointment appointment) {
    double totalBuyCostPart = appointment.parts.fold(0, (sum, item) => sum + (item.buyCostPart * item.quantity));
    double totalPartCost = appointment.parts.fold(0, (sum, item) => sum + (item.costPart * item.quantity));
    double totalServiceCost = appointment.parts.fold(0, (sum, item) => sum + item.costService);
    double totalMargin = totalPartCost - totalBuyCostPart;
    double totalCost = totalPartCost + totalServiceCost;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Podsumowanie kosztów',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildCostRow('Suma cen części:', totalPartCost, false),
            _buildCostRow('Marża:', totalMargin, false),
            _buildCostRow('Suma cen usług:', totalServiceCost, false),
            const Divider(thickness: 1.0),
            _buildCostRow('Łączna cena:', totalCost, true),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, double value, bool isTotal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16.0 : 14.0,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: isTotal ? BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.green.shade200),
            ) : null,
            child: Text(
              '${value.toStringAsFixed(2)} PLN',
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 16.0 : 14.0,
                color: isTotal ? Colors.green.shade800 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBarBuilder extends StatelessWidget implements PreferredSizeWidget {
  final Appointment? appointment;
  final Function(Appointment) onPrintPressed;

  const _AppBarBuilder({
    required this.appointment,
    required this.onPrintPressed,
  });
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: BlocBuilder<AppointmentBloc, AppointmentState>(
        buildWhen: (previous, current) {
          // Only rebuild for initial loading or when appointment data changes
          if (previous is AppointmentLoading && current is AppointmentLoading) {
            return false; // Skip rebuilds between loading states
          }
          return true; // Rebuild for all other state changes
        },
        builder: (context, state) {
          if (state is AppointmentDetailsLoaded || state is AppointmentOperationSuccessWithDetails) {
            final appointment = state is AppointmentDetailsLoaded 
                ? state.appointment 
                : (state as AppointmentOperationSuccessWithDetails).appointment;
            
            return Text(
              '${DateFormat('dd-MM-yyyy').format(appointment.scheduledTime.toLocal())} '
              '- ${appointment.vehicle.make} ${appointment.vehicle.model}',
            );
          }
          return const Text('Ładowanie...');
        },
      ),
      actions: _buildAppBarActions(context),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      BlocBuilder<AppointmentBloc, AppointmentState>(
        builder: (context, state) {
          if (state is! AppointmentDetailsLoaded) {
            return const SizedBox.shrink();
          }
          return IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historia pojazdu',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VehicleServiceHistoryScreen(
                    workshopId: state.appointment.workshopId,
                    vehicleId: state.appointment.vehicle.id,
                  ),
                ),
              );
            },
          );
        },
      ),
      BlocBuilder<AppointmentBloc, AppointmentState>(
        builder: (context, state) {
          if (state is! AppointmentDetailsLoaded) {
            return const SizedBox.shrink();
          }
          return IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Drukuj',
            onPressed: () => onPrintPressed(state.appointment),
          );
        },
      ),
    ];
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}