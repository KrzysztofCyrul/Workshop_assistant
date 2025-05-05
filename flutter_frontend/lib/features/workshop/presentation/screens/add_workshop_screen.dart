import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/workshop_bloc.dart';

class AddWorkshopScreen extends StatefulWidget {
  static const routeName = '/add-workshop';

  const AddWorkshopScreen({super.key});

  @override
  State<AddWorkshopScreen> createState() => _AddWorkshopScreenState();
}

class _AddWorkshopScreenState extends State<AddWorkshopScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workshopNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _postCodeController = TextEditingController();
  final _nipNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  bool _isSubmitting = false;

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<WorkshopBloc>().add(
          AddWorkshopEvent(
            name: _workshopNameController.text,
            address: _addressController.text,
            postCode: _postCodeController.text,
            nipNumber: _nipNumberController.text,
            email: _emailController.text,
            phoneNumber: _phoneNumberController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Utwórz Warsztat'),
      ),
      body: BlocConsumer<WorkshopBloc, WorkshopState>(
        listener: (context, state) {
          if (state is WorkshopLoading) {
            setState(() => _isSubmitting = true);
          } else {
            setState(() => _isSubmitting = false);
          }

          if (state is WorkshopOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                duration: const Duration(seconds: 2),
              ),
            );
            
            // Zmieniona nawigacja - przekierowanie do ekranu logowania
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false, // czyści cały stos nawigacji
              );
            }
          }

          if (state is WorkshopError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (state is WorkshopUnauthenticated) {
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            }
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _workshopNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nazwa warsztatu',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nazwa warsztatu jest wymagana';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Adres',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Adres jest wymagany';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _postCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Kod pocztowy',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kod pocztowy jest wymagany';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nipNumberController,
                    decoration: const InputDecoration(
                      labelText: 'NIP',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegExp.hasMatch(value)) {
                          return 'Nieprawidłowy format email';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Telefon',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Telefon jest wymagany';
                      } else if (value.length > 20) {
                        return 'Telefon nie może mieć więcej niż 20 znaków';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: _isSubmitting
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _submitForm,
                            child: const Text('Utwórz Warsztat'),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _workshopNameController.dispose();
    _addressController.dispose();
    _postCodeController.dispose();
    _nipNumberController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }
}
