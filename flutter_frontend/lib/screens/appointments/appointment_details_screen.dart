import 'package:flutter/cupertino.dart';
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
  int selectedHours = 0;
  int selectedMinutes = 0;

  final hours = List.generate(24, (index) => index);
  final minutes = List.generate(60, (index) => index);

  return showModalBottomSheet<String>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Wybierz czas trwania usługi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200, // wysokość obszaru z pickerami
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Godziny', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(initialItem: 0),
                            itemExtent: 32,
                            magnification: 1.2,
                            onSelectedItemChanged: (index) {
                              selectedHours = hours[index];
                            },
                            children: hours.map((h) => Center(child: Text(h.toString()))).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Minuty', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(initialItem: 0),
                            itemExtent: 32,
                            magnification: 1.2,
                            onSelectedItemChanged: (index) {
                              selectedMinutes = minutes[index];
                            },
                            children: minutes.map((m) => Center(child: Text(m.toString()))).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Anuluj'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final duration = Duration(hours: selectedHours, minutes: selectedMinutes);
                    final durationString = _formatDurationForBackend(duration);
                    Navigator.of(context).pop(durationString);
                  },
                  child: const Text('Zapisz'),
                ),
                const SizedBox(width: 16),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
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
    Theme.of(context);

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
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informacje o zleceniu
                  _buildSectionTitle('Szczegóły Zlecenia'),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
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
                          if (appointment.notes != null && appointment.notes!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Notatki:',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
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
                  ),
                  const SizedBox(height: 16.0),
                  // Informacje o pojeździe
                  _buildSectionTitle('Pojazd'),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
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
                  ),
                  const SizedBox(height: 16.0),
                  // Informacje o kliencie
                  _buildSectionTitle('Klient'),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
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
                            _buildDetailRow('Adres', appointment.client.address!, icon: Icons.map),
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
            );
          }
        },
      ),
    );
  }
}