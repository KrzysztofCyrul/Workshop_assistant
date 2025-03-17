import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/providers/vehicle_provider1.dart';
import 'package:flutter_frontend/presentation/screens/vehicles/vehicle_edit_screen.dart';
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

  Widget _buildInfoCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildBody(VehicleProvider1 provider) {
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (provider.error != null) return Center(child: Text(provider.error!));
    if (provider.selectedVehicle == null) return const Center(child: Text('Vehicle not found'));

    final vehicle = provider.selectedVehicle!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('ID:', vehicle.id),
          _buildInfoCard('Make:', vehicle.make),
          _buildInfoCard('Model:', vehicle.model),
          _buildInfoCard('Year:', vehicle.year.toString()),
          _buildInfoCard('VIN:', vehicle.vin),
          _buildInfoCard('License Plate:', vehicle.licensePlate),
          _buildInfoCard('Mileage:', '${vehicle.mileage} km'),
          _buildInfoCard('Created:', _formatDate(vehicle.createdAt)),
          _buildInfoCard('Updated:', _formatDate(vehicle.updatedAt)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushNamed(
                VehicleEditScreen.routeName,
                arguments: {
                  'workshopId': widget.workshopId,
                  'vehicleId': widget.vehicleId,
                },
              );
            },
          ),
        ],
      ),
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