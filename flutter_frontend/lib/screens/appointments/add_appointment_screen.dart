import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../models/client.dart';
import '../../models/vehicle.dart';
import '../../models/employee.dart';
import '../../providers/client_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../services/appointment_service.dart';
import '../../providers/auth_provider.dart';
import '../../services/client_service.dart';
import '../../services/employee_service.dart';
import '../../utils/colors.dart';
import '../../widgets/client_search_widget.dart';
import '../../screens/vehicles/add_vehicle_screen.dart';

class AddAppointmentScreen extends StatefulWidget {
  static const routeName = '/add-appointment';

  const AddAppointmentScreen({super.key});

  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Pola formularza
  Client? _selectedClient;
  Vehicle? _selectedVehicle;
  DateTime? _scheduledTime;
  String? _notes;
  int _mileage = 0;
  String? _recommendations;
  Duration? _estimatedDuration;
  double? _totalCost;
  // List<Employee> _assignedMechanics = [];
  String _status = 'scheduled';

  // Listy danych
  List<Client> _clients = [];
  List<Employee> _mechanics = [];

  // Stany ładowania
  bool _isLoading = false;
  bool _isSubmitting = false;

  // Komunikaty błędów
  String? _errorMessage;

  // Kontrolery
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _estimatedDurationController = TextEditingController();
  final TextEditingController _totalCostController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
    _fetchInitialData();
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

Future<void> _fetchInitialData() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final accessToken = authProvider.accessToken;
  final workshopId = authProvider.user?.employeeProfiles.first.workshopId;

