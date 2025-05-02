import 'package:flutter/material.dart';
import 'package:flutter_frontend/features/clients/domain/entities/client.dart';

class ClientInfoWidget extends StatelessWidget {
  final Client client;

  const ClientInfoWidget({
    super.key,
    required this.client,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${client.firstName} ${client.lastName}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Email: ${client.email}', 
               style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('Telefon: ${client.phone ?? 'Brak'}', 
               style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('Adres: ${client.address ?? 'Brak'}', 
               style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('Segment: ${client.segment ?? 'Brak segmentu'}', 
               style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          const Text(
            'Pojazdy klienta:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}