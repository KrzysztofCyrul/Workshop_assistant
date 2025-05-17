import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/features/vehicles/domain/entities/vehicle.dart';
import 'package:flutter_frontend/features/vehicles/presentation/bloc/vehicle_bloc.dart';
import 'package:flutter_frontend/features/vehicles/presentation/screens/vehicle_details_screen.dart';
import 'package:flutter_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_frontend/core/widgets/custom_app_bar.dart';

class ClientVehicleListScreen extends StatefulWidget {
  static const routeName = '/client-vehicle-list';

  final String workshopId;
  final String clientId;

  const ClientVehicleListScreen({super.key, required this.workshopId, required this.clientId});

  @override
  State<ClientVehicleListScreen> createState() => _ClientVehicleListScreenState();
}

class _ClientVehicleListScreenState extends State<ClientVehicleListScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVehicles();
    });
  }

void _loadVehicles() {
  if (mounted) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<VehicleBloc>().add(LoadVehiclesForClientEvent(
        workshopId: widget.workshopId,
        clientId: widget.clientId,
      ));
    }
  }
}

  List<Vehicle> _filterVehicles(List<Vehicle> vehicles) {
    if (_searchQuery.isEmpty) return vehicles;
    
    final query = _searchQuery.toLowerCase();
    return vehicles.where((vehicle) {
      return vehicle.make.toLowerCase().contains(query) ||
             vehicle.model.toLowerCase().contains(query) ||
             vehicle.licensePlate.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return Scaffold(
            appBar: CustomAppBar(
              title: 'Lista Pojazdów Klienta',
              feature: 'vehicles',
            ),
            body: const Center(
              child: Text(
                'Brak dostępu do danych użytkownika.\nZaloguj się, aby zobaczyć listę pojazdów.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Scaffold(          appBar: CustomAppBar(
            title: 'Lista Pojazdów Klienta',
            feature: 'vehicles',
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadVehicles,
              ),
            ],
          ),
          body: BlocConsumer<VehicleBloc, VehicleState>(
            listener: (context, state) {
              if (state is VehicleError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () async => _loadVehicles(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Wyszukaj pojazd',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) => setState(() => _searchQuery = value),
                      ),
                    ),
                    Expanded(
                      child: _buildContent(state),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildContent(VehicleState state) {
    if (state is VehicleInitial || state is VehicleLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is VehicleError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadVehicles,
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      );
    }

    if (state is! VehiclesLoaded) {
      return const Center(child: Text('Nieznany stan'));
    }

    final vehicles = _filterVehicles(state.vehicles);

    if (vehicles.isEmpty) {
      return _buildEmptyState(_searchQuery.isEmpty
          ? 'Brak pojazdów klienta'
          : 'Brak wyników dla: "$_searchQuery"');
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.directions_car, color: Colors.blue),
            title: Text('${vehicle.make} ${vehicle.model}'.trim()),
            subtitle: Text('Rejestracja: ${vehicle.licensePlate}'),
            onTap: () => Navigator.pushNamed(
              context,
              VehicleDetailsScreen.routeName,
              arguments: {
                'workshopId': widget.workshopId,
                'vehicleId': vehicle.id,
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            message.contains('Brak wyników') ? Icons.search_off : Icons.directions_car,
            size: 60,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadVehicles,
            icon: const Icon(Icons.refresh),
            label: const Text('Odśwież'),
          ),
        ],
      ),
    );
  }
}