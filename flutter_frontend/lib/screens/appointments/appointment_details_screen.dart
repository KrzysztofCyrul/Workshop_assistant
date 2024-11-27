// lib/screens/appointments/appointment_details_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/appointment.dart';
import '../../models/repair_item.dart';
import '../../services/appointment_service.dart';
import '../../providers/auth_provider.dart';
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
      return appointment;
    } catch (e) {
      throw Exception('Błąd podczas pobierania szczegółów zlecenia: $e');
    }
  }

  Future<void> _navigateToAddRepairItem() async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AddRepairItemDialog(
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
      // Jeśli element jest oznaczany jako zakończony, poproś o wprowadzenie rzeczywistego czasu trwania
      actualDuration = await _showActualDurationDialog();
      if (actualDuration == null) {
        // Użytkownik anulował wprowadzenie czasu, nie aktualizuj statusu
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
      // Po udanej aktualizacji, odśwież dane
      setState(() {
        _appointmentFuture = _fetchAppointmentDetails();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status elementu naprawy został zaktualizowany')),
      );
    } catch (e) {
      // Obsłuż błąd, np. wyświetl komunikat
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

  // Funkcja pomocnicza do formatowania Duration na string w formacie "HH:MM:SS"
  String _formatDurationForBackend(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  // Funkcja pomocnicza do pobierania etykiety statusu
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

  // Funkcja pomocnicza do formatowania Duration
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 7,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairItem(RepairItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(
          item.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: item.isCompleted ? Colors.green : Colors.grey,
        ),
        title: Text(
          '${item.description} (Priorytet: ${item.order})',
          style: TextStyle(
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: Checkbox(
          value: item.isCompleted,
          onChanged: (value) {
            _updateRepairItemStatus(item, value!);
          },
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${_getStatusLabel(item.status)}'),
            Text('Wykonane przez: ${item.completedBy ?? 'N/D'}'),
            Text('Szacowany czas: ${item.estimatedDuration != null ? _formatDuration(item.estimatedDuration!) : 'N/D'}'),
            Text('Rzeczywisty czas: ${item.actualDuration != null ? _formatDuration(item.actualDuration!) : 'N/D'}'),
            Text('Koszt: ${item.cost} zł'),
            Text('Data utworzenia: ${DateFormat('dd-MM-yyyy HH:mm').format(item.createdAt.toLocal())}'),
            Text('Data aktualizacji: ${DateFormat('dd-MM-yyyy HH:mm').format(item.updatedAt.toLocal())}'),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły Zlecenia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Dodaj element naprawy',
            onPressed: _navigateToAddRepairItem,
          ),
        ],
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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informacje o pojeździe
                    _buildSectionTitle('Pojazd'),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
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
                    ),
                    const SizedBox(height: 16.0),
                    // Informacje o kliencie
                    _buildSectionTitle('Klient'),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            _buildDetailRow('Imię', appointment.client.firstName),
                            _buildDetailRow('Nazwisko', appointment.client.lastName),
                            _buildDetailRow('Email', appointment.client.email),
                            _buildDetailRow('Telefon', appointment.client.phone ?? 'Brak'),
                            _buildDetailRow('Adres', appointment.client.address ?? 'Brak'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    // Informacje o zleceniu
                    _buildSectionTitle('Szczegóły Zlecenia'),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            _buildDetailRow('Data', DateFormat('dd-MM-yyyy HH:mm').format(appointment.scheduledTime.toLocal())),
                            _buildDetailRow('Status', appointment.status),
                            _buildDetailRow('Przebieg', '${appointment.mileage} km'),
                            _buildDetailRow('Notatki', appointment.notes ?? 'Brak'),
                            _buildDetailRow('Całkowity koszt', '${totalCost.toStringAsFixed(2)} zł'),
                            _buildDetailRow('Szacowany czas', _formatDuration(totalEstimatedDuration)),
                          ],
                        ),
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
              ),
            );
          }
        },
      ),
    );
  }
}
