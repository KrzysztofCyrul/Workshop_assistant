import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/features/clients/domain/entities/client.dart';
import 'package:flutter_frontend/features/quotations/presentation/screens/quotation_details_screen.dart';
import 'package:flutter_frontend/features/vehicles/domain/entities/vehicle.dart';
import 'package:flutter_frontend/features/clients/presentation/bloc/client_bloc.dart';
import 'package:flutter_frontend/features/vehicles/presentation/bloc/vehicle_bloc.dart';
import 'package:flutter_frontend/features/quotations/presentation/bloc/quotation_bloc.dart';

class AddQuotationScreen extends StatefulWidget {
  static const routeName = '/add-quotation';

  final String workshopId;

  const AddQuotationScreen({
    super.key,
    required this.workshopId,
  });

  @override
  State<AddQuotationScreen> createState() => _AddQuotationScreenState();
}

class _AddQuotationScreenState extends State<AddQuotationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  Client? _selectedClient;
  Vehicle? _selectedVehicle;
  final TextEditingController _notesController = TextEditingController();
  double? _totalCost;
  DateTime _quotationDate = DateTime.now();

  // Loading state
  bool _isSubmitting = false;
  bool _isLoadingClients = true;
  bool _isLoadingVehicles = false;
  
  // Search queries
  String _clientSearchQuery = '';
  String _vehicleSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  void _loadInitialData() {
    context.read<ClientBloc>().add(
      LoadClientsEvent(workshopId: widget.workshopId),
    );
  }void _submitForm() {
    if (_formKey.currentState!.validate() && _validateRequiredFields()) {
      // Create the quotation with all required fields
      context.read<QuotationBloc>().add(
        AddQuotationEvent(
          workshopId: widget.workshopId,
          clientId: _selectedClient!.id,
          vehicleId: _selectedVehicle!.id,
          totalCost: _totalCost,
          notes: _notesController.text,
          date: _quotationDate,
        ),
      );
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
      },
    ).then((_) {
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
  
  bool _validateRequiredFields() {
    if (_selectedClient == null) {
      _showValidationError('Proszę wybrać klienta');
      return false;
    }
    
    if (_selectedVehicle == null) {
      _showValidationError('Proszę wybrać pojazd');
      return false;
    }
    
    return true;
  }
  
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj nową wycenę'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _submitForm,
            tooltip: 'Zapisz wycenę',
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<QuotationBloc, QuotationState>(
            listener: (context, state) {
              if (state is QuotationLoading) {
                setState(() {
                  _isSubmitting = true;
                });
              } else if (state is QuotationError) {
                setState(() {
                  _isSubmitting = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is QuotationAdded) {
                setState(() {
                  _isSubmitting = false;
                });
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => QuotationDetailsScreen(
                      workshopId: widget.workshopId,
                      quotationId: state.quotationId,
                    ),
                  ),
                );
              } else if (state is QuotationUnauthenticated) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
          BlocListener<ClientBloc, ClientState>(
            listener: (context, state) {
              if (state is ClientsLoaded) {
                setState(() {
                  _isLoadingClients = false;
                });
              } else if (state is ClientUnauthenticated) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
          BlocListener<VehicleBloc, VehicleState>(
            listener: (context, state) {
              if (state is VehiclesLoaded) {
                setState(() {
                  _isLoadingVehicles = false;
                });
              } else if (state is VehicleUnauthenticated) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            physics: const AlwaysScrollableScrollPhysics(),
            child: _isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Dane klienta'),
                      _buildClientSelector(),
                      const SizedBox(height: 24),
                      
                      _buildSectionTitle('Dane pojazdu'),
                      _buildVehicleSelector(),
                      const SizedBox(height: 24),
                        _buildSectionTitle('Data wystawienia wyceny'),
                      _buildDateSelector(),
                      const SizedBox(height: 24),

                      _buildSectionTitle('Szacowany koszt'),
                      _buildPriceField(),
                      const SizedBox(height: 24),
                      
                      _buildSectionTitle('Uwagi'),
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
    );
  }
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
                          ? const ListTile(
                              dense: true,
                              leading: Icon(Icons.search_off, color: Colors.grey),
                              title: Text(
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
                    
                    // Lista zwinięta do max 200px wysokości z możliwością przewijania
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: _selectedVehicle != null ? 
                      // Jeśli pojazd jest wybrany, pokazujemy tylko jego
                      ListTile(
                        dense: true,
                        leading: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.teal,
                          child: Icon(Icons.directions_car, color: Colors.white, size: 18),
                        ),
                        title: Text(
                          '${_selectedVehicle!.make} ${_selectedVehicle!.model}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          _selectedVehicle!.licensePlate,
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _selectedVehicle = null;
                              // Czyścimy wyszukiwanie przy usunięciu pojazdu
                              _vehicleSearchQuery = '';
                            });
                          },
                        ),
                      )
                      // W przeciwnym razie pokazujemy przewijalną listę pojazdów
                      : vehicles.isEmpty
                          ? const ListTile(
                              dense: true,
                              leading: Icon(Icons.search_off, color: Colors.grey),
                              title: Text(
                                'Nie znaleziono pasujących pojazdów',
                                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: vehicles.length,
                              itemBuilder: (context, index) {
                                final vehicle = vehicles[index];
                                return ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                                  visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                                  leading: const CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.teal,
                                    child: Icon(Icons.directions_car, color: Colors.white, size: 14),
                                  ),
                                  title: Text(
                                    '${vehicle.make} ${vehicle.model}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    vehicle.licensePlate,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedVehicle = vehicle;
                                    });
                                  },
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(120, 36),
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
          return const Card(
            elevation: 1,
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'Nie udało się załadować pojazdów',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }
      },
    );
  }
    Widget _buildNotesField() {
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
          children: [
            const Text(
              'Wpisz dodatkowe informacje dotyczące wyceny',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120),
              child: TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: 'Opcjonalne uwagi do wyceny...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.note),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
                  ),
                ),
                maxLines: 3,
                minLines: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
    Widget _buildPriceField() {
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
          children: [
            const Text(
              'Szacowany koszt wyceny',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _totalCost?.toStringAsFixed(2) ?? '',
                    decoration: InputDecoration(
                      labelText: 'Cena (PLN)',
                      hintText: '0.00',
                      prefixIcon: const Icon(Icons.attach_money),
                      suffixText: 'PLN',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      setState(() {
                        _totalCost = double.tryParse(value);
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
    Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: BlocBuilder<QuotationBloc, QuotationState>(
          builder: (context, state) {
            if (state is QuotationLoading) {
              return const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            return const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description, size: 22),
                SizedBox(width: 12),
                Text(
                  'Utwórz nową wycenę',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _quotationDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)), // Allow dates from 30 days ago
      lastDate: DateTime.now().add(const Duration(days: 30)), // Allow dates up to 30 days in future
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null && pickedDate != _quotationDate) {
      setState(() {
        _quotationDate = pickedDate;
      });
    }
  }
  Widget _buildDateSelector() {
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
          children: [
            const Text(
              'Data wystawienia wyceny',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      '${_quotationDate.day.toString().padLeft(2, '0')}.${_quotationDate.month.toString().padLeft(2, '0')}.${_quotationDate.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}