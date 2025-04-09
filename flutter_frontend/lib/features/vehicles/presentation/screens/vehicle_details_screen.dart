import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/core/di/injector_container.dart';
import 'package:flutter_frontend/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:flutter_frontend/features/vehicles/presentation/bloc/vehicle_bloc.dart';
import 'package:flutter_frontend/features/vehicles/presentation/screens/vehicle_edit_screen.dart';
import 'package:flutter_frontend/features/auth/presentation/bloc/auth_bloc.dart';
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
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      getIt<AuthLocalDataSource>().getAccessToken().then((accessToken) {
        if (accessToken != null) {
          context.read<VehicleBloc>().add(LoadVehicleDetailsEvent(
            accessToken: accessToken,
            workshopId: widget.workshopId,
            vehicleId: widget.vehicleId,
          ));
        }
      });
    }
  }
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

  Widget _buildBody(VehicleState state) {
    if (state is VehicleInitial || state is VehicleLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is VehicleError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadVehicleDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (state is VehicleDetailsLoaded) {
      final vehicle = state.vehicle;
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
    return const Center(child: Text('Vehicle not found'));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return Scaffold(
            appBar: AppBar(title: const Text('Szczegóły Pojazdu')),
            body: const Center(
              child: Text(
                'Brak dostępu do danych użytkownika.\nZaloguj się, aby zobaczyć szczegóły pojazdu.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            if (didPop) {
              getIt<AuthLocalDataSource>().getAccessToken().then((accessToken) {
                if (accessToken != null) {
                  context.read<VehicleBloc>()
                    ..add(ResetVehicleStateEvent())
                    ..add(LoadVehiclesEvent(
                      accessToken: accessToken,
                      workshopId: widget.workshopId,
                    ));
                }
              });
            }
          },
          child: Scaffold(
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
            body: BlocBuilder<VehicleBloc, VehicleState>(
              builder: (context, state) => _buildBody(state),
            ),
          ),
        );
      },
    );
  }
}