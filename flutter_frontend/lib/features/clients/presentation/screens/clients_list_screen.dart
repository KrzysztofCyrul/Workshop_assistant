import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/features/clients/domain/entities/client.dart';
import 'package:flutter_frontend/features/clients/presentation/bloc/client_bloc.dart';
import 'package:flutter_frontend/features/clients/presentation/screens/client_details_screen.dart';
import 'package:flutter_frontend/features/clients/presentation/screens/add_client_screen.dart';

class ClientsListScreen extends StatefulWidget {
  static const routeName = '/clients-list';
  final String workshopId;

  const ClientsListScreen({
    super.key,
    required this.workshopId,
  });

  @override
  State<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends State<ClientsListScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadClients();
    });
  }

  void _loadClients() {
    if (!mounted) return;
    debugPrint('ClientListScreen - Loading clients for workshop: ${widget.workshopId}');
    context.read<ClientBloc>().add(LoadClientsEvent(
          workshopId: widget.workshopId,
        ));
  }

  List<Client> _filterClients(List<Client> clients) {
    if (_searchQuery.isEmpty) return clients;

    final query = _searchQuery.toLowerCase();
    return clients.where((client) {
      return client.firstName.toLowerCase().contains(query) ||
          client.lastName.toLowerCase().contains(query) ||
          client.email.toLowerCase().contains(query) ||
          (client.phone?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista Klientów'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadClients,
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () async {  
              final result = await Navigator.pushNamed(
                context,
                AddClientScreen.routeName,
                arguments: {'workshopId': widget.workshopId},
              );
              
              if (result == true) {
                _loadClients();
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<ClientBloc, ClientState>(
        listener: (context, state) {
          if (state is ClientError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async => _loadClients(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Wyszukaj klienta',
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

  Widget _buildContent(ClientState state) {
    if (state is ClientUnauthenticated) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 20),
            Text(state.message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              child: const Text('Zaloguj się'),
            ),
          ],
        ),
      );
    }

    if (state is ClientInitial || state is ClientLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ClientError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadClients,
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      );
    }

    if (state is! ClientsLoaded) {
      return const Center(child: Text('Nieznany stan'));
    }

    final clients = _filterClients(state.clients);

    if (clients.isEmpty) {
      return _buildEmptyState(_searchQuery.isEmpty ? 'Brak klientów w warsztacie' : 'Brak wyników dla: "$_searchQuery"');
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: clients.length,
      itemBuilder: (context, index) {
        final client = clients[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                _getClientInitials(client),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              client.firstName.isEmpty && client.lastName.isEmpty 
                  ? 'Brak nazwy'
                  : '${client.firstName} ${client.lastName}'.trim(),
            ),
            subtitle: Text(
              'Email: ${client.email}\nTelefon: ${client.phone ?? "Brak"}',
            ),
            isThreeLine: true,
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                ClientDetailsScreen.routeName,
                arguments: {
                  'workshopId': widget.workshopId,
                  'clientId': client.id,
                },
              );
              
              // Jeśli wróciliśmy z edycji i była ona udana
              if (result == true) {
                _loadClients(); // Odśwież listę klientów
              }
            },
          ),
        );
      },
    );
  }

  String _getClientInitials(Client client) {
    final firstInitial = client.firstName.isNotEmpty ? client.firstName[0] : '?';
    final lastInitial = client.lastName.isNotEmpty ? client.lastName[0] : '?';
    return '$firstInitial$lastInitial';
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            message.contains('Brak wyników') ? Icons.search_off : Icons.people,
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
            onPressed: _loadClients,
            icon: const Icon(Icons.refresh),
            label: const Text('Odśwież'),
          ),
        ],
      ),
    );
  }
}
