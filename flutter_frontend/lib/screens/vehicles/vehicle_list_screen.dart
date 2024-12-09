import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';
import 'vehicle_details_screen.dart';

class VehicleListScreen extends StatefulWidget {
  static const routeName = '/vehicle-list';

  final String workshopId;

  const VehicleListScreen({Key? key, required this.workshopId}) : super(key: key);

  @override
  _VehicleListScreenState createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  late Future<void> _fetchFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchFuture = _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;
    if (accessToken != null) {
      await Provider.of<VehicleProvider>(context, listen: false).fetchVehicles(
        accessToken,
        widget.workshopId,
      );
    }
  }

  Future<void> _refreshVehicles() async {
    setState(() {
      _fetchFuture = _fetchVehicles();
    });
    await _fetchFuture;
  }

  List<dynamic> _filterVehicles(List<dynamic> vehicles) {
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;

    if (accessToken == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lista Pojazdów'),
        ),
        body: const Center(
          child: Text(
            'Brak dostępu do danych użytkownika.\nZaloguj się, aby zobaczyć listę pojazdów.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final vehicleProvider = Provider.of<VehicleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista Pojazdów'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Odśwież listę',
            onPressed: _refreshVehicles,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshVehicles,
        child: Column(
          children: [
            // Pole wyszukiwania podobne do ClientsScreen
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
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
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
                              'Brak pojazdów w warsztacie.',
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
                      final filteredVehicles = _filterVehicles(vehicleProvider.vehicles);
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
                        itemBuilder: (context, index) {
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
                                    'workshopId': widget.workshopId,
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
