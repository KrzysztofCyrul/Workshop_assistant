import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:provider/provider.dart';

import '../../models/client.dart';
import '../../providers/client_provider.dart';
import '../../utils/colors.dart';
import '../screens/clients/add_client_screen.dart';

class ClientSearchWidget extends StatelessWidget {
  /// Aktualnie wybrany klient (jeśli chcemy ustawiać np. w formularzu edycji).
  final Client? selectedClient;

  /// Funkcja wywoływana po zmianie wyboru klienta.
  final ValueChanged<Client?> onChanged;

  /// Funkcja walidująca wybór klienta (np. wymóg: nie może być pusty).
  final String? Function(Client?)? validator;

  /// Etykieta wyświetlana w polu (np. "Klient").
  final String labelText;

  const ClientSearchWidget({
    Key? key,
    this.selectedClient,
    required this.onChanged,
    this.validator,
    this.labelText = 'Klient',
  }) : super(key: key);

  /// Metoda pomocnicza do kolorowania segmentu klienta.
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

  /// Asynchroniczne pobranie (i odfiltrowanie) listy klientów z Providera
  /// na podstawie wpisanego w wyszukiwarkę tekstu.
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
      // Listę ładujemy asynchronicznie, a filtry obsługujemy w _fetchClients
      asyncItems: (String filter) => _fetchClients(context, filter),
      selectedItem: selectedClient,

      // Formatowanie wyświetlanego tekstu dla wybranego elementu
      itemAsString: (Client client) =>
          '${client.firstName} ${client.lastName} - ${client.phone ?? 'Brak'}',

      // Dostosowanie "dropdowna" (pole tekstowe przed rozwinięciem listy)
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
      ),

      // Konfiguracja wyświetlania popupu i listy wyszukiwania
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            labelText: 'Szukaj klienta',
            prefixIcon: const Icon(Icons.search),
            // Przyciskiem z plusem przechodzimy do ekranu dodawania klienta
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddClientScreen(),
                  ),
                );
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

      // Obsługa "onChanged" i "validator"
      onChanged: onChanged,
      validator: validator,
    );
  }
}
