import 'package:flutter/material.dart';
import '../../models/client.dart';
import 'package:intl/intl.dart';

class ClientDetailsScreen extends StatelessWidget {
  static const routeName = '/client-details';

  final Client client;

  const ClientDetailsScreen({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${client.firstName} ${client.lastName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${client.id}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Email: ${client.email}'),
            const SizedBox(height: 8),
            Text('Telefon: ${client.phone ?? 'Brak'}'),
            const SizedBox(height: 8),
            Text('Adres: ${client.address ?? 'Brak'}'),
            const SizedBox(height: 8),
            Text('Segment: ${client.segment ?? 'Brak segmentu'}'),
            const SizedBox(height: 8),
            Text('Data Utworzenia: ${DateFormat('dd-MM-yyyy').format(client.createdAt)}'),
            const SizedBox(height: 8),
            Text('Data Aktualizacji: ${DateFormat('dd-MM-yyyy').format(client.updatedAt)}'),
            // Dodaj inne szczegóły według potrzeb
          ],
        ),
      ),
    );
  }
}
