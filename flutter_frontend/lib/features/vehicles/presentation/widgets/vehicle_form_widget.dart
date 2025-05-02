import 'package:flutter/material.dart';
import 'package:flutter_frontend/features/clients/domain/entities/client.dart';
import 'package:flutter_frontend/core/widgets/custom_text_field.dart';
import 'package:flutter_frontend/features/vehicles/presentation/widgets/client_search_widget.dart';

class VehicleFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController makeController;
  final TextEditingController modelController;
  final TextEditingController yearController;
  final TextEditingController vinController;
  final TextEditingController licensePlateController;
  final TextEditingController mileageController;
  final Client? selectedClient;
  final ValueChanged<Client?> onClientChanged;
  final VoidCallback onSubmit;
  final bool isSubmitting;
  final String workshopId;

  const VehicleFormWidget({
    super.key,
    required this.formKey,
    required this.makeController,
    required this.modelController,
    required this.yearController,
    required this.vinController,
    required this.licensePlateController,
    required this.mileageController,
    this.selectedClient,
    required this.onClientChanged,
    required this.onSubmit,
    required this.isSubmitting,
    required this.workshopId,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClientSearchWidget(
            selectedClient: selectedClient,
            onChanged: onClientChanged,
            validator: (client) => client == null ? 'Wybierz klienta' : null,
            workshopId: workshopId,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: makeController,
            labelText: 'Marka',
            validator: (value) => value?.isEmpty ?? true ? 'Marka jest wymagana' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: modelController,
            labelText: 'Model',
            validator: (value) => value?.isEmpty ?? true ? 'Model jest wymagany' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: yearController,
            labelText: 'Rok produkcji',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: vinController,
            labelText: 'VIN',
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: licensePlateController,
            labelText: 'Numer rejestracyjny',
            validator: (value) => value?.isEmpty ?? true ? 'Numer rejestracyjny jest wymagany' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: mileageController,
            labelText: 'Przebieg (km)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Dodaj Pojazd'),
            ),
          ),
        ],
      ),
    );
  }
}