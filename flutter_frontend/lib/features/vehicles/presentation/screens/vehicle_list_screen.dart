import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/features/vehicles/domain/entities/vehicle.dart';
import 'package:flutter_frontend/features/vehicles/presentation/bloc/vehicle_bloc.dart';
import 'package:flutter_frontend/features/vehicles/presentation/screens/vehicle_details_screen.dart';
import 'package:flutter_frontend/features/vehicles/presentation/screens/add_vehicle_screen.dart';
import 'package:flutter_frontend/core/widgets/custom_app_bar.dart';

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
    return Scaffold(      appBar: CustomAppBar(
        title: 'Lista Pojazdów',
        feature: 'vehicles',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVehicles,
            tooltip: 'Odśwież listę',
          ),
          IconButton(
            icon: const Icon(Icons.add_circle),
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
            tooltip: 'Dodaj pojazd',
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
      body: BlocConsumer<VehicleBloc, VehicleState>(
        listener: (context, state) {
          if (state is VehicleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async => _loadVehicles(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Wyszukaj pojazd',
                      hintText: 'Wpisz markę, model lub numer rejestracyjny',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2.0,
                        ),
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
      floatingActionButton: FloatingActionButton.extended(
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
        tooltip: 'Dodaj pojazd',
        icon: const Icon(Icons.add),
        label: const Text('Nowy pojazd'),
        backgroundColor: Colors.blue,
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Ładowanie pojazdów...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (state is VehicleError) {
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
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Wystąpił błąd',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadVehicles,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Ponów próbę'),
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

    if (state is! VehiclesLoaded) {
      return const Center(child: Text('Nieznany stan'));
    }

    final vehicles = _filterVehicles(state.vehicles);

    if (vehicles.isEmpty) {
      return _buildEmptyState(_searchQuery.isEmpty ? 'Brak pojazdów w warsztacie' : 'Brak wyników dla: "$_searchQuery"');
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12.0),
      itemCount: vehicles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
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
              '${vehicle.make} ${vehicle.model}'.trim(),
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
                message.contains('Brak wyników') ? Icons.search_off : Icons.directions_car,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadVehicles,
                icon: const Icon(Icons.refresh),
                label: const Text('Odśwież'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
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
                icon: const Icon(Icons.add),
                label: const Text('Dodaj nowy pojazd'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
