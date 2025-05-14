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
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  vehicles.isEmpty ? Icons.directions_car_filled : Icons.search_off,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  vehicles.isEmpty 
                      ? 'Klient nie posiada żadnych pojazdów' 
                      : 'Brak wyników dla: "$searchQuery"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(
                    '/add-vehicle',
                    arguments: {
                      'workshopId': workshopId,
                      'clientId': vehicles.isNotEmpty ? vehicles.first.clientId : null,
                    },
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Dodaj nowy pojazd'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12.0),
      itemCount: filteredVehicles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final vehicle = filteredVehicles[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Icon(
                Icons.directions_car,
                color: Colors.blue.shade800,
                size: 24,
              ),
            ),
            title: Text(
              '${vehicle.make} ${vehicle.model}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pin, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Rejestracja: ${vehicle.licensePlate}',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.date_range, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Rok produkcji: ${vehicle.year}',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.primary,
            ),
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