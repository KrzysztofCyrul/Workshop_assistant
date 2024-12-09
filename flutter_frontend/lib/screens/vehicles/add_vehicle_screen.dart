import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/client_provider.dart';
import '../../models/client.dart';
import '../clients/add_client_screen.dart'; // Import the AddClientScreen

class AddVehicleScreen extends StatefulWidget {
  static const routeName = '/add-vehicle';

  final String workshopId;

  const AddVehicleScreen({
    Key? key,
    required this.workshopId,
  }) : super(key: key);

  @override
  _AddVehicleScreenState createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  // Kontrolery formularza
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _vinController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();

  String? _selectedClientId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;
    final workshopId = authProvider.user?.employeeProfiles.first.workshopId;

    if (accessToken != null && workshopId != null) {
      await clientProvider.fetchClients(accessToken, workshopId);
    }
  }

  Future<List<Client>> _fetchClients(String filter) async {
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    return clientProvider.clients.where((client) {
      final searchQuery = filter.toLowerCase();
      return client.firstName.toLowerCase().contains(searchQuery) ||
          client.lastName.toLowerCase().contains(searchQuery) ||
          (client.phone?.contains(searchQuery) ?? false);
    }).toList();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proszę poprawić błędy w formularzu')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;

    if (accessToken == null || _selectedClientId == null) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Brak dostępu do danych użytkownika lub klienta')),
      );
      return;
    }

    try {
      await Provider.of<VehicleProvider>(context, listen: false).addVehicle(
        accessToken,
        widget.workshopId,
        clientId: _selectedClientId!,
        make: _makeController.text,
        model: _modelController.text,
        year: int.parse(_yearController.text),
        vin: _vinController.text,
        licensePlate: _licensePlateController.text,
        mileage: int.parse(_mileageController.text),
      );
      Navigator.of(context).pop(true); // Powrót po dodaniu pojazdu
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas dodawania pojazdu: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ClientProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj Pojazd'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownSearch<Client>(
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      labelText: 'Szukaj klienta',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddClientScreen(),
                            ),
                          );
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  itemBuilder: (context, client, isSelected) => ListTile(
                    title: Text('${client.firstName} ${client.lastName}'),
                    subtitle: Text('Telefon: ${client.phone ?? 'Brak'}'),
                  ),
                ),
                asyncItems: (String filter) => _fetchClients(filter),
                itemAsString: (Client client) => '${client.firstName} ${client.lastName} - ${client.phone ?? 'Brak'}',
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Klient',
                    border: OutlineInputBorder(),
                  ),
                ),
                onChanged: (client) {
                  setState(() {
                    _selectedClientId = client?.id;
                  });
                },
                validator: (client) => client == null ? 'Wybierz klienta' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _makeController,
                decoration: const InputDecoration(
                  labelText: 'Marka',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Marka jest wymagana';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Model jest wymagany';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Rok produkcji',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Rok produkcji jest wymagany';
                  } else if (int.tryParse(value) == null) {
                    return 'Podaj poprawny rok';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vinController,
                decoration: const InputDecoration(
                  labelText: 'VIN',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _licensePlateController,
                decoration: const InputDecoration(
                  labelText: 'Numer rejestracyjny',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Numer rejestracyjny jest wymagany';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(
                  labelText: 'Przebieg (km)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Przebieg jest wymagany';
                  } else if (int.tryParse(value) == null) {
                    return 'Podaj poprawny przebieg';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Dodaj Pojazd'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _vinController.dispose();
    _licensePlateController.dispose();
    _mileageController.dispose();
    super.dispose();
  }
}
