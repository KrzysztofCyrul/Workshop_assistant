import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_frontend/screens/vehicles/add_vehicle_screen.dart';
import 'package:provider/provider.dart';
import '../../models/client.dart';
import '../../models/vehicle.dart';
import '../../providers/client_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../services/quotation_service.dart';
import '../../providers/auth_provider.dart';
import '../../services/client_service.dart';
import '../../widgets/client_search_widget.dart';
import 'quotation_details_screen.dart'; // Import the quotation details screen

class AddQuotationScreen extends StatefulWidget {
  static const routeName = '/add-quotation';

  const AddQuotationScreen({super.key});

  @override
  _AddQuotationScreenState createState() => _AddQuotationScreenState();
}

class _AddQuotationScreenState extends State<AddQuotationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Pola formularza
  Client? _selectedClient;
  Vehicle? _selectedVehicle;
  double? _totalCost;

  // Listy danych
  List<Client> _clients = [];

  // Stany ładowania
  bool _isLoading = false;
  bool _isSubmitting = false;

  // Komunikaty błędów
  String? _errorMessage;

  // Kontrolery
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _totalCostController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;
    final workshopId = authProvider.user?.employeeProfiles.first.workshopId;

    try {
      await Provider.of<ClientProvider>(context, listen: false).fetchClients(accessToken!, workshopId!);
      _clients = await ClientService.getClients(accessToken, workshopId);
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _errorMessage = 'Błąd podczas pobierania danych: $e';
        });
      });
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  Future<void> _fetchVehicles(String? clientId) async {
    setState(() {
      _selectedVehicle = null;
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;
    final workshopId = authProvider.user?.employeeProfiles.first.workshopId;

    if (accessToken == null || workshopId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Brak dostępu do danych użytkownika.';
      });
      return;
    }

    try {
      if (clientId != null) {
        await Provider.of<VehicleProvider>(context, listen: false).fetchVehiclesForClient(accessToken, workshopId, clientId);
      } else {
        await Provider.of<VehicleProvider>(context, listen: false).fetchVehicles(accessToken, workshopId);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Błąd podczas pobierania pojazdów: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proszę poprawić błędy w formularzu')),
      );
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;
    final workshopId = authProvider.user?.employeeProfiles.first.workshopId;

    if (workshopId == null) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Brak identyfikatora warsztatu.';
      });
      return;
    }

    try {
      final quotationId = await QuotationService.createQuotation(
        accessToken: accessToken!,
        workshopId: workshopId,
        clientId: _selectedClient!.id,
        vehicleId: _selectedVehicle!.id,
        totalCost: _totalCost,
      );

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wycena została dodana')),
      );

      Navigator.of(context).pushReplacementNamed(
        QuotationDetailsScreen.routeName,
        arguments: {
          'workshopId': workshopId,
          'quotationId': quotationId,
        },
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas tworzenia wyceny: $e')),
      );
    }
  }

  @override
  void dispose() {
    _dateTimeController.dispose();
    _totalCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _clients.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dodaj Wycenę'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dodaj Wycenę'),
        ),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj Wycenę'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _isSubmitting
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wybór klienta i pojazdu
                    Card(
                      elevation: 2.0,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Informacje Klienta', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 16.0),
                            ClientSearchWidget(
                              selectedClient: _selectedClient,
                              labelText: 'Klient',
                              onChanged: (value) async {
                                setState(() {
                                  _selectedClient = value;
                                  _selectedVehicle = null;
                                });
                                await _fetchVehicles(value?.id);
                              },
                              validator: (value) => value == null ? 'Wybierz klienta' : null,
                            ),
                            const SizedBox(height: 16.0),
                            DropdownSearch<Vehicle>(
  asyncItems: (String filter) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;
    final workshopId = authProvider.user?.employeeProfiles.first.workshopId;

    if (accessToken == null || workshopId == null) return [];

    final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
    await _fetchVehicles(_selectedClient?.id);

    return vehicleProvider.vehicles.where((vehicle) {
      final query = filter.toLowerCase();
      return vehicle.make.toLowerCase().contains(query) ||
          vehicle.model.toLowerCase().contains(query) ||
          (vehicle.licensePlate.toLowerCase().contains(query));
    }).toList();
  },
  selectedItem: _selectedVehicle,
  itemAsString: (Vehicle vehicle) => '${vehicle.make} ${vehicle.model} - ${vehicle.licensePlate}',
  dropdownDecoratorProps: const DropDownDecoratorProps(
    dropdownSearchDecoration: InputDecoration(
      labelText: 'Pojazd',
      border: OutlineInputBorder(),
    ),
  ),
  popupProps: PopupProps.menu(
    showSearchBox: true,
    searchFieldProps: TextFieldProps(
      decoration: InputDecoration(
        labelText: 'Szukaj pojazdu',
        prefixIcon: const Icon(Icons.search),
                                              suffixIcon: IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () async {
                                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                          final accessToken = authProvider.accessToken;
                                          final workshopId = authProvider.user?.employeeProfiles.first.workshopId;

                                          if (accessToken == null || workshopId == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Brak dostępu do danych użytkownika.')),
                                            );
                                            return;
                                          }

                                          final result = await Navigator.of(context).push<bool>(
                                            MaterialPageRoute(
                                              builder: (context) => AddVehicleScreen(
                                                workshopId: workshopId,
                                                selectedClient: _selectedClient,
                                              ),
                                            ),
                                          );

                                          if (result == true) {
                                            await Provider.of<VehicleProvider>(context, listen: false).fetchVehiclesForClient(accessToken, workshopId, _selectedClient!.id);

                                            setState(() {
                                              _selectedVehicle = Provider.of<VehicleProvider>(context, listen: false).vehicles.last;
                                            });
                                          }
                                        },
                                      ),
        border: const OutlineInputBorder(),
      ),
    ),
    itemBuilder: (context, vehicle, isSelected) => ListTile(
      leading: const Icon(Icons.directions_car),
      title: Text('${vehicle.make} ${vehicle.model}'),
      subtitle: Text('Rejestracja: ${vehicle.licensePlate}'),
    ),
  ),
  onChanged: (Vehicle? vehicle) {
    setState(() {
      _selectedVehicle = vehicle;
      if (vehicle != null) {
        // Znajdź klienta, który jest właścicielem tego pojazdu
        _selectedClient = _clients.firstWhere((client) => client.id == vehicle.clientId);
      }
    });
  },
  validator: (Vehicle? value) => value == null ? 'Wybierz pojazd' : null,
),
                          ],
                        ),
                      ),
                    ),

                    // Przycisk zapisu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.save),
                        label: const Text('Zapisz Wycenę'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}