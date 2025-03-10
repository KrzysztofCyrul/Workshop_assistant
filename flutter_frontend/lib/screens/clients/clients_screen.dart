import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/client_provider.dart';
import '../../data/models/client.dart';
import '../../screens/clients/client_details_screen.dart';
import '../../core/utils/colors.dart';
import 'add_client_screen.dart';

class ClientsScreen extends StatefulWidget {
  static const routeName = '/clients';

  const ClientsScreen({super.key});

  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  String _searchQuery = '';
  String _selectedSegment = 'Wszystkie';
  bool _isFirstLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _loadClients();
      _isFirstLoad = false;
    }
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

  Future<void> _navigateToAddClient() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddClientScreen(),
      ),
    );

    if (result == true) {
      _loadClients();
    }
  }

  List<Client> _filterClients(List<Client> clients) {
    return clients.where((client) {
      final matchesSearchQuery = _searchQuery.isEmpty ||
          client.firstName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          client.lastName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          client.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (client.phone?.contains(_searchQuery) ?? false);

      final matchesSegment = _selectedSegment == 'Wszystkie' ||
          client.segment == _selectedSegment;

      return matchesSearchQuery && matchesSegment;
    }).toList();
  }

  Color _getSegmentColor(String? segment) {
    switch (segment) {
      case 'A':
        return SegmentColors.segmentA;
      case 'B':
        return SegmentColors.segmentB;
      case 'C':
        return SegmentColors.segmentC;
      case 'D':
        return SegmentColors.segmentD;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Klienci'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _navigateToAddClient,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadClients,
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
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedSegment,
                items: ['Wszystkie', 'A', 'B', 'C', 'D']
                    .map((segment) => DropdownMenuItem(
                          value: segment,
                          child: Text(segment),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSegment = value!;
                  });
                },
              ),
            ),
            Expanded(
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
                      : _filterClients(clientProvider.clients).isEmpty
                          ? const Center(child: Text('Brak klientów.'))
                          : ListView.builder(
                              itemCount: _filterClients(clientProvider.clients).length,
                              itemBuilder: (context, index) {
                                final client = _filterClients(clientProvider.clients)[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: Text(
                                        (client.firstName.isNotEmpty && client.lastName.isNotEmpty)
                                            ? '${client.firstName[0]}${client.lastName[0]}'
                                            : '?',
                                      ),
                                    ),
                                    title: Text('${client.firstName} ${client.lastName}'),
                                    subtitle: Text(
                                      'Email: ${client.email}\nTelefon: ${client.phone ?? 'Brak'}',
                                    ),
                                    trailing: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: _getSegmentColor(client.segment),
                                      child: Text(
                                        client.segment ?? '-',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    isThreeLine: true,
                                    onTap: () => _navigateToClientDetails(client),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}