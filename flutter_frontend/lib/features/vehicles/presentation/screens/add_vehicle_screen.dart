import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/features/vehicles/presentation/bloc/vehicle_bloc.dart';
import 'package:flutter_frontend/features/clients/presentation/bloc/client_bloc.dart';
import 'package:flutter_frontend/features/vehicles/presentation/models/vehicle_form_model.dart';
import 'package:flutter_frontend/features/clients/domain/entities/client.dart';
import 'package:flutter_frontend/features/clients/presentation/screens/add_client_screen.dart';

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
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _vinController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _mileageController = TextEditingController();

  Client? _selectedClient;
  bool _isSubmitting = false;
  String _clientSearchQuery = '';
  bool _isSearchingClients = false;

  @override
  void initState() {
    super.initState();
    _selectedClient = widget.selectedClient;
    
    // Load clients when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientBloc>().add(
            LoadClientsEvent(workshopId: widget.workshopId),
          );
    });
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wybierz klienta')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final vehicle = VehicleFormModel(
      make: _makeController.text,
      model: _modelController.text,
      year: _yearController.text,
      vin: _vinController.text,
      licensePlate: _licensePlateController.text,
      mileage: _mileageController.text,
      clientId: _selectedClient!.id,
    );

    context.read<VehicleBloc>().add(AddVehicleEvent(
      workshopId: widget.workshopId,
      clientId: vehicle.clientId,
      make: vehicle.make,
      model: vehicle.model,
      year: int.tryParse(vehicle.year ?? '') ?? 0,
      vin: vehicle.vin ?? '',
      licensePlate: vehicle.licensePlate,
      mileage: int.tryParse(vehicle.mileage ?? '') ?? 0,
    ));
  }

  void _onClientSelected(Client client) {
    setState(() {
      _selectedClient = client;
      _isSearchingClients = false;
      _clientSearchQuery = '';
    });
  }

  void _navigateToAddClientScreen() async {
    final result = await Navigator.pushNamed(
      context,
      AddClientScreen.routeName,
      arguments: {'workshopId': widget.workshopId},
    );
    
    if (result == true) {
      context.read<ClientBloc>().add(
        LoadClientsEvent(workshopId: widget.workshopId),
      );
    }
  }

  // Helper method to get initials from name
  String _getInitials(String firstName, String lastName) {
    String initials = '';
    if (firstName.isNotEmpty) initials += firstName[0];
    if (lastName.isNotEmpty) initials += lastName[0];
    return initials.toUpperCase();
  }

  Widget _buildClientSelector() {
    return BlocBuilder<ClientBloc, ClientState>(
      builder: (context, state) {
        if (state is ClientsLoaded) {
          final allClients = state.clients;
          
          // Filter clients based on search query
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
                    // Client search field
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
                        onTap: () {
                          setState(() {
                            _isSearchingClients = true;
                          });
                        },
                        onChanged: (value) {
                          setState(() {
                            _clientSearchQuery = value;
                            if (value.isNotEmpty) {
                              _isSearchingClients = true;
                            }
                          });
                        },
                      ),
                    ),
                    
                    // Client list in a scrollable container
                    if (_isSearchingClients || _selectedClient == null)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: clients.isEmpty
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
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                                    visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                                    leading: CircleAvatar(
                                      radius: 16,
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
                    
                    // Selected client display
                    if (_selectedClient != null && !_isSearchingClients)
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
                            });
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
        } else if (state is ClientLoading) {
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
        }
        
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj Pojazd'),
      ),
      body: BlocListener<VehicleBloc, VehicleState>(
        listener: (context, state) {
          if (state is VehicleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            setState(() => _isSubmitting = false);
          } else if (state is VehicleOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.of(context).pop(true);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildClientSelector(),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _makeController,
                  decoration: InputDecoration(
                    labelText: 'Marka',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Marka jest wymagana' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _modelController,
                  decoration: InputDecoration(
                    labelText: 'Model',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Model jest wymagany' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _yearController,
                  decoration: InputDecoration(
                    labelText: 'Rok produkcji',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _vinController,
                  decoration: InputDecoration(
                    labelText: 'VIN',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _licensePlateController,
                  decoration: InputDecoration(
                    labelText: 'Numer rejestracyjny',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Numer rejestracyjny jest wymagany' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mileageController,
                  decoration: InputDecoration(
                    labelText: 'Przebieg (km)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Dodaj Pojazd', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
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