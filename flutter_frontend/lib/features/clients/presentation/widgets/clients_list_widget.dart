import 'package:flutter/material.dart';
import 'package:flutter_frontend/features/clients/domain/entities/client.dart';
import 'package:flutter_frontend/core/utils/colors.dart';

class ClientsListWidget extends StatelessWidget {
  final List<Client> clients;
  final Function(Client) onClientTap;
  final String searchQuery;
  final String selectedSegment;

  const ClientsListWidget({
    super.key,
    required this.clients,
    required this.onClientTap,
    required this.searchQuery,
    required this.selectedSegment,
  });

  List<Client> _filterClients() {
    return clients.where((client) {
      final matchesSearchQuery = searchQuery.isEmpty ||
          client.firstName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          client.lastName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          client.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (client.phone?.contains(searchQuery) ?? false);

      final matchesSegment = selectedSegment == 'Wszystkie' ||
          client.segment == selectedSegment;

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
    final filteredClients = _filterClients();

    if (filteredClients.isEmpty) {
      return const Center(child: Text('Brak klientów.'));
    }

    return ListView.builder(
      itemCount: filteredClients.length,
      itemBuilder: (context, index) {
        final client = filteredClients[index];
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
            onTap: () => onClientTap(client),
          ),
        );
      },
    );
  }
}