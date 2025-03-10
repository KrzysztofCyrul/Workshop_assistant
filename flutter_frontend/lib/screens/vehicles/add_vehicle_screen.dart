import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/client_provider.dart';
import '../../data/models/client.dart';
import '../../widgets/client_search_widget.dart';
import '../../core/utils/colors.dart';

class AddVehicleScreen extends StatefulWidget {
  static const routeName = '/add-vehicle';

  final String workshopId;
  final Client? selectedClient;

  const AddVehicleScreen({
    super.key,
    required this.workshopId,
    this.selectedClient,
  });

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
    _selectedClientId = widget.selectedClient?.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClients();
    });
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

  Future<void> _submitForm() async {
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
    final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
    await vehicleProvider.addVehicle(
      accessToken,
      widget.workshopId,
      clientId: _selectedClientId!,
      make: _makeController.text,
      model: _modelController.text,
      year: _yearController.text.isNotEmpty ? int.parse(_yearController.text) : 0, // Domyślna wartość 0
      vin: _vinController.text.isNotEmpty ? _vinController.text : '', // Domyślna wartość pusty ciąg
      licensePlate: _licensePlateController.text,
      mileage: _mileageController.text.isNotEmpty ? int.parse(_mileageController.text) : 0, // Domyślna wartość 0
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
              ClientSearchWidget(
                selectedClient: widget.selectedClient, // Automatyczne ustawienie klienta
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