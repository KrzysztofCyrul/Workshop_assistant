import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/features/clients/presentation/bloc/client_bloc.dart';
import 'package:flutter_frontend/features/vehicles/presentation/bloc/vehicle_bloc.dart';
import 'package:flutter_frontend/features/clients/presentation/widgets/client_info_widget.dart';
import 'package:flutter_frontend/features/clients/presentation/widgets/vehicles_list_widget.dart';
import 'package:flutter_frontend/core/widgets/custom_app_bar.dart';
import 'package:flutter_frontend/core/theme/app_theme.dart';

class ClientDetailsScreen extends StatefulWidget {
  static const routeName = '/client-details';

  final String clientId;
  final String workshopId;

  const ClientDetailsScreen({
    super.key,
    required this.clientId,
    required this.workshopId,
  });

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadClientDetails();
    _loadVehicles();
  }

  void _loadClientDetails() {
    context.read<ClientBloc>().add(LoadClientDetailsEvent(
          workshopId: widget.workshopId,
          clientId: widget.clientId,
        ));
  }

  void _loadVehicles() {
    context.read<VehicleBloc>().add(LoadVehiclesForClientEvent(
          workshopId: widget.workshopId,
          clientId: widget.clientId,
        ));
  }

  void _deleteClient() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Potwierdzenie usunięcia',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'Czy na pewno chcesz usunąć tego klienta?',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Ta operacja jest nieodwracalna i spowoduje usunięcie wszystkich danych powiązanych z tym klientem.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black54,
            ),
            child: const Text('Anuluj'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_forever),
            label: const Text('Usuń klienta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.read<ClientBloc>().add(DeleteClientEvent(
            workshopId: widget.workshopId,
            clientId: widget.clientId,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      appBar: CustomAppBar(
        title: 'Szczegóły klienta',
        feature: 'clients',
        titleWidget: BlocBuilder<ClientBloc, ClientState>(
          builder: (context, state) {
            if (state is ClientDetailsLoaded) {
              return Text(
                '${state.client.firstName} ${state.client.lastName}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              );
            }
            return const Text(
              'Szczegóły klienta',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            );
          },
        ),
        actions: [          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edytuj klienta',
            onPressed: () => Navigator.of(context).pushNamed(
              '/client-edit',
              arguments: {
                'workshopId': widget.workshopId,
                'clientId': widget.clientId,
              },
            ).then((_) => _loadClientDetails()),
          ),          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Usuń klienta',
            onPressed: _deleteClient,
          ),
        ],
      ),
      body: PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          if (didPop) {
            context.read<ClientBloc>()
              ..add(ResetClientEvent())
              ..add(LoadClientsEvent(workshopId: widget.workshopId));
          }
        },
        child: BlocListener<ClientBloc, ClientState>(
          listener: (context, state) {
            if (state is ClientError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is ClientOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green.shade700,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(context).pop(true);
            } else if (state is ClientUnauthenticated) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          },
          child: RefreshIndicator(
            onRefresh: () async {
              _loadClientDetails();
              _loadVehicles();
            },
            child: Column(
              children: [
                BlocBuilder<ClientBloc, ClientState>(
                  builder: (context, state) {
                    if (state is ClientLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Ładowanie danych klienta...',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (state is ClientDetailsLoaded) {
                      return ClientInfoWidget(client: state.client);
                    }
                    return const SizedBox.shrink();
                  },
                ),
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
                const SizedBox(height: 8),
                Expanded(
                  child: BlocBuilder<VehicleBloc, VehicleState>(
                    builder: (context, state) {
                      if (state is VehicleLoading) {
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
                      } else if (state is VehicleError) {
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
                      } else if (state is VehiclesLoaded) {
                        return VehiclesListWidget(
                          vehicles: state.vehicles,
                          searchQuery: _searchQuery,
                          workshopId: widget.workshopId,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),      floatingActionButton: BlocBuilder<ClientBloc, ClientState>(
        builder: (context, state) {
          if (state is ClientDetailsLoaded) {
            return FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).pushNamed(
                '/add-vehicle',
                arguments: {
                  'workshopId': widget.workshopId,
                  'selectedClient': state.client,
                },
              ).then((result) {
                if (result == true) {
                  _loadVehicles();
                }
              }),
              icon: const Icon(Icons.directions_car),
              label: const Text('Dodaj pojazd'),
              tooltip: 'Dodaj pojazd dla klienta',
              backgroundColor: AppTheme.getFeatureColor('clients'),
            );
          }
          return FloatingActionButton.extended(
            onPressed: () => Navigator.of(context).pushNamed(
              '/add-vehicle',
              arguments: {
                'workshopId': widget.workshopId,
                'clientId': widget.clientId,
              },
            ).then((result) {
              if (result == true) {
                _loadVehicles();
              }
            }),            icon: const Icon(Icons.directions_car),
            label: const Text('Dodaj pojazd'),
            tooltip: 'Dodaj pojazd dla klienta',
            backgroundColor: AppTheme.getFeatureColor('clients'),
          );
        },
      ),
    );
  }
}
