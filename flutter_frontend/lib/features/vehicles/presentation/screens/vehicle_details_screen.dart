import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/features/vehicles/presentation/bloc/vehicle_bloc.dart';
import 'package:flutter_frontend/features/vehicles/presentation/screens/vehicle_edit_screen.dart';
import 'package:intl/intl.dart';

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
  @override
  void initState() {
    super.initState();
    _loadVehicleDetails();
  }

  void _loadVehicleDetails() {
    if (mounted) {
      context.read<VehicleBloc>().add(LoadVehicleDetailsEvent(
        workshopId: widget.workshopId,
        vehicleId: widget.vehicleId,
      ));
    }
  }

  String _formatDate(DateTime date) => DateFormat('dd.MM.yyyy HH:mm').format(date);

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 16),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
          ],
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(VehicleState state) {
    if (state is VehicleInitial || state is VehicleLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is VehicleError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadVehicleDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      );
    }
    if (state is VehicleDetailsLoaded) {
      final vehicle = state.vehicle;
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    '${vehicle.make} ${vehicle.model}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vehicle.licensePlate,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailSection(
              'Informacje podstawowe',
              [
                _buildInfoTile('Rok produkcji:', vehicle.year.toString(), icon: Icons.calendar_today),
                _buildInfoTile('Przebieg:', '${vehicle.mileage} km', icon: Icons.speed),
                _buildInfoTile('VIN:', vehicle.vin, icon: Icons.qr_code),
              ],
            ),
            _buildDetailSection(
              'Informacje systemowe',
              [
                _buildInfoTile('ID pojazdu:', vehicle.id, icon: Icons.tag),
                _buildInfoTile('Data utworzenia:', _formatDate(vehicle.createdAt), icon: Icons.access_time),
                _buildInfoTile('Ostatnia aktualizacja:', _formatDate(vehicle.updatedAt), icon: Icons.update),
              ],
            ),
          ],
        ),
      );
    }
    return const Center(child: Text('Nie znaleziono pojazdu'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły Pojazdu'),
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
              ).then((_) => _loadVehicleDetails());
            },
          ),
        ],
      ),
      body: PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          if (didPop) {
            context.read<VehicleBloc>()
              ..add(ResetVehicleStateEvent())
              ..add(LoadVehiclesEvent(
                workshopId: widget.workshopId,
              ));
          }
        },
        child: BlocBuilder<VehicleBloc, VehicleState>(
          builder: (context, state) => _buildBody(state),
        ),
      ),
    );
  }
}