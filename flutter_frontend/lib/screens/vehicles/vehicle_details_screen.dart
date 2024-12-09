import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';

class VehicleDetailsScreen extends StatelessWidget {
  static const routeName = '/vehicle-details';

  final String workshopId;
  final String vehicleId;

  const VehicleDetailsScreen({Key? key, required this.workshopId, required this.vehicleId}) : super(key: key);

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
          child: Text('Brak dostępu do danych użytkownika.'),
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
            return Center(child: Text('Błąd: ${snapshot.error}'));
          } else {
            return Consumer<VehicleProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (provider.errorMessage != null) {
                  return Center(child: Text(provider.errorMessage!));
                } else if (provider.vehicle == null) {
                  return const Center(child: Text('Nie znaleziono pojazdu.'));
                } else {
                  final vehicle = provider.vehicle!;
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${vehicle.id}', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('Marka: ${vehicle.make}'),
                        const SizedBox(height: 8),
                        Text('Model: ${vehicle.model}'),
                        const SizedBox(height: 8),
                        Text('Rok: ${vehicle.year}'),
                        const SizedBox(height: 8),
                        Text('VIN: ${vehicle.vin}'),
                        const SizedBox(height: 8),
                        Text('Rejestracja: ${vehicle.licensePlate}'),
                        const SizedBox(height: 8),
                        Text('Data Utworzenia: ${vehicle.createdAt}'),
                        const SizedBox(height: 8),
                        Text('Data Aktualizacji: ${vehicle.updatedAt}'),
                        const SizedBox(height: 8),
                        Text('Przebieg: ${vehicle.mileage} km'),
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