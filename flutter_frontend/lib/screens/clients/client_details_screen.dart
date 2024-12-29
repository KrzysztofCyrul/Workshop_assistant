import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/client.dart';
import '../../providers/client_provider.dart';
import '../../providers/auth_provider.dart';

class ClientDetailsScreen extends StatelessWidget {
  static const routeName = '/client-details';

  final Client client;

  const ClientDetailsScreen({Key? key, required this.client}) : super(key: key);

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
        await clientProvider.deleteClient(accessToken, workshopId, client.id);
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
      arguments: client
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client details UI
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
              'Pojazdy:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Add other UI elements as needed
          ],
        ),
      ),
    );
  }
}
