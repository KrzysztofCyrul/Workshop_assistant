import 'package:flutter/material.dart';

class ClientFormWidget extends StatelessWidget {
  // static const List<String> segments = ['A', 'B', 'C', 'D'];

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  // final String? selectedSegment;
  // final ValueChanged<String?> onSegmentChanged;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  const ClientFormWidget({
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: firstNameController,
            decoration: const InputDecoration(
              labelText: 'Imię',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Proszę podać imię';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: lastNameController,
            decoration: const InputDecoration(
              labelText: 'Nazwisko',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Proszę podać nazwisko';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Proszę podać email';
              }
              if (!value.contains('@')) {
                return 'Nieprawidłowy format email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: 'Telefon',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: addressController,
            decoration: const InputDecoration(
              labelText: 'Adres',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          // DropdownButtonFormField<String>(
          //   decoration: const InputDecoration(
          //     labelText: 'Segment klienta',
          //     border: OutlineInputBorder(),
          //   ),
          //   value: selectedSegment,
          //   items: [
          //     const DropdownMenuItem<String>(
          //       value: null,
          //       child: Text('Wybierz segment'),
          //     ),
          //     ...segments.map((segment) => DropdownMenuItem(
          //           value: segment,
          //           child: Text('Segment $segment'),
          //         )),
          //   ],
          //   onChanged: onSegmentChanged,
          // ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: isSubmitting ? null : onSubmit,
            child: isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Zapisz'),
          ),
        ],
      ),
    );
  }
}