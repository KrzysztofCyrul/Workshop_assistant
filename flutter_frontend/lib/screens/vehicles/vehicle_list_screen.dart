import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';
import 'vehicle_details_screen.dart';

class VehicleListScreen extends StatelessWidget {
  static const routeName = '/vehicle-list';

  final String workshopId;

  const VehicleListScreen({Key? key, required this.workshopId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;

    if (accessToken == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lista Pojazdów'),
        ),
        body: const Center(
          child: Text('Brak dostępu do danych użytkownika.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista Pojazdów'),
      ),
      body: FutureBuilder(
        future: Provider.of<VehicleProvider>(context, listen: false).fetchVehicles(
          accessToken,
          workshopId,
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
                } else if (provider.vehicles.isEmpty) {
                  return const Center(child: Text('Brak pojazdów.'));
                } else {
                  return ListView.builder(
                    itemCount: provider.vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = provider.vehicles[index];
                      return ListTile(
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
                      );
                    },
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