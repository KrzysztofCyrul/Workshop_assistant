import 'package:flutter/material.dart';
import 'package:flutter_frontend/features/vehicles/domain/entities/vehicle.dart';
import 'package:flutter_frontend/features/vehicles/presentation/screens/vehicle_details_screen.dart';

class VehiclesListWidget extends StatelessWidget {
  final List<Vehicle> vehicles;
  final String searchQuery;
  final String workshopId;

  const VehiclesListWidget({
    super.key,
    required this.vehicles,
    required this.searchQuery,
    required this.workshopId,
  });

  List<Vehicle> _filterVehicles() {
    if (searchQuery.isEmpty) return vehicles;
    
    final query = searchQuery.toLowerCase();
    return vehicles.where((vehicle) {
      final make = vehicle.make.toLowerCase();
      final model = vehicle.model.toLowerCase();
      final plate = vehicle.licensePlate.toLowerCase();
      return make.contains(query) || 
             model.contains(query) || 
             plate.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredVehicles = _filterVehicles();

    if (filteredVehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 60, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              'Brak wyników dla: "$searchQuery"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: filteredVehicles.length,
      itemBuilder: (context, index) {
        final vehicle = filteredVehicles[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.directions_car, color: Colors.blue),
            title: Text('${vehicle.make} ${vehicle.model}'),
            subtitle: Text('Rejestracja: ${vehicle.licensePlate}'),
            onTap: () => Navigator.of(context).pushNamed(
              VehicleDetailsScreen.routeName,
              arguments: {
                'workshopId': workshopId,
                'vehicleId': vehicle.id,
              },
            ),
          ),
        );
      },
    );
  }
}