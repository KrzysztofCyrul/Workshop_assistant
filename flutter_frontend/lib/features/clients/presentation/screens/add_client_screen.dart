import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/features/clients/presentation/bloc/client_bloc.dart';
import 'package:flutter_frontend/features/clients/presentation/widgets/add_client_form_widget.dart';

class AddClientScreen extends StatefulWidget {
  static const routeName = '/add-client';

  final String workshopId;

  const AddClientScreen({
    super.key,
    required this.workshopId,
  });

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isSubmitting = false;

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    context.read<ClientBloc>().add(
          AddClientEvent(
            workshopId: widget.workshopId,
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            address: _addressController.text,
            segment: '', // Empty string instead of _selectedSegment
          ),
        );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj Klienta'),
      ),
      body: BlocListener<ClientBloc, ClientState>(
        listener: (context, state) {
          if (state is ClientError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            setState(() => _isSubmitting = false);
          } else if (state is ClientOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.read<ClientBloc>().add(LoadClientsEvent(
              workshopId: widget.workshopId,
            ));
            Navigator.of(context).pop(true);
          } else if (state is ClientUnauthenticated) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: AddClientFormWidget(
            formKey: _formKey,
            firstNameController: _firstNameController,
            lastNameController: _lastNameController,
            emailController: _emailController,
            phoneController: _phoneController,
            addressController: _addressController,
            onSubmit: _submitForm,
            isSubmitting: _isSubmitting,
          ),
        ),
      ),
    );
  }
}
