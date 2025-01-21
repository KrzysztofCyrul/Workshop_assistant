import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/appointment.dart';
import '../../models/repair_item.dart';
import '../../services/appointment_service.dart';
import '../../providers/auth_provider.dart';
import '../service_records/service_history_screen.dart';
import 'add_repair_item_dialog.dart';
import 'package:intl/intl.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  static const routeName = '/appointment-details';

  final String workshopId;
  final String appointmentId;

  const AppointmentDetailsScreen({
    Key? key,
    required this.workshopId,
    required this.appointmentId,
  }) : super(key: key);

  @override
  _AppointmentDetailsScreenState createState() => _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  late Future<Appointment> _appointmentFuture;
  Appointment? _currentAppointment; // Przechowujemy załadowaną wizytę

  @override
  void initState() {
    super.initState();
    _appointmentFuture = _fetchAppointmentDetails();
  }

  Future<Appointment> _fetchAppointmentDetails() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken!;

    try {
      final appointment = await AppointmentService.getAppointmentDetails(
        accessToken,
        widget.workshopId,
        widget.appointmentId,
      );
      _currentAppointment = appointment;
      // Odśwież ekran, żeby zaktualizować AppBar z ikoną historii
      setState(() {});
      return appointment;
    } catch (e) {
      throw Exception('Błąd podczas pobierania szczegółów zlecenia: $e');
    }
  }

  double _calculateDiscountedCost(double originalCost, String? segment) {
    double discountPercentage;
    switch (segment) {
      case 'A':
        discountPercentage = 0.10;
        break;
      case 'B':
        discountPercentage = 0.06;
        break;
      case 'C':
        discountPercentage = 0.03;
        break;
      case 'D':
      default:
        discountPercentage = 0.0;
        break;
    }
    return originalCost * (1 - discountPercentage);
  }

  Future<void> _navigateToAddRepairItem() async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AddMultipleRepairItemsDialog(
          appointmentId: widget.appointmentId,
          workshopId: widget.workshopId,
        );
      },
    );

    if (result == true) {
      // Jeśli element został dodany, odśwież szczegóły zlecenia
      setState(() {
        _appointmentFuture = _fetchAppointmentDetails();
      });
    }
  }

  Future<void> _updateRepairItemStatus(RepairItem item, bool isCompleted) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken!;

    String? actualDuration;

    if (isCompleted) {
      actualDuration = await _showActualDurationDialog();
      if (actualDuration == null) {
        return;
      }
    }

    try {
      await AppointmentService.updateRepairItem(
        accessToken,
        widget.workshopId,
        widget.appointmentId,
        item.id,
        isCompleted: isCompleted,
        actualDuration: actualDuration,
      );
      setState(() {
        _appointmentFuture = _fetchAppointmentDetails();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status elementu naprawy został zaktualizowany')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błąd podczas aktualizacji statusu')),
      );
    }
  }

  Future<String?> _showActualDurationDialog() async {
    final _durationFormKey = GlobalKey<FormState>();
    int? _hours;
    int? _minutes;

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Wprowadź rzeczywisty czas trwania'),
          content: Form(
            key: _durationFormKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Godziny'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wprowadź godziny';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Wprowadź poprawną liczbę';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _hours = int.parse(value!);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Minuty'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wprowadź minuty';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Wprowadź poprawną liczbę';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _minutes = int.parse(value!);
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_durationFormKey.currentState!.validate()) {
                  _durationFormKey.currentState!.save();
                  final duration = Duration(hours: _hours!, minutes: _minutes!);
                  final durationString = _formatDurationForBackend(duration);
                  Navigator.of(context).pop(durationString);
                }
              },
              child: const Text('Zapisz'),
            ),
          ],
        );
      },
    );
  }

  String _formatDurationForBackend(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Do wykonania';
      case 'in_progress':
        return 'W trakcie';
      case 'completed':
        return 'Zakończone';
      default:
        return status;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    return '$hours h $minutes min';
  }

  double _calculateTotalCost(List<RepairItem> repairItems) {
    return repairItems.fold(0.0, (sum, item) => sum + item.cost);
  }

  Duration _calculateTotalEstimatedDuration(List<RepairItem> repairItems) {
    return repairItems.fold(Duration.zero, (sum, item) => sum + (item.estimatedDuration ?? Duration.zero));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
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

  Widget _buildRepairItem(RepairItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          item.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: item.isCompleted ? Colors.green : Colors.grey,
          size: 32,
        ),
        title: Text(
          item.description,
          style: TextStyle(
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Status: ${_getStatusLabel(item.status)}'),
            Text('Koszt: ${item.cost.toStringAsFixed(2)} PLN'),
            if (item.estimatedDuration != null)
              Text('Szacowany czas: ${_formatDuration(item.estimatedDuration!)}'),
            if (item.actualDuration != null)
              Text('Rzeczywisty czas: ${_formatDuration(item.actualDuration!)}'),
            if (item.completedBy != null)
              Text('Wykonane przez: ${item.completedBy}'),
          ],
        ),
        trailing: GestureDetector(
          onTap: () {
            _updateRepairItemStatus(item, !item.isCompleted);
          },
          child: Icon(
            item.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: item.isCompleted ? Colors.green : Colors.grey,
            size: 32,
          ),
        ),
        isThreeLine: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Wyliczamy dynamicznie akcje w AppBar w zależności od tego, czy mamy załadowane dane.
List<Widget> appBarActions = [];

// Jeśli mamy dane o wizycie, dodaj ikonę historii jako pierwszą:
if (_currentAppointment != null) {
  appBarActions.add(
    IconButton(
      icon: const Icon(Icons.history),
      tooltip: 'Historia pojazdu',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VehicleServiceHistoryScreen(
              workshopId: widget.workshopId,
              vehicleId: _currentAppointment!.vehicle.id,
            ),
          ),
        );
      },
    ),
  );
}

