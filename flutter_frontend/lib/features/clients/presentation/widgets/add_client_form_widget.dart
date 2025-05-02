import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/utils/validators.dart';

class AddClientFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  // final String? selectedSegment;
  // final Function(String?) onSegmentChanged;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  const AddClientFormWidget({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
    // required this.selectedSegment,
    // required this.onSegmentChanged,
    required this.onSubmit,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: firstNameController,
            decoration: const InputDecoration(
              labelText: 'Imię',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: lastNameController,
            decoration: const InputDecoration(
              labelText: 'Nazwisko',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: 'Telefon',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            validator: Validators.phone(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: addressController,
            decoration: const InputDecoration(
              labelText: 'Adres',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          // DropdownButtonFormField<String>(
          //   decoration: const InputDecoration(
          //     labelText: 'Segment',
          //     border: OutlineInputBorder(),
          //   ),
          //   value: selectedSegment,
          //   items: ['A', 'B', 'C', 'D']
          //       .map((segment) => DropdownMenuItem(
          //             value: segment,
          //             child: Text('Segment $segment'),
          //           ))
          //       .toList(),
          //   onChanged: onSegmentChanged,
          // ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: onSubmit,
                    child: const Text('Dodaj Klienta'),
                  ),
          ),
        ],
      ),
    );
  }
}