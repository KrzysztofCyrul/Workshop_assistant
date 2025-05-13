import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/appointment_bloc.dart';
import '../../../clients/domain/entities/client.dart';
import '../../../vehicles/domain/entities/vehicle.dart';
import '../../../clients/presentation/bloc/client_bloc.dart';
import '../../../vehicles/presentation/bloc/vehicle_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

// Constants for appointment status
class AppointmentStatus {
  static const String pending = 'pending';
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';
  static const String canceled = 'canceled';

  static String getLabel(String status) {
    switch (status) {
      case pending:
        return 'Do wykonania';
      case inProgress:
        return 'W trakcie';
      case completed:
        return 'Zakończone';
      case canceled:
        return 'Anulowane';
      default:
        return status;
    }
  }
  
  static IconData getIcon(String status) {
    switch (status) {
      case pending:
        return Icons.pending;
      case inProgress:
        return Icons.timelapse;
      case completed:
        return Icons.check_circle;
      case canceled:
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  static Color getColor(String status) {
    switch (status) {
      case pending:
        return Colors.orange;
      case inProgress:
        return Colors.blue;
      case completed:
        return Colors.green;
      case canceled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class AddAppointmentScreen extends StatefulWidget {
  static const String routeName = '/add-appointment';
  
  final String workshopId;

  const AddAppointmentScreen({
    super.key,
    required this.workshopId,
  });

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _estimatedDurationController = TextEditingController(text: '60');
    // Form values
  Client? _selectedClient;
  Vehicle? _selectedVehicle;  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedStatus = 'pending'; // Default status
  List<String> _selectedMechanicIds = []; // Store mechanic IDs
  bool _isLoadingClients = true;
  bool _isLoadingVehicles = false;
  
  @override
  void initState() {
    super.initState();
    // Load initial data
    _loadData();
  }  void _loadData() {
    // Load clients for this workshop
    context.read<ClientBloc>().add(LoadClientsEvent(workshopId: widget.workshopId));
    
    // Current user should be automatically selected
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      setState(() {
        _selectedMechanicIds = [authState.user.id];
      });
    }
  }

  void _onClientSelected(Client client) {
    setState(() {
      _selectedClient = client;
      _selectedVehicle = null; // Reset vehicle selection
      _isLoadingVehicles = true;
    });
    
    // Load vehicles for selected client
    context.read<VehicleBloc>().add(
      LoadVehiclesForClientEvent(
        workshopId: widget.workshopId,
        clientId: client.id,
      ),
    );
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }
  // Method removed - functionality is handled directly in _buildMechanicsSelector
    void _submitForm() {
    if (_formKey.currentState!.validate() && _validateRequiredFields()) {
      // Create DateTime from date and time
      final DateTime scheduledTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      // Parse values
      final int mileage = _mileageController.text.isNotEmpty 
          ? int.tryParse(_mileageController.text) ?? 0 
          : 0;
      
      final int estimatedDuration = int.tryParse(_estimatedDurationController.text) ?? 60;
      
      // Add appointment
      context.read<AppointmentBloc>().add(
        AddAppointmentEvent(
          workshopId: widget.workshopId,
          clientId: _selectedClient!.id,
          vehicleId: _selectedVehicle!.id,
          scheduledTime: scheduledTime,
          notes: _notesController.text,
          mileage: mileage,
          recommendations: '',
          estimatedDuration: Duration(minutes: estimatedDuration),
          totalCost: 0.0, // Initial cost is 0
          status: _selectedStatus,
          assignedMechanicIds: _selectedMechanicIds,
        ),
      );
    }
  }
    bool _validateRequiredFields() {
    if (_selectedClient == null) {
      _showValidationError('Proszę wybrać klienta');
      return false;
    }
    
    if (_selectedVehicle == null) {
      _showValidationError('Proszę wybrać pojazd');
      return false;
    }
    
    if (_selectedMechanicIds.isEmpty) {
      _showValidationError('Proszę wybrać przynajmniej jednego mechanika');
      return false;
    }
    
    return true;
  }
  
  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  void _navigateToAddClientScreen() {
    // Navigate to add client screen
    Navigator.pushNamed(
      context,
      '/add-client',
      arguments: {'workshopId': widget.workshopId},
    ).then((_) {
      // Reload clients after returning
      context.read<ClientBloc>().add(LoadClientsEvent(workshopId: widget.workshopId));
    });
  }
  
  void _navigateToAddVehicleScreen() {
    if (_selectedClient == null) {
      _showValidationError('Proszę najpierw wybrać klienta');
      return;
    }
    
    // Navigate to add vehicle screen
    Navigator.pushNamed(
      context,
      '/add-vehicle',
      arguments: {
        'workshopId': widget.workshopId,
        'clientId': _selectedClient!.id,
      },    ).then((_) {
      // Reload vehicles after returning
      if (_selectedClient != null) {
        context.read<VehicleBloc>().add(
          LoadVehiclesForClientEvent(
            workshopId: widget.workshopId,
            clientId: _selectedClient!.id,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _mileageController.dispose();
    _estimatedDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj nową wizytę'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _submitForm,
            tooltip: 'Zapisz wizytę',
          ),
        ],
      ),      body: MultiBlocListener(
        listeners: [
          BlocListener<AppointmentBloc, AppointmentState>(
            listener: (context, state) {
              if (state is AppointmentOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                // Return true to indicate success when popping back to the appointment list
                Navigator.pop(context, true);
              } else if (state is AppointmentError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<ClientBloc, ClientState>(
            listener: (context, state) {
              if (state is ClientsLoaded) {
                setState(() {
                  _isLoadingClients = false;
                });
              }
            },
          ),
          BlocListener<VehicleBloc, VehicleState>(
            listener: (context, state) {
              if (state is VehiclesLoaded) {
                setState(() {
                  _isLoadingVehicles = false;
                });
              }
            },
          ),          // Removed UserBloc listener as it's not needed
        ],        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                    AppBar().preferredSize.height - 
                    MediaQuery.of(context).padding.top - 
                    MediaQuery.of(context).padding.bottom - 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Klient i pojazd'),
                  _buildClientSelector(),
                  const SizedBox(height: 16),
                  _buildVehicleSelector(),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Termin wizyty'),
                  _buildDateTimePicker(),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Szczegóły wizyty'),
                  _buildAppointmentDetails(),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Mechanicy'),
                  _buildMechanicsSelector(),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Notatki'),
                  _buildNotesField(),
                  const SizedBox(height: 40),
                  
                  _buildSubmitButton(),
                  // Add safe area at bottom to prevent overflow
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  // Pole do przechowywania tekstu wyszukiwania klientów
  String _clientSearchQuery = '';
  
  Widget _buildClientSelector() {
    return BlocBuilder<ClientBloc, ClientState>(
      builder: (context, state) {
        if (state is ClientsLoaded) {
          final allClients = state.clients;
          
          // Filtrowanie klientów na podstawie wyszukiwanego tekstu
          final clients = _clientSearchQuery.isEmpty
              ? allClients
              : allClients.where((client) {
                  final fullName = '${client.firstName} ${client.lastName}'.toLowerCase();
                  final phone = client.phone?.toLowerCase() ?? '';
                  final query = _clientSearchQuery.toLowerCase();
                  return fullName.contains(query) || phone.contains(query);
                }).toList();
          
          if (allClients.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Nie znaleziono żadnych klientów',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _navigateToAddClientScreen,
                  icon: const Icon(Icons.add),
                  label: const Text('Dodaj nowego klienta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          }
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Wyszukiwarka klientów
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Wyszukaj klienta...',
                          prefixIcon: const Icon(Icons.search, size: 22),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          // Dodanie przycisku do wyczyszczenia tekstu wyszukiwania
                          suffixIcon: _clientSearchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _clientSearchQuery = '';
                                  });
                                },
                              )
                            : null,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _clientSearchQuery = value;
                          });
                        },
                      ),
                    ),
                    
                    // Lista zwinięta do max 200px wysokości z możliwością przewijania
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: _selectedClient != null ? 
                      // Jeśli klient jest wybrany, pokazujemy tylko jego
                      ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            _getInitials(_selectedClient!.firstName, _selectedClient!.lastName),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        title: Text(
                          '${_selectedClient!.firstName} ${_selectedClient!.lastName}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: _selectedClient!.phone != null && _selectedClient!.phone!.isNotEmpty
                          ? Text(
                              _selectedClient!.phone!,
                              style: const TextStyle(fontSize: 12),
                            )
                          : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _selectedClient = null;
                              _selectedVehicle = null;
                              // Czyścimy wyszukiwanie przy usunięciu klienta
                              _clientSearchQuery = '';
                            });
                          },
                        ),
                      )
                      // W przeciwnym razie pokazujemy przewijalną listę klientów
                      : clients.isEmpty
                          ? ListTile(
                              dense: true,
                              leading: const Icon(Icons.search_off, color: Colors.grey),
                              title: const Text(
                                'Nie znaleziono pasujących klientów',
                                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: clients.length,
                              itemBuilder: (context, index) {
                                final client = clients[index];
                                return ListTile(
                                  dense: true,  // Bardziej kompaktowa lista
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                                  visualDensity: const VisualDensity(horizontal: 0, vertical: -4), // Jeszcze bardziej kompaktowa
                                  leading: CircleAvatar(
                                    radius: 16,  // Mniejszy rozmiar awatara
                                    backgroundColor: Theme.of(context).primaryColor,
                                    child: Text(
                                      _getInitials(client.firstName, client.lastName),
                                      style: const TextStyle(color: Colors.white, fontSize: 10),
                                    ),
                                  ),
                                  title: Text(
                                    '${client.firstName} ${client.lastName}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  subtitle: client.phone != null && client.phone!.isNotEmpty
                                    ? Text(
                                        client.phone!,
                                        style: const TextStyle(fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : null,
                                  onTap: () => _onClientSelected(client),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _navigateToAddClientScreen,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Dodaj nowego klienta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(120, 36),
                ),
              ),
            ],
          );
        } else if (state is ClientLoading || _isLoadingClients) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is ClientError) {
          return Center(
            child: Text(
              'Błąd: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else {
          return const Center(
            child: Text('Nie udało się załadować klientów'),
          );
        }
      },
    );
  }
    // Pole do przechowywania tekstu wyszukiwania pojazdów
  String _vehicleSearchQuery = '';
  
  Widget _buildVehicleSelector() {
    if (_selectedClient == null) {
      return const Card(
        elevation: 1,
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Najpierw wybierz klienta, aby zobaczyć jego pojazdy',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return BlocBuilder<VehicleBloc, VehicleState>(
      builder: (context, state) {
        if (state is VehiclesLoaded) {
          final allVehicles = state.vehicles;
          
          // Filtrowanie pojazdów na podstawie wyszukiwanego tekstu
          final vehicles = _vehicleSearchQuery.isEmpty
              ? allVehicles
              : allVehicles.where((vehicle) {
                  final vehicleInfo = '${vehicle.make} ${vehicle.model} ${vehicle.licensePlate}'.toLowerCase();
                  final query = _vehicleSearchQuery.toLowerCase();
                  return vehicleInfo.contains(query);
                }).toList();
          
          if (allVehicles.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Card(
                  elevation: 1,
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.directions_car_outlined, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Klient nie posiada żadnych pojazdów',
                            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _navigateToAddVehicleScreen,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Dodaj nowy pojazd'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: const Size(120, 36),
                  ),
                ),
              ],
            );
          }
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Wyszukiwarka pojazdów
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Wyszukaj pojazd...',
                          prefixIcon: const Icon(Icons.search, size: 22),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          // Dodanie przycisku do wyczyszczenia tekstu wyszukiwania
                          suffixIcon: _vehicleSearchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  setState(() {
                                    _vehicleSearchQuery = '';
                                  });
                                },
                              )
                            : null,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _vehicleSearchQuery = value;
                          });
                        },
                      ),
                    ),
                    
                    // Lista pojazdów zwinięta do max 200px wysokości z możliwością przewijania
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: _selectedVehicle != null 
                        // Jeśli pojazd jest wybrany, pokazujemy tylko jego
                        ? InkWell(
                          onTap: () {
                            setState(() {
                              _selectedVehicle = null;
                              _vehicleSearchQuery = '';
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.directions_car, size: 18, color: Colors.blueGrey),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${_selectedVehicle!.make} ${_selectedVehicle!.model}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Text(
                                        'Nr rej.: ${_selectedVehicle!.licensePlate}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${_selectedVehicle!.mileage} km',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const Text(
                                      'Przebieg',
                                      style: TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    setState(() {
                                      _selectedVehicle = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                        : vehicles.isEmpty
                            ? ListTile(
                                dense: true,
                                leading: const Icon(Icons.search_off, color: Colors.grey, size: 18),
                                title: const Text(
                                  'Nie znaleziono pasujących pojazdów',
                                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: vehicles.length,
                                itemBuilder: (context, index) {
                                  final vehicle = vehicles[index];
                                  return InkWell(
                                    onTap: () {
                                      setState(() {                                        _selectedVehicle = vehicle;
                                        _mileageController.text = vehicle.mileage.toString();
                                        _vehicleSearchQuery = '';
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: Colors.blueGrey.shade100,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Icon(Icons.directions_car, size: 16, color: Colors.blueGrey),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  '${vehicle.make} ${vehicle.model}',
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                ),
                                                Text(
                                                  'Nr rej.: ${vehicle.licensePlate}',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${vehicle.mileage} km',
                                                style: const TextStyle(fontSize: 11),
                                              ),
                                              const Text(
                                                'Przebieg',
                                                style: TextStyle(fontSize: 9, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _navigateToAddVehicleScreen,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Dodaj nowy pojazd'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        } else if (state is VehicleLoading || _isLoadingVehicles) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is VehicleError) {
          return Center(
            child: Text(
              'Błąd: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else {
          return const Center(
            child: Text('Nie udało się załadować pojazdów'),
          );
        }
      },
    );
  }

  String _getInitials(String firstName, String lastName) {
    String initials = '';
    
    if (firstName.isNotEmpty) {
      initials += firstName[0];
    }
    
    if (lastName.isNotEmpty) {
      initials += lastName[0];
    }
    
    return initials.isNotEmpty ? initials.toUpperCase() : '?';
  }

  Widget _buildDateTimePicker() {
    final formattedDate = DateFormat('dd.MM.yyyy').format(_selectedDate);
    final formattedTime = '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Data',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              formattedDate,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: InkWell(
                  onTap: () => _selectTime(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Godzina',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              formattedTime,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildAppointmentDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Prevent expanding too much
      children: [
        // Wrap TextFormField in constraints to ensure proper sizing
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 80),
          child: TextFormField(
            controller: _mileageController,
            decoration: InputDecoration(
              labelText: 'Przebieg (km)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.speed),
              hintText: 'Opcjonalnie',
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 80),
          child: TextFormField(
            controller: _estimatedDurationController,
            decoration: InputDecoration(
              labelText: 'Szacowany czas trwania (min)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.timer),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Proszę podać szacowany czas';
              }
              if (int.tryParse(value) == null) {
                return 'Proszę podać prawidłową liczbę';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(
                        value: 'pending',
                        child: Row(
                          children: [
                            Icon(
                              AppointmentStatus.getIcon('pending'), 
                              color: AppointmentStatus.getColor('pending'),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(AppointmentStatus.getLabel('pending')),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'in_progress',
                        child: Row(
                          children: [
                            Icon(
                              AppointmentStatus.getIcon('in_progress'),
                              color: AppointmentStatus.getColor('in_progress'),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(AppointmentStatus.getLabel('in_progress')),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedStatus = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }    Widget _buildMechanicsSelector() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          final user = state.user;
          final isSelected = _selectedMechanicIds.contains(user.id);
          
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Prevent expanding too much
                children: [
                  const Text(
                    'Mechanik przypisany do zlecenia',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Wrap ListTile in a container with fixed height to prevent overflow
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 70),
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                      leading: CircleAvatar(
                        backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                        child: Text(
                          _getInitials(user.firstName, user.lastName),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text('${user.firstName} ${user.lastName}'),
                      subtitle: Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              if (!_selectedMechanicIds.contains(user.id)) {
                                _selectedMechanicIds.add(user.id);
                              }
                            } else {
                              _selectedMechanicIds.remove(user.id);
                            }
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedMechanicIds.remove(user.id);
                          } else {
                            _selectedMechanicIds.add(user.id);
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Card(
            elevation: 1,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Proszę się zalogować, aby wybrać mechanika'),
                ],
              ),
            ),
          );
        }
      },
    );
  }
    Widget _buildNotesField() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 120),
      child: TextFormField(
        controller: _notesController,
        decoration: InputDecoration(
          labelText: 'Notatki',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.note),
          hintText: 'Opcjonalnie informacje dotyczące wizyty',
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        maxLines: 3,
        minLines: 3,
      ),
    );
  }
  
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: BlocBuilder<AppointmentBloc, AppointmentState>(
          builder: (context, state) {
            if (state is AppointmentLoading) {
              return const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            return const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add),
                SizedBox(width: 8),
                Text(
                  'Dodaj wizytę',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}