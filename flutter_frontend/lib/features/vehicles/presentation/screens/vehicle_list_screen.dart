import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/features/vehicles/domain/entities/vehicle.dart';
import 'package:flutter_frontend/features/vehicles/presentation/bloc/vehicle_bloc.dart';
import 'package:flutter_frontend/features/vehicles/presentation/screens/vehicle_details_screen.dart';
import 'package:flutter_frontend/features/vehicles/presentation/screens/add_vehicle_screen.dart';

class VehicleListScreen extends StatefulWidget {
  static const routeName = '/vehicle-list';
  final String workshopId;

  const VehicleListScreen({super.key, required this.workshopId});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadVehicles();
    });
  }

  void _loadVehicles() {
    if (!mounted) return;
    debugPrint('VehicleListScreen - Loading vehicles for workshop: ${widget.workshopId}');
    context.read<VehicleBloc>().add(LoadVehiclesEvent(
          workshopId: widget.workshopId,
        ));
  }

  List<Vehicle> _filterVehicles(List<Vehicle> vehicles) {
    if (_searchQuery.isEmpty) return vehicles;

    final query = _searchQuery.toLowerCase();
    return vehicles.where((vehicle) {
      return vehicle.make.toLowerCase().contains(query) == true ||
          vehicle.model.toLowerCase().contains(query) == true ||
          vehicle.licensePlate.toLowerCase().contains(query) == true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista Pojazdów'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVehicles,
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                AddVehicleScreen.routeName,
                arguments: {'workshopId': widget.workshopId},
              );

              if (result == true) {
                _loadVehicles();
              }
            },
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
  }

  Widget _buildContent(VehicleState state) {
    if (state is VehicleUnauthenticated) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 20),
            Text(state.message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Zaloguj się'),
            ),
          ],
        ),
      );
    }

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
      return _buildEmptyState(_searchQuery.isEmpty ? 'Brak pojazdów w warsztacie' : 'Brak wyników dla: "$_searchQuery"');
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
