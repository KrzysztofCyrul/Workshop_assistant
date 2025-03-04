import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_record_provider.dart';
import '../../models/service_record.dart';

class VehicleDetailsScreen extends StatefulWidget {
  static const routeName = '/vehicle-details';

  final String workshopId;
  final String vehicleId;

  const VehicleDetailsScreen({super.key, required this.workshopId, required this.vehicleId});

  @override
  _VehicleDetailsScreenState createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  late Future<void> _vehicleFuture;
  late Future<void> _serviceRecordsFuture;

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('yyyy-MM-dd HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;
    _vehicleFuture = _fetchVehicleDetails(accessToken);
    _serviceRecordsFuture = _fetchServiceRecords(accessToken);
  }

  Future<void> _fetchVehicleDetails(String? accessToken) async {
    if (accessToken != null) {
      await Provider.of<VehicleProvider>(context, listen: false)
          .fetchVehicleDetails(accessToken, widget.workshopId, widget.vehicleId);
    }
  }

  Future<void> _fetchServiceRecords(String? accessToken) async {
    if (accessToken != null) {
      await Provider.of<ServiceRecordProvider>(context, listen: false)
          .fetchServiceRecords(accessToken, widget.workshopId, widget.vehicleId);
    }
  }

  TableRow _buildRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(value),
        ),
      ],
    );
  }

  Widget _buildServiceRecordsList(List<ServiceRecord> records) {
    if (records.isEmpty) {
      return const Text('Brak rekordów serwisowych dla tego pojazdu.');
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text('Data: ${record.date}, Przebieg: ${record.mileage} km'),
            subtitle: Text(record.description),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;

    if (accessToken == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Szczegóły Pojazdu'),
        ),
        body: const Center(
          child: Text(
            'Brak dostępu do danych użytkownika.\nZaloguj się, aby wyświetlić szczegóły pojazdu.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły Pojazdu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<void>(
          future: Future.wait([_vehicleFuture, _serviceRecordsFuture]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Błąd: ${snapshot.error}'),
              );
            } else {
              final vehicleProvider = Provider.of<VehicleProvider>(context);
              final serviceRecordProvider = Provider.of<ServiceRecordProvider>(context);

              if (vehicleProvider.isLoading || serviceRecordProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (vehicleProvider.errorMessage != null) {
                return Center(
                  child: Text(vehicleProvider.errorMessage!),
                );
              }

              if (vehicleProvider.vehicle == null) {
                return const Center(child: Text('Nie znaleziono pojazdu.'));
              }

              final vehicle = vehicleProvider.vehicle!;
              final records = serviceRecordProvider.serviceRecords;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tabela z danymi pojazdu
                  Table(
                    columnWidths: const {
                      0: const IntrinsicColumnWidth(),
                      1: const FlexColumnWidth(),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      _buildRow('ID:', vehicle.id),
                      _buildRow('Marka:', vehicle.make),
                      _buildRow('Model:', vehicle.model),
                      _buildRow('Rok:', vehicle.year.toString()),
                      _buildRow('VIN:', vehicle.vin),
                      _buildRow('Rejestracja:', vehicle.licensePlate),
                      _buildRow('Przebieg:', '${vehicle.mileage} km'),
                      _buildRow('Data utworzenia:', '${vehicle.createdAt}'),
                      _buildRow('Data aktualizacji:', '${vehicle.updatedAt}'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    'Historia Serwisowa:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (serviceRecordProvider.errorMessage != null)
                    Text(serviceRecordProvider.errorMessage!, style: const TextStyle(color: Colors.red))
                  else
                    _buildServiceRecordsList(records),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
