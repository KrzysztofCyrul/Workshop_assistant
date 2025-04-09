import 'package:flutter/material.dart';
import 'package:flutter_frontend/features/vehicles/presentation/screens/vehicle_details_screen.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/client_provider.dart';
import '../../models/client.dart';
import '../../features/vehicles/data/models/vehicle_model.dart';

class ClientDetailsScreen extends StatefulWidget {
  static const routeName = '/client-details';

  final Client client;

  const ClientDetailsScreen({super.key, required this.client});

  @override
  _ClientDetailsScreenState createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  late Future<void> _fetchFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Uruchamiamy pobieranie pojazdów przy starcie ekranu
    _fetchFuture = _fetchVehiclesForClient();
  }

  Future<void> _fetchVehiclesForClient() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;
    final workshopId = authProvider.user?.employeeProfiles.first.workshopId;

    if (accessToken != null && workshopId != null) {
      await Provider.of<VehicleProvider>(context, listen: false)
          .fetchVehiclesForClient(accessToken, workshopId, widget.client.id);
    }
  }

  Future<void> _refreshVehicles() async {
    // Odświeżenie listy pojazdów
    setState(() {
      _fetchFuture = _fetchVehiclesForClient();
    });
    await _fetchFuture;
  }

  /// Filtrowanie pojazdów po marce, modelu i rejestracji
  List<VehicleModel> _filterVehicles(List<VehicleModel> vehicles) {
    if (_searchQuery.isEmpty) {
      return vehicles;
    }
    final query = _searchQuery.toLowerCase();
    return vehicles.where((vehicle) {
      final make = vehicle.make.toLowerCase();
      final model = vehicle.model.toLowerCase();
      final plate = vehicle.licensePlate.toLowerCase();
      return make.contains(query) || model.contains(query) || plate.contains(query);
    }).toList();
  }

  void _deleteClient(BuildContext context) async {
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;
    final workshopId = authProvider.user?.employeeProfiles.first.workshopId;

    if (accessToken == null || workshopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Brak dostępu do danych użytkownika.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potwierdzenie'),
        content: const Text('Czy na pewno chcesz usunąć tego klienta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await clientProvider.deleteClient(accessToken, workshopId, widget.client.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Klient został usunięty.')),
        );
        Navigator.of(context).pop(); // Powrót po usunięciu klienta
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas usuwania klienta: $e')),
        );
      }
    }
  }

  void _editClient(BuildContext context) {
    Navigator.of(context).pushNamed(
      '/edit-client',
      arguments: widget.client,
    );
  }

  @override
  Widget build(BuildContext context) {
    final client = widget.client;

    return Scaffold(
      appBar: AppBar(
        title: Text('${client.firstName} ${client.lastName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edytuj',
            onPressed: () => _editClient(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Usuń',
            onPressed: () => _deleteClient(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshVehicles,
        child: Column(
          children: [
            // Nagłówek z danymi klienta
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${client.firstName} ${client.lastName}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Email: ${client.email}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Telefon: ${client.phone ?? 'Brak'}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Adres: ${client.address ?? 'Brak'}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Segment: ${client.segment ?? 'Brak segmentu'}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  const Text(
                    'Pojazdy klienta:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Pole wyszukiwania
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Wyszukaj pojazd',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),

            // Lista pojazdów
            Expanded(
              child: FutureBuilder<void>(
                future: _fetchFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Błąd: ${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16, color: Colors.red),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _refreshVehicles,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Ponów próbę'),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    // Gdy future jest ukończone, korzystamy z VehicleProvider
                    final vehicleProvider = Provider.of<VehicleProvider>(context);
                    if (vehicleProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (vehicleProvider.errorMessage != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                vehicleProvider.errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16, color: Colors.red),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _refreshVehicles,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Ponów próbę'),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (vehicleProvider.vehicles.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.directions_car, size: 60, color: Colors.grey),
                            const SizedBox(height: 20),
                            const Text(
                              'Brak pojazdów dla tego klienta.',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _refreshVehicles,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Odśwież'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Mamy listę pojazdów, ewentualnie ją filtrujemy
                      final filteredVehicles =
                          _filterVehicles(vehicleProvider.vehicles);

                      if (filteredVehicles.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, size: 60, color: Colors.grey),
                              const SizedBox(height: 20),
                              Text(
                                'Brak wyników dla: "$_searchQuery"',
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
                        itemBuilder: (ctx, index) {
                          final vehicle = filteredVehicles[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: ListTile(
                              leading: const Icon(Icons.directions_car, color: Colors.blue),
                              title: Text('${vehicle.make} ${vehicle.model}'),
                              subtitle: Text('Rejestracja: ${vehicle.licensePlate}'),
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  VehicleDetailsScreen.routeName,
                                  arguments: {
                                    'workshopId':
                                        Provider.of<AuthProvider>(context, listen: false)
                                            .user
                                            ?.employeeProfiles
                                            .first
                                            .workshopId,
                                    'vehicleId': vehicle.id,
                                  },
                                );
                              },
                            ),
                          );
                        },
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
