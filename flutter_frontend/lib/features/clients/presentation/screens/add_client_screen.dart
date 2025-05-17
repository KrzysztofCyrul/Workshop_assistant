import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/features/clients/presentation/bloc/client_bloc.dart';
import 'package:flutter_frontend/features/clients/presentation/widgets/add_client_form_widget.dart';
import 'package:flutter_frontend/core/widgets/custom_app_bar.dart';

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
    return Scaffold(      appBar: CustomAppBar(
        title: 'Dodaj Klienta',
        feature: 'clients',
      ),
      body: BlocListener<ClientBloc, ClientState>(
        listener: (context, state) {
          if (state is ClientError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            setState(() => _isSubmitting = false);          } else if (state is ClientOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            
            // Po pomyślnym dodaniu klienta, wczytaj listę klientów
            context.read<ClientBloc>().add(LoadClientsEvent(
              workshopId: widget.workshopId,
            ));
            
            // Ustaw flagę, żeby wiedzieć, że czekamy na załadowanie clienta
            setState(() => _isSubmitting = true);
            // Nie zamykamy ekranu tutaj - zrobimy to po otrzymaniu ClientsLoaded
          } else if (state is ClientsLoaded && _isSubmitting) {
            // Ustaw flagę, żeby uniknąć wielokrotnej nawigacji
            setState(() => _isSubmitting = false);
            
            try {
              // Znajdź ostatnio dodanego klienta po jego imieniu i nazwisku
              final addedClient = state.clients.firstWhere(
                (client) => 
                  client.firstName == _firstNameController.text.trim() && 
                  client.lastName == _lastNameController.text.trim(),
              );
              
              // Zwróć klienta do poprzedniego ekranu
              Navigator.of(context).pop({'client': addedClient});
            } catch (e) {
              // W przypadku błędu zwróć true jako sygnał, że dodanie powiodło się
              Navigator.of(context).pop(true);
            }
          }else if (state is ClientUnauthenticated) {
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
