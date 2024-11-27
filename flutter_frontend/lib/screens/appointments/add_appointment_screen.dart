import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/client_service.dart';
import '../../services/vehicle_service.dart';
import '../../services/appointment_service.dart';
import '../../models/client.dart';
import '../../models/vehicle.dart';

class AddAppointmentScreen extends StatefulWidget {
  static const routeName = '/add-appointment';

  const AddAppointmentScreen({Key? key}) : super(key: key);

  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  Client? _selectedClient;
  Vehicle? _selectedVehicle;
  DateTime? _selectedDateTime;
  String? _notes;

  // Data lists
  List<Client> _clients = [];
  List<Vehicle> _vehicles = [];

  // Loading states
  bool _isLoading = false;
  bool _isSubmitting = false;

  // Error messages
  String? _errorMessage;

  // Controller for date and time field
  final TextEditingController _dateTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  @override
  void dispose() {
    _dateTimeController.dispose();
    super.dispose();
  }

  Future<void> _fetchClients() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;
    final workshopId = authProvider.user?.employeeProfiles.first.workshopId;

    if (accessToken == null || workshopId == null) {
      setState(() {
        _errorMessage = 'Brak dostępu do danych użytkownika.';
        _isLoading = false;
      });
      return;
    }

    try {
      final clients = await ClientService.getClients(accessToken, workshopId);
      // Usunięcie duplikatów na podstawie id
      final uniqueClients = <String, Client>{};
      for (var client in clients) {
        uniqueClients[client.id] = client;
      }
      setState(() {
        _clients = uniqueClients.values.toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Błąd podczas pobierania listy klientów: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchVehicles(String clientId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _vehicles = [];
      _selectedVehicle = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;
    final workshopId = authProvider.user?.employeeProfiles.first.workshopId;

    if (accessToken == null || workshopId == null) {
      setState(() {
        _errorMessage = 'Brak tokena dostępu.';
        _isLoading = false;
      });
      return;
    }

    try {
      final vehicles = await VehicleService.getVehiclesForClient(accessToken, workshopId, clientId);
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Błąd podczas pobierania listy pojazdów: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedDateTime != null
            ? TimeOfDay.fromDateTime(_selectedDateTime!)
            : TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _selectedDateTime = selectedDateTime;
          _dateTimeController.text = DateFormat('dd-MM-yyyy HH:mm').format(selectedDateTime);
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      // Formularz zawiera błędy
      return;
    }

    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wybierz datę i godzinę wizyty')),
      );
      return;
    }

    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wybierz klienta')),
      );
      return;
    }

    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wybierz pojazd')),
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

    try {
      await AppointmentService.createAppointment(
        accessToken!,
        workshopId!,
        _selectedClient!.id,
        _selectedVehicle!.id,
        _selectedDateTime!,
        _notes,
      );

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zlecenie zostało dodane')),
      );

      Navigator.of(context).pop(true); // Przekaż wynik, aby odświeżyć listę zleceń
    } catch (e) {
      setState(() {
        _errorMessage = 'Błąd podczas tworzenia zlecenia: $e';
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj Zlecenie'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.red),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _fetchClients,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Ponów próbę'),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Wybór klienta
                          DropdownButtonFormField<Client>(
                            decoration: const InputDecoration(
                              labelText: 'Klient',
                              border: OutlineInputBorder(),
                            ),
                            items: _clients.map((Client client) {
                              return DropdownMenuItem<Client>(
                                value: client,
                                child: Text('${client.firstName} ${client.lastName}'),
                              );
                            }).toList(),
                            value: _selectedClient,
                            onChanged: (Client? newValue) {
                              if (newValue != _selectedClient) {
                                setState(() {
                                  _selectedClient = newValue;
                                  _selectedVehicle = null;
                                  _vehicles = [];
                                });
                                if (newValue != null) {
                                  _fetchVehicles(newValue.id);

                                  if (_vehicles.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Wybrany klient nie ma przypisanych pojazdów.')),
  );
}
                                }
                              }
                            },
                            validator: (value) => value == null ? 'Wybierz klienta' : null,
                          ),
                          const SizedBox(height: 16.0),

                          // Wybór pojazdu
                          DropdownButtonFormField<Vehicle>(
                            decoration: const InputDecoration(
                              labelText: 'Pojazd',
                              border: OutlineInputBorder(),
                            ),
                            items: _vehicles.map((Vehicle vehicle) {
                              return DropdownMenuItem<Vehicle>(
                                value: vehicle,
                                child: Text('${vehicle.make} ${vehicle.model} (${vehicle.licensePlate})'),
                              );
                            }).toList(),
                            value: _selectedVehicle,
                            onChanged: (Vehicle? newValue) {
                              setState(() {
                                _selectedVehicle = newValue;
                              });
                            },
                            validator: (value) => value == null ? 'Wybierz pojazd' : null,
                          ),
                          const SizedBox(height: 16.0),

                          // Wybór daty i czasu
                          GestureDetector(
                            onTap: _selectDateTime,
                            child: AbsorbPointer(
                              child: TextFormField(
                                controller: _dateTimeController,
                                decoration: const InputDecoration(
                                  labelText: 'Data i Godzina Wizyty',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                validator: (value) {
                                  if (_selectedDateTime == null) {
                                    return 'Wybierz datę i godzinę wizyty';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),

                          // Pole notatek
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Notatki',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            onSaved: (value) {
                              _notes = value;
                            },
                          ),
                          const SizedBox(height: 24.0),

                          // Przycisk Zapisz
                          _isSubmitting
                              ? const CircularProgressIndicator()
                              : ElevatedButton.icon(
                                  onPressed: _submitForm,
                                  icon: const Icon(Icons.save),
                                  label: const Text('Zapisz Zlecenie'),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(50), // Wysokość przycisku
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