// Na końcu dodaj ikonę plusa:
appBarActions.add(
  IconButton(
    icon: const Icon(Icons.add),
    tooltip: 'Dodaj element naprawy',
    onPressed: _navigateToAddRepairItem,
  ),
);

    return Scaffold(
      appBar: AppBar(
        title: _currentAppointment == null
            ? const Text('Ładowanie...')
            : Text(
                '${DateFormat('dd-MM-yyyy').format(_currentAppointment!.scheduledTime.toLocal())} '
                '- ${_currentAppointment!.vehicle.make} ${_currentAppointment!.vehicle.model}',
              ),
        actions: appBarActions,
      ),
      body: FutureBuilder<Appointment>(
        future: _appointmentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _appointmentFuture = _fetchAppointmentDetails();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Ponów próbę'),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Nie znaleziono zlecenia'));
          } else {
            final appointment = snapshot.data!;
            final totalCost = _calculateTotalCost(appointment.repairItems);
            final totalEstimatedDuration = _calculateTotalEstimatedDuration(appointment.repairItems);
            final discountedCost = _calculateDiscountedCost(totalCost, appointment.client.segment);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Szczegóły zlecenia
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ExpansionTile(
                      title: const Text('Szczegóły Zlecenia'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                'Data',
                                DateFormat('dd-MM-yyyy HH:mm').format(appointment.scheduledTime.toLocal()),
                                icon: Icons.calendar_today,
                              ),
                              _buildDetailRow(
                                'Status',
                                _getStatusLabel(appointment.status),
                                icon: Icons.info,
                              ),
                              _buildDetailRow(
                                'Przebieg',
                                '${appointment.mileage} km',
                                icon: Icons.speed,
                              ),
                              _buildDetailRow(
                                'Szacowany czas',
                                _formatDuration(totalEstimatedDuration),
                                icon: Icons.timer,
                              ),
                              _buildDetailRow(
                                'Całkowity koszt',
                                '${totalCost.toStringAsFixed(2)} PLN',
                                icon: Icons.attach_money,
                              ),
                                _buildDetailRow(
                                  'Koszt z rabatem',
                                  '${discountedCost.toStringAsFixed(2)} PLN',
                                  icon: Icons.money_off,
                                ),
                              if (appointment.notes != null && appointment.notes!.isNotEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Notatki:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              if (appointment.notes != null && appointment.notes!.isNotEmpty)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    appointment.notes!,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Szczegóły pojazdu
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ExpansionTile(
                      title: const Text('Szczegóły Pojazdu'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildDetailRow('Marka', appointment.vehicle.make),
                              _buildDetailRow('Model', appointment.vehicle.model),
                              _buildDetailRow('Rok', appointment.vehicle.year.toString()),
                              _buildDetailRow('VIN', appointment.vehicle.vin),
                              _buildDetailRow('Rejestracja', appointment.vehicle.licensePlate),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Szczegóły klienta
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ExpansionTile(
                      title: const Text('Szczegóły Klienta'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                'Imię i nazwisko',
                                '${appointment.client.firstName} ${appointment.client.lastName}',
                                icon: Icons.person,
                              ),
                              _buildDetailRow('Email', appointment.client.email, icon: Icons.email),
                              _buildDetailRow('Telefon', appointment.client.phone ?? 'Brak', icon: Icons.phone),
                              if (appointment.client.address != null)
                                _buildDetailRow('Adres', appointment.client.address!, icon: Icons.home),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Elementy naprawy
                  _buildSectionTitle('Elementy Naprawy'),
                  appointment.repairItems.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Brak elementów naprawy.'),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: appointment.repairItems.length,
                          itemBuilder: (context, index) {
                            final item = appointment.repairItems[index];
                            return _buildRepairItem(item);
                          },
                        ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
