import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/providers/vehicle_provider1.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/auth_provider.dart';

class VehicleDetailsScreen extends StatefulWidget {
  static const routeName = '/vehicle-details';
  final String vehicleId;
  final String workshopId;

  const VehicleDetailsScreen({
    super.key,
    required this.vehicleId,
    required this.workshopId,
  });

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  late Future<void> _vehicleFuture;

  @override
  void initState() {
    super.initState();
    _vehicleFuture = _fetchVehicleDetails();
  }

  Future<void> _fetchVehicleDetails() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final vehicleProvider = Provider.of<VehicleProvider1>(context, listen: false);
    
    if (authProvider.accessToken == null) {
      throw Exception('User not authenticated');
    }

    await vehicleProvider.fetchVehicleDetails(
      authProvider.accessToken!,
      widget.workshopId,
      widget.vehicleId,
    );
  }

  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd HH:mm').format(date);

  TableRow _buildTableRow(String label, String value) => TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(value),
      ),
    ],
  );

  Widget _buildBody(VehicleProvider1 provider) {
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (provider.error != null) return Center(child: Text(provider.error!));
    if (provider.selectedVehicle == null) return const Center(child: Text('Vehicle not found'));

    final vehicle = provider.selectedVehicle!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Table(
        columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
        children: [
          _buildTableRow('ID:', vehicle.id),
          _buildTableRow('Make:', vehicle.make),
          _buildTableRow('Model:', vehicle.model),
          _buildTableRow('Year:', vehicle.year.toString()),
          _buildTableRow('VIN:', vehicle.vin),
          _buildTableRow('License Plate:', vehicle.licensePlate),
          _buildTableRow('Mileage:', '${vehicle.mileage} km'),
          _buildTableRow('Created:', _formatDate(vehicle.createdAt)),
          _buildTableRow('Updated:', _formatDate(vehicle.updatedAt)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle Details')),
      body: FutureBuilder(
        future: _vehicleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Consumer<VehicleProvider1>(
            builder: (context, provider, _) => _buildBody(provider),
          );
        },
      ),
    );
  }
}