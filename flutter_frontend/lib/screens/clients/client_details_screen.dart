import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/client.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:intl/intl.dart';
import '../vehicles/vehicle_details_screen.dart';

class ClientDetailsScreen extends StatelessWidget {
  static const routeName = '/client-details';

  final Client client;

  const ClientDetailsScreen({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final workshopId = authProvider.user?.employeeProfiles.first.workshopId;
    final accessToken = authProvider.accessToken;

    if (accessToken == null || workshopId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${client.firstName} ${client.lastName}'),
        ),
        body: const Center(
          child: Text('Brak dostępu do danych użytkownika.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${client.firstName} ${client.lastName}'),
      ),
      body: FutureBuilder(
        future: Provider.of<VehicleProvider>(context, listen: false).fetchVehiclesForClient(
          accessToken,
          workshopId,
          client.id,
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
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${client.firstName} ${client.lastName}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8, width: double.infinity),
                                // Text('ID: ${client.id}', style: const TextStyle(fontSize: 16)),
                                // const SizedBox(height: 8),
                                Text('Email: ${client.email}', style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 8),
                                Text('Telefon: ${client.phone ?? 'Brak'}', style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 8),
                                Text('Adres: ${client.address ?? 'Brak'}', style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 8),
                                Text('Segment: ${client.segment ?? 'Brak segmentu'}', style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 8),
                                Text(
                                  'Data Utworzenia: ${DateFormat('dd-MM-yyyy').format(client.createdAt)}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Data Aktualizacji: ${DateFormat('dd-MM-yyyy').format(client.updatedAt)}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Pojazdy:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: provider.vehicles.length,
                            itemBuilder: (context, index) {
                              final vehicle = provider.vehicles[index];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: ListTile(
                                  leading: Icon(Icons.directions_car, color: Colors.blue[800]),
                                  title: Text('${vehicle.make} ${vehicle.model}'),
                                  subtitle: Text('Rejestracja: ${vehicle.licensePlate}'),
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                      VehicleDetailsScreen.routeName,
                                      arguments: {
                                        'workshopId': workshopId,
                                        'vehicleId': vehicle.id,
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
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