  try {
    await Provider.of<ClientProvider>(context, listen: false).fetchClients(accessToken!, workshopId!);
    _clients = await ClientService.getClients(accessToken, workshopId);
    _mechanics = await EmployeeService.getMechanics(accessToken, workshopId);
  } catch (e) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _errorMessage = 'Błąd podczas pobierania danych: $e';
      });
    });
  } finally {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }
}

  Future<void> _fetchVehicles(String clientId) async {
    setState(() {
      _selectedVehicle = null;
      _isLoading = true;
      _errorMessage = null;
    });

    Provider.of<AuthProvider>(context, listen: false);

    try {} catch (e) {
      setState(() {
        _errorMessage = 'Błąd podczas pobierania pojazdów: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'To pole jest wymagane';
    }
    final number = num.tryParse(value);
    if (number == null) {
      return 'Proszę wprowadzić poprawną liczbę';
    }
    return null;
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

    try {
      await AppointmentService.createAppointment(
        accessToken: accessToken!,
        workshopId: workshopId!,
        clientId: _selectedClient!.id,
        vehicleId: _selectedVehicle!.id,
        scheduledTime: _scheduledTime!,
        notes: _notes,
        mileage: _mileage,
        recommendations: _recommendations,
        estimatedDuration: _estimatedDuration,
        totalCost: _totalCost,
        status: _status,
      );

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zlecenie zostało dodane')),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop(true);
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas tworzenia zlecenia: $e')),
      );
    }
  }

  void _onVehicleChanged(Vehicle? vehicle) {
    setState(() {
      _selectedVehicle = vehicle;
      _mileage = vehicle?.mileage ?? 0;
      _mileageController.text = _mileage.toString();
    });
  }

  @override
  void dispose() {
    _dateTimeController.dispose();
    _estimatedDurationController.dispose();
    _totalCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _clients.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dodaj Zlecenie'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dodaj Zlecenie'),
        ),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj Zlecenie'),
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
                                  _selectedVehicle = null; // Resetuj wybrany pojazd
                                });
                                if (value != null) {
                                  await _fetchVehicles(value.id);
                                }
                              },
                              validator: (value) => value == null ? 'Wybierz klienta' : null,
                            ),
                            const SizedBox(height: 16.0),
                            if (_selectedClient != null)
                              DropdownSearch<Vehicle>(
                                asyncItems: (String filter) async {
                                  // Pobieranie listy pojazdów dla danego klienta z filtrowaniem
                                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                  final accessToken = authProvider.accessToken;
                                  final workshopId = authProvider.user?.employeeProfiles.first.workshopId;

                                  if (accessToken == null || workshopId == null) return [];

                                  final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
                                  await vehicleProvider.fetchVehiclesForClient(accessToken, workshopId, _selectedClient!.id);

                                  return vehicleProvider.vehicles.where((vehicle) {
                                    final query = filter.toLowerCase();
                                    return vehicle.make.toLowerCase().contains(query) ||
                                        vehicle.model.toLowerCase().contains(query) ||
                                        (vehicle.licensePlate.toLowerCase().contains(query));
                                  }).toList();
                                },
                                selectedItem: _selectedVehicle,

                                // Formatowanie wyświetlanego tekstu dla wybranego elementu
                                itemAsString: (Vehicle vehicle) => '${vehicle.make} ${vehicle.model} - ${vehicle.licensePlate}',

                                // Dekoracja pola rozwijanego
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    labelText: 'Pojazd',
                                    border: const OutlineInputBorder(),
                                  ),
                                ),

                                // Konfiguracja popupu listy rozwijanej
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

                                          // Przekazanie wybranego klienta do ekranu AddVehicleScreen
                                          final result = await Navigator.of(context).push<bool>(
                                            MaterialPageRoute(
                                              builder: (context) => AddVehicleScreen(
                                                workshopId: workshopId,
                                                selectedClient: _selectedClient, // Przekazanie wybranego klienta
                                              ),
                                            ),
                                          );

                                          if (result == true) {
                                            await Provider.of<VehicleProvider>(context, listen: false).fetchVehiclesForClient(accessToken, workshopId, _selectedClient!.id);

                                            setState(() {
                                              _selectedVehicle = Provider.of<VehicleProvider>(context, listen: false).vehicles.last; // Ustaw ostatni pojazd jako wybrany
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

                                // Obsługa "onChanged"
                                onChanged: (Vehicle? vehicle) {
                                  setState(() {
                                    _selectedVehicle = vehicle;
                                    _mileage = vehicle?.mileage ?? 0;
                                    _mileageController.text = _mileage.toString();
                                  });
                                },

                                // Walidacja pola
                                validator: (Vehicle? value) => value == null ? 'Wybierz pojazd' : null,
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Szczegóły zlecenia
                    Card(
                      elevation: 2.0,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Szczegóły Zlecenia', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Data i godzina',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              readOnly: true,
                              controller: _dateTimeController,
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (time != null) {
                                    setState(() {
                                      _scheduledTime = DateTime(
                                        date.year,
                                        date.month,
                                        date.day,
                                        time.hour,
                                        time.minute,
                                      );
                                      _dateTimeController.text = '${_scheduledTime!.toLocal()}'.split('.')[0];
                                    });
                                  }
                                }
                              },
                              validator: (value) => _scheduledTime == null ? 'Wybierz datę i godzinę' : null,
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Przebieg (km)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: _validateNumber,
                              onSaved: (value) {
                                _mileage = int.tryParse(value!) ?? 0;
                              },
                            ),
                            // const SizedBox(height: 16.0),
                            // TextFormField(
                            //   decoration: const InputDecoration(
                            //     labelText: 'Szacowany czas trwania (min)',
                            //     border: OutlineInputBorder(),
                            //   ),
                            //   keyboardType: TextInputType.number,
                            //   validator: _validateNumber,
                            //   controller: _estimatedDurationController,
                            //   onSaved: (value) {
                            //     final minutes = int.tryParse(value!) ?? 0;
                            //     _estimatedDuration = Duration(minutes: minutes);
                            //   },
                            // ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Całkowity koszt (PLN)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              controller: _totalCostController,
                              onSaved: (value) {
                                _totalCost = double.tryParse(value!) ?? 0.0;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(),
                              ),
                              value: _status,
                              items: const [
                                DropdownMenuItem(value: 'scheduled', child: Text('Zaplanowana')),
                                DropdownMenuItem(value: 'completed', child: Text('Zakończona')),
                                DropdownMenuItem(value: 'canceled', child: Text('Anulowana')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _status = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Wybór mechaników
                    if (_mechanics.isNotEmpty)
                      Card(
                        elevation: 2.0,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: MultiSelectDialogField<Employee>(
                            items: _mechanics.map((e) => MultiSelectItem<Employee>(e, e.userFullName)).toList(),
                            title: const Text('Przypisani Mechanicy'),
                            selectedColor: Theme.of(context).primaryColor,
                            decoration: BoxDecoration(
                              color: Theme.of(context).canvasColor,
                              borderRadius: const BorderRadius.all(Radius.circular(4)),
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 1,
                              ),
                            ),
                            buttonIcon: const Icon(
                              Icons.engineering,
                              color: Colors.grey,
                            ),
                            buttonText: const Text(
                              'Wybierz mechaników',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            onConfirm: (results) {
                              setState(() {
                                // _assignedMechanics = results;
                              });
                            },
                            validator: (values) {
                              if (values == null || values.isEmpty) {
                                return 'Wybierz przynajmniej jednego mechanika';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    // Dodatkowe informacje
                    Card(
                      elevation: 2.0,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dodatkowe Informacje', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Notatki',
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true,
                              ),
                              maxLines: 3,
                              onSaved: (value) {
                                _notes = value;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Rekomendacje',
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true,
                              ),
                              maxLines: 3,
                              onSaved: (value) {
                                _recommendations = value;
                              },
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
                        label: const Text('Zapisz Zlecenie'),
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
