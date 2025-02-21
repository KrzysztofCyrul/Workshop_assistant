import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:provider/provider.dart';

import '../../models/client.dart';
import '../../providers/client_provider.dart';
import '../../utils/colors.dart';
import '../screens/clients/add_client_screen.dart';

class ClientSearchWidget extends StatefulWidget {
  final Client? selectedClient;
  final ValueChanged<Client?> onChanged;
  final String? Function(Client?)? validator;
  final String labelText;

  const ClientSearchWidget({
    Key? key,
    this.selectedClient,
    required this.onChanged,
    this.validator,
    this.labelText = 'Klient',
  }) : super(key: key);

  @override
  _ClientSearchWidgetState createState() => _ClientSearchWidgetState();
}

class _ClientSearchWidgetState extends State<ClientSearchWidget> {
  @override
  void didUpdateWidget(ClientSearchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Aktualizuj stan, gdy widget.selectedClient się zmienia
    if (widget.selectedClient != oldWidget.selectedClient) {
      setState(() {});
    }
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
        return SegmentColors.defaultColor;
    }
  }

  Future<List<Client>> _fetchClients(BuildContext context, String filter) async {
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    final allClients = clientProvider.clients;
    final searchQuery = filter.toLowerCase();

    return allClients.where((client) {
      final firstNameMatch = client.firstName.toLowerCase().contains(searchQuery);
      final lastNameMatch = client.lastName.toLowerCase().contains(searchQuery);
      final phoneMatch = (client.phone?.contains(searchQuery) ?? false);

      return firstNameMatch || lastNameMatch || phoneMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<Client>(
      asyncItems: (String filter) => _fetchClients(context, filter),
      selectedItem: widget.selectedClient, // Używamy widget.selectedClient zamiast stanu wewnętrznego
      itemAsString: (Client client) =>
          '${client.firstName} ${client.lastName} - ${client.phone ?? 'Brak'}',
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: widget.labelText,
          border: const OutlineInputBorder(),
        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            labelText: 'Szukaj klienta',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final newClient = await Navigator.of(context).push<Client>(
                  MaterialPageRoute(
                    builder: (_) => AddClientScreen(),
                  ),
                );

                if (newClient != null) {
                  widget.onChanged(newClient); // Powiadom rodzica o nowym kliencie
                }
              },
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        itemBuilder: (context, client, isSelected) => ListTile(
          leading: CircleAvatar(
            backgroundColor: _getSegmentColor(client.segment),
            child: Text(
              client.segment ?? '-',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text('${client.firstName} ${client.lastName}'),
          subtitle: Text('Telefon: ${client.phone ?? 'Brak'}'),
        ),
      ),
      onChanged: (client) {
        widget.onChanged(client); // Powiadom rodzica o zmianie klienta
      },
      validator: widget.validator,
    );
  }
}