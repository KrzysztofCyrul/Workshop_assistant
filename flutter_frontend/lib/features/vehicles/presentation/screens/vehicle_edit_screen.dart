import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/features/vehicles/presentation/bloc/vehicle_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/providers/auth_provider.dart';

class VehicleEditScreen extends StatefulWidget {
  static const routeName = '/vehicle-edit';
  final String vehicleId;
  final String workshopId;

  const VehicleEditScreen({
    super.key,
    required this.vehicleId,
    required this.workshopId,
  });

  @override
  State<VehicleEditScreen> createState() => _VehicleEditScreenState();
}

class _VehicleEditScreenState extends State<VehicleEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers for form fields
  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _vinController;
  late TextEditingController _licensePlateController;
  late TextEditingController _mileageController;
  bool _controllersInitialized = false;


  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.accessToken == null) {
      throw Exception('User not authenticated');
    }
    context.read<VehicleBloc>().add(LoadVehicleDetailsEvent(
          accessToken: authProvider.accessToken!,
          workshopId: widget.workshopId,
          vehicleId: widget.vehicleId,
        ));
  }

void _initializeControllers(VehicleDetailsLoaded state) {
    if (_controllersInitialized) return;
    final vehicle = state.vehicle;
    _makeController = TextEditingController(text: vehicle.make);
    _modelController = TextEditingController(text: vehicle.model);
    _yearController = TextEditingController(text: vehicle.year.toString());
    _vinController = TextEditingController(text: vehicle.vin);
    _licensePlateController = TextEditingController(text: vehicle.licensePlate);
    _mileageController = TextEditingController(text: vehicle.mileage.toString());
    _controllersInitialized = true;

  }

    @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_controllersInitialized) {
      final state = context.read<VehicleBloc>().state;
      if (state is VehicleDetailsLoaded) {
        _initializeControllers(state);
      }
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      context.read<VehicleBloc>().add(UpdateVehicleEvent(
            accessToken: authProvider.accessToken!,
            workshopId: widget.workshopId,
            vehicleId: widget.vehicleId,
            make: _makeController.text,
            model: _modelController.text,
            year: int.parse(_yearController.text),
            vin: _vinController.text,
            licensePlate: _licensePlateController.text,
            mileage: int.parse(_mileageController.text),
          ));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle updated successfully')),
      );
      context.read<VehicleBloc>().add(ResetVehicleStateEvent());
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating vehicle: $error')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Vehicle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: BlocBuilder<VehicleBloc, VehicleState>(
        builder: (context, state) {
          if (state is VehicleLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is VehicleError) {
            return Center(child: Text(state.message));
          }
          if (state is VehicleDetailsLoaded) {
            _initializeControllers(state);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildFormField(
                      label: 'Make',
                      controller: _makeController,
                      validator: (value) => value!.isEmpty ? 'Enter make' : null,
                    ),
                    _buildFormField(
                      label: 'Model',
                      controller: _modelController,
                      validator: (value) => value!.isEmpty ? 'Enter model' : null,
                    ),
                    _buildFormField(
                      label: 'Year',
                      controller: _yearController,
                      validator: (value) => value!.isEmpty || int.tryParse(value) == null
                          ? 'Enter valid year'
                          : null,
                      keyboardType: TextInputType.number,
                    ),
                    _buildFormField(
                      label: 'VIN',
                      controller: _vinController,
                      validator: (value) => null,
                    ),
                    _buildFormField(
                      label: 'License Plate',
                      controller: _licensePlateController,
                      validator: (value) => value!.isEmpty ? 'Enter license plate' : null,
                    ),
                    _buildFormField(
                      label: 'Mileage (km)',
                      controller: _mileageController,
                      validator: (value) => value!.isEmpty || int.tryParse(value) == null
                          ? 'Enter valid mileage'
                          : null,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _saveForm,
                            child: const Text('Save Changes'),
                          ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: Text('Vehicle not found'));
        },
      ),
    );
  }
}