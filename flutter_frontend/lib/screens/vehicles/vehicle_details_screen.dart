import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';

class VehicleDetailsScreen extends StatelessWidget {
  static const routeName = '/vehicle-details';

  final String workshopId;
  final String vehicleId;

  const VehicleDetailsScreen({Key? key, required this.workshopId, required this.vehicleId}) : super(key: key);

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('yyyy-MM-dd HH:mm').format(date);
    } catch (_) {
      return dateStr;
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
      body: FutureBuilder(
        future: Provider.of<VehicleProvider>(context, listen: false).fetchVehicleDetails(
          accessToken,
          workshopId,
          vehicleId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Błąd: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
            );
          } else {
            return Consumer<VehicleProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (provider.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        provider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    ),
                  );
                } else if (provider.vehicle == null) {
                  return const Center(child: Text('Nie znaleziono pojazdu.'));
                } else {
                  final vehicle = provider.vehicle!;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Table(
                      columnWidths: {
                        0: IntrinsicColumnWidth(),
                        1: FlexColumnWidth(),
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
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
