// lib/screens/clients/clients_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/client_provider.dart';
import '../../models/client.dart';
import '../../screens/clients/client_details_screen.dart'; // Import ClientDetailsScreen

class ClientsScreen extends StatefulWidget {
  static const routeName = '/clients';

  const ClientsScreen({Key? key}) : super(key: key);

  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  @override
  void initState() {
    super.initState();
    // Wywołanie _loadClients po zakończeniu budowy pierwszej ramki
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClients();
    });
  }

  Future<void> _loadClients() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;
    final workshopId = authProvider.user?.employeeProfiles.first.workshopId;

    if (accessToken == null || workshopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Brak dostępu do danych użytkownika.')),
      );
      return;
    }

    await clientProvider.fetchClients(accessToken, workshopId);
  }

  void _navigateToClientDetails(Client client) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ClientDetailsScreen(client: client),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Klienci'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadClients,
        child: clientProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : clientProvider.errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            clientProvider.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, color: Colors.red),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _loadClients,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Ponów próbę'),
                          ),
                        ],
                      ),
                    ),
                  )
                : clientProvider.clients.isEmpty
                    ? const Center(child: Text('Brak klientów.'))
                    : ListView.builder(
                        itemCount: clientProvider.clients.length,
                        itemBuilder: (context, index) {
                          final client = clientProvider.clients[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                (client.firstName.isNotEmpty && client.lastName.isNotEmpty)
                                    ? '${client.firstName[0]}${client.lastName[0]}'
                                    : '?',
                              ),
                            ),
                            title: Text('${client.firstName} ${client.lastName}'),
                            subtitle: Text(
                              'Email: ${client.email}\nSegment: ${client.segment ?? 'Brak segmentu'}',
                            ),
                            isThreeLine: true,
                            onTap: () => _navigateToClientDetails(client),
                          );
                        },
                      ),
      ),
    );
  }
}
