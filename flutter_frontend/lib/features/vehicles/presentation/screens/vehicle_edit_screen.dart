import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/features/vehicles/presentation/bloc/vehicle_bloc.dart';
import 'package:flutter_frontend/core/widgets/custom_app_bar.dart';
import 'package:flutter_frontend/core/theme/app_theme.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/custom_text_field.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/details_card_widget.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/form_submit_button.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/loading_indicator.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/error_state_widget.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/vehicle_profile_widget.dart';

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
  bool _controllersInitialized = false;

  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _vinController;
  late TextEditingController _licensePlateController;
  late TextEditingController _mileageController;

  @override
  void initState() {
    super.initState();
    _loadVehicleDetails();
  }

  void _loadVehicleDetails() {
    if (mounted) {
      context.read<VehicleBloc>().add(LoadVehicleDetailsEvent(
        workshopId: widget.workshopId,
        vehicleId: widget.vehicleId,
      ));
    }
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

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      context.read<VehicleBloc>().add(UpdateVehicleEvent(
        workshopId: widget.workshopId,
        vehicleId: widget.vehicleId,
        make: _makeController.text,
        model: _modelController.text,
        year: int.parse(_yearController.text),
        vin: _vinController.text,
        licensePlate: _licensePlateController.text,
        mileage: int.parse(_mileageController.text),
      ));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      appBar: CustomAppBar(
        title: 'Edytuj Pojazd',
        feature: 'vehicles',
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
            tooltip: 'Zapisz zmiany',
          ),
        ],
      ),
      body: BlocConsumer<VehicleBloc, VehicleState>(
        listener: (context, state) {
          if (state is VehicleOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.of(context).pop();
          } else if (state is VehicleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },        builder: (context, state) {
          if (state is VehicleLoading) {
            return const LoadingIndicator();
          }
          if (state is VehicleError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: _loadVehicleDetails,
            );
          }
          if (state is VehicleDetailsLoaded) {
            _initializeControllers(state);
            return _buildBody(state);
          }
          return const Center(
            child: Text(
              'Nie znaleziono pojazdu',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
  Widget _buildBody(VehicleDetailsLoaded state) {
    final vehicle = state.vehicle;
    final vehicleFeatureColor = AppTheme.getFeatureColor('vehicles');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Profile Card
            VehicleProfileWidget(
              make: vehicle.make,
              model: vehicle.model,
              licensePlate: vehicle.licensePlate,
            ),
            
            const SizedBox(height: 16.0),
            
            // Basic Information Section
            DetailsCardWidget(
              title: 'Informacje podstawowe',
              subtitle: 'Dane identyfikacyjne pojazdu',
              icon: Icons.info,
              iconBackgroundColor: vehicleFeatureColor.withValues(alpha: 0.1),
              iconColor: vehicleFeatureColor,
              initiallyExpanded: true,
              children: [
                CustomTextField(
                  controller: _makeController,
                  labelText: 'Marka',
                  prefixIcon: Icons.category,
                  validator: (value) => value?.isEmpty ?? true ? 'Marka jest wymagana' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _modelController,
                  labelText: 'Model',
                  prefixIcon: Icons.style,
                  validator: (value) => value?.isEmpty ?? true ? 'Model jest wymagany' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _yearController,
                  labelText: 'Rok produkcji',
                  prefixIcon: Icons.date_range,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Rok jest wymagany';
                    final year = int.tryParse(value!);
                    if (year == null) return 'Wprowadź prawidłowy rok';
                    if (year < 1900 || year > DateTime.now().year + 1) {
                      return 'Rok musi być między 1900 a ${DateTime.now().year + 1}';
                    }
                    return null;
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16.0),
            
            // Technical Information Section
            DetailsCardWidget(
              title: 'Dane techniczne',
              subtitle: 'VIN i informacje eksploatacyjne',
              icon: Icons.engineering,
              iconBackgroundColor: Colors.grey.shade100,
              iconColor: Colors.grey.shade600,
              initiallyExpanded: true,
              children: [
                CustomTextField(
                  controller: _vinController,
                  labelText: 'VIN',
                  prefixIcon: Icons.tag,
                  hintText: 'Opcjonalnie - numer VIN',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _licensePlateController,
                  labelText: 'Numer rejestracyjny',
                  prefixIcon: Icons.badge,
                  validator: (value) => value?.isEmpty ?? true ? 'Numer rejestracyjny jest wymagany' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _mileageController,
                  labelText: 'Przebieg (km)',
                  prefixIcon: Icons.speed,
                  keyboardType: TextInputType.number,
                  suffixText: 'km',
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Przebieg jest wymagany';
                    final mileage = int.tryParse(value!);
                    if (mileage == null) return 'Wprowadź prawidłowy przebieg';
                    if (mileage < 0) return 'Przebieg nie może być ujemny';
                    return null;
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Save Button
            FormSubmitButton(
              label: 'Zapisz zmiany',
              onPressed: _saveForm,
              isSubmitting: _isLoading,
              backgroundColor: vehicleFeatureColor,
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    if (_controllersInitialized) {
      _makeController.dispose();
      _modelController.dispose();
      _yearController.dispose();
      _vinController.dispose();
      _licensePlateController.dispose();
      _mileageController.dispose();
    }
    super.dispose();
  }
}