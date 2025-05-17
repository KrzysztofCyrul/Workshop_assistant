import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../bloc/appointment_bloc.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/part.dart';
import '../../domain/entities/repair_item.dart';
import '../../domain/services/appointment_pdf_generator.dart';
import 'package:flutter_frontend/features/vehicles/presentation/screens/service_history_screen.dart';
import 'package:flutter_frontend/features/vehicles/domain/entities/vehicle.dart';
import 'package:flutter_frontend/features/clients/domain/entities/client.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/contact_button_widget.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/cost_summary_widget.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/detail_row_widget.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/details_card_widget.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/client_profile_widget.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/vehicle_profile_widget.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/part_form_widget.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/section_title_widget.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/status_badge_widget.dart';
import 'package:flutter_frontend/core/widgets/custom_app_bar.dart';
import 'package:flutter_frontend/core/theme/app_theme.dart';

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
    // Parts suggestions for autocomplete
  List<String> _partsSuggestions = [];
  bool _isSuggestionsLoaded = false;
  
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
    _loadPartsSuggestions();
  }
  
  Future<void> _loadPartsSuggestions() async {
    if (!_isSuggestionsLoaded) {
      try {
        final String response = await rootBundle.loadString('assets/parts.json');
        final List<dynamic> data = json.decode(response);
        setState(() {
          _partsSuggestions = List<String>.from(data);
          _isSuggestionsLoaded = true;
        });
      } catch (e) {
        debugPrint('Error loading parts suggestions: $e');
      }
    }
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
  }

  void _onPrintButtonPressed(Appointment appointment) {
    final pdfGenerator = AppointmentPdfGenerator();
    pdfGenerator.generateAndPrint(
      appointment,
      appointment.parts,
      appointment.repairItems,
    );
  }

  Future<void> _confirmDeletePartItem(Part part, Appointment appointment) async {
    // Wyświetl dialog z potwierdzeniem usunięcia
    final shouldDelete = await showDialog<bool>(      context: context,
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
                backgroundColor: AppTheme.errorColor,
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
    return BlocConsumer<AppointmentBloc, AppointmentState>(      listener: (context, state) {
        if (state is AppointmentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        } else if (state is AppointmentOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.getFeatureColor('appointments'),
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
              backgroundColor: AppTheme.getFeatureColor('appointments'),
            ),
          );
        }
      },
      buildWhen: (previous, current) {
        // Only rebuild for states that affect the UI
        return current is AppointmentLoading || current is AppointmentDetailsLoaded || current is AppointmentOperationSuccessWithDetails || current is AppointmentError;
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
    final statusColor = AppointmentStatus.getColor(appointment.status);
    final statusIcon = AppointmentStatus.getIcon(appointment.status);
    final featureColor = AppTheme.getFeatureColor('appointments');
    
    return DetailsCardWidget(
      title: 'Szczegóły Zlecenia',
      subtitle: AppointmentStatus.getLabel(appointment.status),
      icon: Icons.assignment,
      iconBackgroundColor: featureColor.withOpacity(0.2),
      iconColor: featureColor,
      initiallyExpanded: false,
      children: [
        // Appointment details
        DetailRowWidget(
          label: 'Data',
          value: DateFormat('dd-MM-yyyy HH:mm').format(appointment.scheduledTime.toLocal()),
          icon: Icons.calendar_today,
          iconColor: featureColor,
        ),
        DetailRowWidget(
          label: 'Status',
          value: AppointmentStatus.getLabel(appointment.status),
          icon: statusIcon,
          iconColor: statusColor,
        ),
        DetailRowWidget(
          label: 'Przebieg',
          value: '${appointment.mileage} km',
          icon: Icons.speed,
          iconColor: featureColor,
        ),
        const SizedBox(height: 12.0),
        
        // Notes section
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
                  Icon(Icons.note, size: 18, color: featureColor),
                  SizedBox(width: 8),
                  Text(
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
                        borderSide: BorderSide(color: featureColor, width: 2),
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
    );
  }
  Widget _buildVehicleDetailsCard(Vehicle vehicle) {
    final vehicleFeatureColor = AppTheme.getFeatureColor('vehicles');
    
    return DetailsCardWidget(
      title: 'Szczegóły Pojazdu',
      subtitle: '${vehicle.make} ${vehicle.model}',
      icon: Icons.directions_car,
      iconBackgroundColor: vehicleFeatureColor.withOpacity(0.2),
      iconColor: vehicleFeatureColor,
      initiallyExpanded: false,
      children: [
        // Vehicle profile card
        VehicleProfileWidget(
          make: vehicle.make,
          model: vehicle.model,
          licensePlate: vehicle.licensePlate,
        ),
        
        // Vehicle details
        DetailRowWidget(
          label: 'Marka',
          value: vehicle.make,
          icon: Icons.category,
          iconColor: Colors.teal.shade700,
        ),
        DetailRowWidget(
          label: 'Model',
          value: vehicle.model,
          icon: Icons.style,
          iconColor: Colors.teal.shade600,
        ),
        DetailRowWidget(
          label: 'Rok',
          value: vehicle.year.toString(),
          icon: Icons.date_range,
          iconColor: Colors.teal.shade500,
        ),
        DetailRowWidget(
          label: 'VIN',
          value: vehicle.vin,
          icon: Icons.tag,
          iconColor: Colors.teal.shade700,
        ),
        DetailRowWidget(
          label: 'Rejestracja',
          value: vehicle.licensePlate,
          icon: Icons.badge,
          iconColor: Colors.teal.shade600,
        ),
      ],
    );
  }
  Widget _buildClientDetailsCard(Client client) {
    final clientFeatureColor = AppTheme.getFeatureColor('clients');
    
    return DetailsCardWidget(
      title: 'Szczegóły Klienta',
      subtitle: '${client.firstName} ${client.lastName}',
      icon: Icons.person,
      iconBackgroundColor: clientFeatureColor.withOpacity(0.2),
      iconColor: clientFeatureColor,
      initiallyExpanded: false,
      trailing: Container(
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
        // Client profile widget
        ClientProfileWidget(
          firstName: client.firstName,
          lastName: client.lastName,
          phone: client.phone,
          email: client.email,
          address: client.address,
          initials: _getInitials(client.firstName, client.lastName),
        ),
        
        // Contact buttons row
        Row(
          children: [
            if (client.phone != null && client.phone!.isNotEmpty)
              ContactButtonWidget(
                icon: Icons.phone,
                label: 'Zadzwoń',
                color: clientFeatureColor,
                onPressed: () {
                  try {
                    final uri = Uri.parse('tel:${client.phone}');
                    launchUrl(uri);
                  } catch (e) {
                    debugPrint('Nie można wykonać połączenia: $e');
                  }
                },
              ),
            if (client.email.isNotEmpty)
              ContactButtonWidget(
                icon: Icons.email,
                label: 'Email',
                color: clientFeatureColor,
                onPressed: () {
                  try {
                    final uri = Uri.parse('mailto:${client.email}');
                    launchUrl(uri);
                  } catch (e) {
                    debugPrint('Nie można wysłać email: $e');
                  }
                },
              ),
            if (client.address != null && client.address!.isNotEmpty)
              ContactButtonWidget(
                icon: Icons.map,
                label: 'Mapa',
                color: clientFeatureColor,
                onPressed: () {
                  try {
                    final encodedAddress = Uri.encodeComponent(client.address!);
                    final uri = Uri.parse('https://maps.google.com/?q=$encodedAddress');
                    launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    debugPrint('Nie można otworzyć mapy: $e');
                  }
                },
              ),
          ],
        ),
        
        // Client details
        DetailRowWidget(
          label: 'Email',
          value: client.email,
          icon: Icons.email,
          iconColor: clientFeatureColor,
        ),
        DetailRowWidget(
          label: 'Telefon',
          value: client.phone ?? 'Brak',
          icon: Icons.phone,
          iconColor: clientFeatureColor,
        ),
        if (client.address != null)
          DetailRowWidget(
            label: 'Adres',
            value: client.address!,
            icon: Icons.home,
            iconColor: clientFeatureColor,
          ),
      ],
    );
  }
  Widget _buildRepairSection(BuildContext context, Appointment appointment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitleWidget(
          title: 'Do naprawy',
          color: AppTheme.getFeatureColor('appointments'),
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
    final featureColor = AppTheme.getFeatureColor('appointments');

    return BlocBuilder<AppointmentBloc, AppointmentState>(      builder: (context, state) {
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
                        borderSide: BorderSide(color: featureColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Dodaj'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.getFeatureColor('appointments'),
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

    Future<void> confirmDeleteRepairItem(RepairItem item) async {
      // Wyświetl dialog z potwierdzeniem usunięcia
      final shouldDelete = await showDialog<bool>(        context: context,
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
                  backgroundColor: AppTheme.errorColor,
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
                    (states) => AppTheme.getFeatureColor('appointments').withOpacity(0.2),
                  ),
                  dataRowColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppTheme.getFeatureColor('appointments').withOpacity(0.1);
                    }
                    return states.any((element) => element == WidgetState.hovered) ? Colors.grey.shade200 : Colors.grey.shade50;
                  }),
                  columns: const [
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
                        return states.any((element) => element == MaterialState.hovered) ? Colors.grey.shade200 : null; // Use the default value.
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
                              },
                              onTapOutside: (_) {
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
                        ),                        DataCell(
                          Center(
                            child: GestureDetector(
                              onTap: () => showStatusChangeDialog(item),
                              child: StatusBadgeWidget.fromStatus(item.status),
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
                                  onPressed: () => confirmDeleteRepairItem(item),
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
        SectionTitleWidget(
          title: 'Części',
          color: AppTheme.getFeatureColor('appointments'),
        ),
        const SizedBox(height: 8.0),
        _buildAddPartForm(context, appointment),
        const SizedBox(height: 16.0),
        _buildPartsTable(context, appointment),
      ],
    );
  }  Widget _buildAddPartForm(BuildContext context, Appointment appointment) {
    final TextEditingController partNameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController(text: '1');
    final TextEditingController partCostController = TextEditingController(text: '0.0');
    final TextEditingController serviceCostController = TextEditingController(text: '0.0');
    final TextEditingController buyCostPartController = TextEditingController(text: '0.0');
    
    return BlocBuilder<AppointmentBloc, AppointmentState>(      builder: (context, state) {        return PartFormWidget(
          partNameController: partNameController,
          quantityController: quantityController,
          partCostController: partCostController,
          serviceCostController: serviceCostController,
          buyCostPartController: buyCostPartController,
          partsSuggestions: _partsSuggestions,
          addButtonLabel: 'Dodaj część',
          onAddPart: () {
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
        );
      },
    );
  }

  Widget _buildPartsTable(BuildContext context, Appointment appointment) {
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

    DataCell buildEditableCell(String initialValue, String fieldName, Part part,
        {TextInputType keyboardType = TextInputType.text, bool isNumber = false, bool alignCenter = false}) {
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
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth, // Ważne: ustawia minimalną szerokość na szerokość ekranu
                  ),
                  child: SingleChildScrollView(
                    child: DataTable(
                      columnSpacing: 10.0,
                      horizontalMargin: 16.0,
                      headingRowHeight: 48.0,
                      dataRowHeight: 56.0,
                      // Ustawienie dostosowania szerokości kolumny
                      border: TableBorder.all(
                        color: Colors.grey.shade300,
                        width: 1,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      headingRowColor: WidgetStateProperty.resolveWith(
                        (states) => AppTheme.getFeatureColor('appointments').withOpacity(0.2),
                      ),
                      dataRowColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppTheme.getFeatureColor('appointments').withOpacity(0.1);
                        }
                        return states.any((element) => element == WidgetState.hovered) ? Colors.grey.shade200 : Colors.grey.shade50;
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
                            buildEditableCell(part.quantity.toString(), 'quantity', part, keyboardType: TextInputType.number, isNumber: true, alignCenter: true),
                            buildEditableCell(part.buyCostPart.toStringAsFixed(2), 'buyCostPart', part,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true), isNumber: true, alignCenter: true),
                            buildEditableCell(part.costPart.toStringAsFixed(2), 'costPart', part,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true), isNumber: true, alignCenter: true),
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
                                keyboardType: const TextInputType.numberWithOptions(decimal: true), isNumber: true, alignCenter: true),
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
                ));
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

    return CostSummaryWidget(
      totalPartsCost: totalPartCost,
      totalServiceCost: totalServiceCost,
      totalMargin: totalMargin,
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
    return CustomAppBar(
      title: 'Szczegóły zlecenia',
      feature: 'appointments',
      titleWidget: BlocBuilder<AppointmentBloc, AppointmentState>(        buildWhen: (previous, current) {
          // Only rebuild for initial loading or when appointment data changes
          if (previous is AppointmentLoading && current is AppointmentLoading) {
            return false; // Skip rebuilds between loading states
          }
          return true; // Rebuild for all other state changes
        },
        builder: (context, state) {
          if (state is AppointmentDetailsLoaded || state is AppointmentOperationSuccessWithDetails) {
            final appointment = state is AppointmentDetailsLoaded ? state.appointment : (state as AppointmentOperationSuccessWithDetails).appointment;

            return Text(
              '${DateFormat('dd-MM-yyyy').format(appointment.scheduledTime.toLocal())} '
              '- ${appointment.vehicle.make} ${appointment.vehicle.model}',
              style: AppTheme.appBarTitleStyle,
            );
          }
          return const Text(
            'Ładowanie...', 
            style: AppTheme.appBarTitleStyle,
          );
        },
      ),
      actions: _buildAppBarActions(context),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      BlocBuilder<AppointmentBloc, AppointmentState>(        builder: (context, state) {
          if (state is! AppointmentDetailsLoaded) {
            return const SizedBox.shrink();
          }
          return IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historia pojazdu',
            onPressed: () {
              // Use a safer approach with additionalPostFrameCallback to navigate
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VehicleServiceHistoryScreen(
                        workshopId: state.appointment.workshopId,
                        vehicleId: state.appointment.vehicle.id,
                      ),
                    ),
                  );
                }
              });
            },
          );
        },
      ),
      BlocBuilder<AppointmentBloc, AppointmentState>(        builder: (context, state) {
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
