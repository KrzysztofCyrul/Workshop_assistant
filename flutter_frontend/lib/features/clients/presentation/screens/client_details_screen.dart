import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/features/clients/presentation/bloc/client_bloc.dart';
import 'package:flutter_frontend/features/vehicles/presentation/bloc/vehicle_bloc.dart';
import 'package:flutter_frontend/features/clients/presentation/widgets/client_info_widget.dart';
import 'package:flutter_frontend/features/clients/presentation/widgets/vehicles_list_widget.dart';

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

    if (confirm == true && mounted) {
      context.read<ClientBloc>().add(DeleteClientEvent(
            workshopId: widget.workshopId,
            clientId: widget.clientId,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<ClientBloc, ClientState>(
          builder: (context, state) {
            if (state is ClientDetailsLoaded) {
              return Text('${state.client.firstName} ${state.client.lastName}');
            }
            return const Text('Szczegóły klienta');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edytuj',
            onPressed: () => Navigator.of(context).pushNamed(
              '/client-edit',
              arguments: {
                'workshopId': widget.workshopId,
                'clientId': widget.clientId,
              },
            ).then((_) => _loadClientDetails()),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Usuń',
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
                SnackBar(content: Text(state.message)),
              );
            } else if (state is ClientOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              Navigator.of(context).pop();
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
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ClientDetailsLoaded) {
                      return ClientInfoWidget(client: state.client);
                    }
                    return const SizedBox.shrink();
                  },
                ),
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
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: BlocBuilder<VehicleBloc, VehicleState>(
                    builder: (context, state) {
                      if (state is VehicleLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is VehicleError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(state.message),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadVehicles,
                                child: const Text('Spróbuj ponownie'),
                              ),
                            ],
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
      ),
    );
  }
}
