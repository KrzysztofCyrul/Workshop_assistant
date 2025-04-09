import 'package:flutter/material.dart';
import 'package:flutter_frontend/features/vehicles/domain/entities/vehicle.dart';
import 'package:flutter_frontend/features/vehicles/presentation/widgets/vehicle_info_card.dart';
import 'package:intl/intl.dart';

class VehicleDetailsView extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailsView({
    super.key,
    required this.vehicle,
  });

  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd HH:mm').format(date);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VehicleInfoCard(label: 'ID', value: vehicle.id),
          VehicleInfoCard(label: 'Marka', value: vehicle.make),
          VehicleInfoCard(label: 'Model', value: vehicle.model),
          VehicleInfoCard(label: 'Rok', value: vehicle.year.toString()),
          VehicleInfoCard(label: 'VIN', value: vehicle.vin),
          VehicleInfoCard(label: 'Numer rejestracyjny', value: vehicle.licensePlate),
          VehicleInfoCard(label: 'Przebieg', value: '${vehicle.mileage} km'),
          VehicleInfoCard(label: 'Utworzono', value: _formatDate(vehicle.createdAt)),
          VehicleInfoCard(label: 'Zaktualizowano', value: _formatDate(vehicle.updatedAt)),
        ],
      ),
    );
  }
}