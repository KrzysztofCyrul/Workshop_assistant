import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../bloc/appointment_bloc.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/part.dart';
import '../../domain/entities/repair_item.dart';
import 'package:flutter_frontend/features/vehicles/presentation/screens/service_history_screen.dart';
import 'package:flutter_frontend/core/di/injector_container.dart' as di;
import 'package:flutter_frontend/features/vehicles/domain/entities/vehicle.dart';
import 'package:flutter_frontend/features/clients/domain/entities/client.dart';
import '../../domain/services/appointment_pdf_generator.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  static const routeName = '/appointment-details';

  final String workshopId;
  final String appointmentId;

  const AppointmentDetailsScreen({
    super.key,
    required this.workshopId,
    required this.appointmentId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.getIt<AppointmentBloc>()
        ..add(LoadAppointmentDetailsEvent(
          workshopId: workshopId,
          appointmentId: appointmentId,
        )),
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: BlocBuilder<AppointmentBloc, AppointmentState>(
        builder: (context, state) {
          if (state is AppointmentDetailsLoaded) {
            return Text(
              '${DateFormat('dd-MM-yyyy').format(state.appointment.scheduledTime.toLocal())} '
              '- ${state.appointment.vehicle.make} ${state.appointment.vehicle.model}',
            );
          }
          return const Text('Ładowanie...');
        },
      ),
      actions: _buildAppBarActions(context),
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
                    workshopId: workshopId,
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
            onPressed: () => _onPrintButtonPressed(state.appointment),
          );
        },
      ),
    ];
  }

  Widget _buildBody() {
    return BlocConsumer<AppointmentBloc, AppointmentState>(
      listener: (context, state) {
        if (state is AppointmentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is AppointmentOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
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
                        workshopId: workshopId,
                        appointmentId: appointmentId,
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
    String getStatusLabel(String status) {
      switch (status) {
        case 'pending':
          return 'Do wykonania';
        case 'in_progress':
          return 'W trakcie';
        case 'completed':
          return 'Zakończone';
        case 'canceled':
          return 'Anulowane';
        default:
          return status;
      }
    }

    Widget buildDetailRow(String label, String value, {IconData? icon}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(icon, size: 20, color: Colors.blue),
              ),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: const Text('Szczegóły Zlecenia'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                buildDetailRow(
                  'Data',
                  DateFormat('dd-MM-yyyy HH:mm').format(appointment.scheduledTime.toLocal()),
                  icon: Icons.calendar_today,
                ),
                buildDetailRow(
                  'Status',
                  getStatusLabel(appointment.status),
                  icon: Icons.info,
                ),
                buildDetailRow(
                  'Przebieg',
                  '${appointment.mileage} km',
                  icon: Icons.speed,
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Notatki:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  initialValue: appointment.notes ?? '',
                  decoration: const InputDecoration(
                    hintText: 'Dodaj notatki...',
                    border: InputBorder.none,
                  ),
                  maxLines: 3,
                  onChanged: (newValue) {
                    context.read<AppointmentBloc>().add(EditNotesValueEvent(
                      workshopId: appointment.workshopId,
                      appointmentId: appointment.id,
                      newNotes: newValue,
                    ));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleDetailsCard(Vehicle vehicle) {
    Widget buildDetailRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: const Text('Szczegóły Pojazdu'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                buildDetailRow('Marka', vehicle.make),
                buildDetailRow('Model', vehicle.model),
                buildDetailRow('Rok', vehicle.year.toString()),
                buildDetailRow('VIN', vehicle.vin),
                buildDetailRow('Rejestracja', vehicle.licensePlate),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientDetailsCard(Client client) {
    Widget buildDetailRow(String label, String value, {IconData? icon}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(icon, size: 20, color: Colors.blue),
              ),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: const Text('Szczegóły Klienta'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                buildDetailRow(
                  'Imię i nazwisko',
                  '${client.firstName} ${client.lastName}',
                  icon: Icons.person,
                ),
                buildDetailRow('Email', client.email, icon: Icons.email),
                buildDetailRow('Telefon', client.phone ?? 'Brak', icon: Icons.phone),
                if (client.address != null) 
                  buildDetailRow('Adres', client.address!, icon: Icons.home),
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
        return Row(
          children: [
            Expanded(
              flex: 4,
              child: TextField(
                controller: repairDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Opis',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.green),
              onPressed: () {
                if (repairDescriptionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Wprowadź opis naprawy')),
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
              tooltip: 'Dodaj element naprawy',
            ),
          ],
        );
      },
    );
  }

  Widget _buildRepairItemsTable(BuildContext context, Appointment appointment) {
    IconData getStatusIcon(String status) {
      switch (status) {
        case 'pending':
          return Icons.pending;
        case 'in_progress':
          return Icons.timelapse;
        case 'completed':
          return Icons.check_circle;
        case 'canceled':
          return Icons.cancel;
        default:
          return Icons.info;
      }
    }

    Color getStatusColor(String status) {
      switch (status) {
        case 'pending':
          return Colors.orange;
        case 'in_progress':
          return Colors.blue;
        case 'completed':
          return Colors.green;
        case 'canceled':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

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
                  leading: Icon(Icons.pending, color: getStatusColor('pending')),
                  title: const Text('Do wykonania'),
                  onTap: () {
                    updateRepairItemStatus(item, 'pending');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.timelapse, color: getStatusColor('in_progress')),
                  title: const Text('W trakcie'),
                  onTap: () {
                    updateRepairItemStatus(item, 'in_progress');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.check_circle, color: getStatusColor('completed')),
                  title: const Text('Zakończone'),
                  onTap: () {
                    updateRepairItemStatus(item, 'completed');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.cancel, color: getStatusColor('canceled')),
                  title: const Text('Anulowane'),
                  onTap: () {
                    updateRepairItemStatus(item, 'canceled');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    void confirmDeleteRepairItem(String repairItemId) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Potwierdzenie usunięcia'),
            content: const Text('Czy na pewno chcesz usunąć ten element naprawy?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Anuluj'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<AppointmentBloc>().add(DeleteRepairItemEvent(
                    workshopId: appointment.workshopId,
                    appointmentId: appointment.id,
                    repairItemId: repairItemId,
                  ));
                  Navigator.of(context).pop();
                },
                child: const Text('Usuń'),
              ),
            ],
          );
        },
      );
    }

    return DataTable(
      columnSpacing: MediaQuery.of(context).size.width * 0.02,
      headingRowColor: WidgetStateColor.resolveWith((states) => Colors.blue.shade100),
      dataRowColor: WidgetStateColor.resolveWith((states) {
        return states.contains(WidgetState.selected) ? Colors.blue.shade50 : Colors.grey.shade100;
      }),
      columns: const [
        DataColumn(
          label: Expanded(
            child: Center(
              child: Text(
                'Opis',
                style: TextStyle(fontWeight: FontWeight.bold),
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
                style: TextStyle(fontWeight: FontWeight.bold),
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
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
      rows: appointment.repairItems.map((item) {
        return DataRow(
          cells: [
            DataCell(
              TextFormField(
                initialValue: item.description ?? 'Brak opisu',
                decoration: const InputDecoration(border: InputBorder.none),
                onChanged: (newValue) {
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
              ),
            ),
            DataCell(
              GestureDetector(
                onTap: () => showStatusChangeDialog(item),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      getStatusIcon(item.status),
                      color: getStatusColor(item.status),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            DataCell(
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => confirmDeleteRepairItem(item.id),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
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

    List<String> partsSuggestions = [];
    bool isSuggestionsLoaded = false;

    Future<void> loadPartsSuggestions() async {
      if (!isSuggestionsLoaded) {
        try {
          final String response = await rootBundle.loadString('assets/parts.json');
          final List<dynamic> data = json.decode(response);
          partsSuggestions = List<String>.from(data);
          isSuggestionsLoaded = true;
        } catch (e) {
          // Handle error
        }
      }
    }

    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              flex: 3,
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return partsSuggestions.where((String part) {
                    return part.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  partNameController.text = selection;
                },
                fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                  partNameController.addListener(() {
                    if (partNameController.text != textEditingController.text) {
                      textEditingController.text = partNameController.text;
                    }
                  });

                  return TextField(
                    controller: partNameController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Część',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    ),
                    onChanged: (value) {
                      partNameController.text = value;
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ilość',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: buyCostPartController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cena Hurtowa',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: partCostController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cena części',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: serviceCostController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cena usługi',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.green),
              onPressed: () {
                if (partNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Wprowadź nazwę części')),
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
              tooltip: 'Dodaj część',
            ),
          ],
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

    void confirmDeletePartItem(String partId) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Potwierdzenie usunięcia'),
            content: const Text('Czy na pewno chcesz usunąć tę część?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Anuluj'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<AppointmentBloc>().add(DeletePartEvent(
                    workshopId: appointment.workshopId,
                    appointmentId: appointment.id,
                    partId: partId,
                  ));
                  Navigator.of(context).pop();
                },
                child: const Text('Usuń'),
              ),
            ],
          );
        },
      );
    }

    return DataTable(
      columnSpacing: MediaQuery.of(context).size.width * 0.02,
      headingRowColor: WidgetStateColor.resolveWith((states) => Colors.green.shade100),
      dataRowColor: WidgetStateColor.resolveWith((states) {
        return states.contains(WidgetState.selected) ? Colors.green.shade50 : Colors.white;
      }),
      columns: const [
        DataColumn(
          label: Expanded(
            child: Text(
              'Część',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Text(
              'Ilość',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Text(
              'Hurtowa',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Text(
              'Części',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Text(
              'Suma',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Text(
              'Usługa',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Text(
              'Akcje',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
      rows: appointment.parts.map((part) {
        return DataRow(
          cells: [
            DataCell(
              TextFormField(
                initialValue: part.name,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 14),
                onChanged: (newValue) {
                  editPartValue(part, 'name', newValue);
                },
              ),
            ),
            DataCell(
              TextFormField(
                initialValue: part.quantity.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 14),
                onChanged: (newValue) {
                  editPartValue(part, 'quantity', int.tryParse(newValue) ?? part.quantity);
                },
              ),
            ),
            DataCell(
              TextFormField(
                initialValue: part.buyCostPart.toStringAsFixed(2),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 14),
                onChanged: (newValue) {
                  editPartValue(part, 'buyCostPart', double.tryParse(newValue) ?? part.buyCostPart);
                },
              ),
            ),
            DataCell(
              TextFormField(
                initialValue: part.costPart.toStringAsFixed(2),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 14),
                onChanged: (newValue) {
                  editPartValue(part, 'costPart', double.tryParse(newValue) ?? part.costPart);
                },
              ),
            ),
            DataCell(
              Center(
                child: Text(
                  (part.costPart * part.quantity).toStringAsFixed(2),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            DataCell(
              TextFormField(
                initialValue: part.costService.toStringAsFixed(2),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 14),
                onChanged: (newValue) {
                  editPartValue(part, 'costService', double.tryParse(newValue) ?? part.costService);
                },
              ),
            ),
            DataCell(
              Center(
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => confirmDeletePartItem(part.id),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCostSummary(Appointment appointment) {
    double totalBuyCostPart = appointment.parts.fold(0, (sum, item) => sum + (item.buyCostPart * item.quantity));
    double totalPartCost = appointment.parts.fold(0, (sum, item) => sum + (item.costPart * item.quantity));
    double totalServiceCost = appointment.parts.fold(0, (sum, item) => sum + item.costService);
    double totalMargin = totalPartCost - totalBuyCostPart;
    double totalCost = totalPartCost + totalServiceCost;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Suma cen części: ${totalPartCost.toStringAsFixed(2)} PLN'),
              Text('Marża: ${totalMargin.toStringAsFixed(2)} PLN'),
              Text('Suma cen usług: ${totalServiceCost.toStringAsFixed(2)} PLN'),
              Text(
                'Łączna cena: ${totalCost.toStringAsFixed(2)} PLN',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}