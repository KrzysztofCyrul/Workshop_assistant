import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/workshop_service.dart';

class CreateWorkshopScreen extends StatefulWidget {
  static const routeName = '/create-workshop';

  const CreateWorkshopScreen({super.key});

  @override
  _CreateWorkshopScreenState createState() => _CreateWorkshopScreenState();
}

class _CreateWorkshopScreenState extends State<CreateWorkshopScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _workshopNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postCodeController = TextEditingController();
  final TextEditingController _nipNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  bool _isSubmitting = false;

void _submitForm() async {
  if (!_formKey.currentState!.validate()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Proszę poprawić błędy w formularzu')),
    );
    return;
  }

  setState(() {
    _isSubmitting = true;
  });

  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final accessToken = authProvider.accessToken;

  if (accessToken == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Brak dostępu do danych użytkownika')),
    );
    setState(() {
      _isSubmitting = false;
    });
    return;
  }

  try {
    await WorkshopService.createWorkshop(
      accessToken: accessToken,
      name: _workshopNameController.text,
      address: _addressController.text,
      postCode: _postCodeController.text,
      nipNumber: _nipNumberController.text,
      email: _emailController.text,
      phoneNumber: _phoneNumberController.text,
    );

    // Refresh user profile
    await authProvider.refreshUserProfile();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Warsztat został utworzony pomyślnie')),
    );

    // Navigate to the Home Screen
    Navigator.of(context).pushReplacementNamed('/home');
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Błąd podczas tworzenia warsztatu: $e')),
    );
  } finally {
    setState(() {
      _isSubmitting = false;
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Utwórz Warsztat'),
      ),
      body: SingleChildScrollView(
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
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              TextFormField(
                controller: _nipNumberController,
                decoration: const InputDecoration(
                  labelText: 'NIP',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty) {
                    return 'Nieprawidłowy format email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
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
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Utwórz Warsztat'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _workshopNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
