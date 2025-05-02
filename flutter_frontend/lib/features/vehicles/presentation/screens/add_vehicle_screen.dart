import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/features/vehicles/presentation/bloc/vehicle_bloc.dart';
import 'package:flutter_frontend/features/clients/presentation/bloc/client_bloc.dart';
import 'package:flutter_frontend/features/vehicles/presentation/models/vehicle_form_model.dart';
import 'package:flutter_frontend/features/vehicles/presentation/widgets/vehicle_form_widget.dart';
import 'package:flutter_frontend/features/clients/domain/entities/client.dart';

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
          child: VehicleFormWidget(
            formKey: _formKey,
            makeController: _makeController,
            modelController: _modelController,
            yearController: _yearController,
            vinController: _vinController,
            licensePlateController: _licensePlateController,
            mileageController: _mileageController,
            selectedClient: _selectedClient,
            onClientChanged: (client) => setState(() => _selectedClient = client),
            onSubmit: _submitForm,
            isSubmitting: _isSubmitting,
            workshopId: widget.workshopId,
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