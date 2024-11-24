import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/appointment.dart';
import '../../models/repair_item.dart';
import '../../services/appointment_service.dart';
import '../../providers/auth_provider.dart';
import 'package:intl/intl.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  static const routeName = '/appointment-details';

  final String workshopId;
  final String appointmentId;

  AppointmentDetailsScreen({
    required this.workshopId,
    required this.appointmentId,
  });

  @override
  _AppointmentDetailsScreenState createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  Appointment? _appointment;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAppointmentDetails();
  }

  Future<void> _fetchAppointmentDetails() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken!;

    try {
      final appointment = await AppointmentService.getAppointmentDetails(
        accessToken,
        widget.workshopId,
        widget.appointmentId,
      );
      setState(() {
        _appointment = appointment;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Szczegóły Zlecenia'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Szczegóły Zlecenia'),
        ),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    if (_appointment == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Szczegóły Zlecenia'),
        ),
        body: Center(child: Text('Nie znaleziono zlecenia')),
      );
    }

    final appointment = _appointment!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Szczegóły Zlecenia'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Informacje o pojeździe
              _buildSectionTitle('Pojazd'),
              _buildDetailRow('Marka', appointment.vehicle.make),
              _buildDetailRow('Model', appointment.vehicle.model),
              _buildDetailRow('Rok', appointment.vehicle.year.toString()),
              _buildDetailRow('VIN', appointment.vehicle.vin),
              _buildDetailRow('Rejestracja', appointment.vehicle.licensePlate),
              SizedBox(height: 16.0),
              // Informacje o kliencie
              _buildSectionTitle('Klient'),
              _buildDetailRow('Imię', appointment.client.firstName),
              _buildDetailRow('Nazwisko', appointment.client.lastName),
              _buildDetailRow('Email', appointment.client.email),
              _buildDetailRow('Telefon', appointment.client.phone ?? 'Brak'),
              _buildDetailRow('Adres', appointment.client.address ?? 'Brak'),
              SizedBox(height: 16.0),
              // Informacje o zleceniu
              _buildSectionTitle('Szczegóły Zlecenia'),
              _buildDetailRow(
                  'Data',
                  DateFormat('dd-MM-yyyy HH:mm')
                      .format(appointment.scheduledTime.toLocal())),
              _buildDetailRow('Status', appointment.status),
              _buildDetailRow('Przebieg', '${appointment.mileage} km'),
              _buildDetailRow('Notatki', appointment.notes ?? 'Brak'),
              SizedBox(height: 16.0),
              // Elementy naprawy
              _buildSectionTitle('Elementy Naprawy'),
              if (appointment.repairItems.isEmpty)
                Text('Brak elementów naprawy.')
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: appointment.repairItems.length,
                  itemBuilder: (context, index) {
                    final item = appointment.repairItems[index];
                    return _buildRepairItem(item);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRepairItem(RepairItem item) {
    return Card(
      child: ListTile(
        title: Text(item.description),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${item.status}'),
            Text('Zakończone: ${item.isCompleted ? 'Tak' : 'Nie'}'),
            Text('Wykonane przez: ${item.completedById ?? 'N/D'}'),
            Text(
                'Utworzono: ${DateFormat('dd-MM-yyyy HH:mm').format(item.createdAt.toLocal())}'),
            Text(
                'Zaktualizowano: ${DateFormat('dd-MM-yyyy HH:mm').format(item.updatedAt.toLocal())}'),
            Text('Kolejność: ${item.order}'),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
