import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/features/clients/presentation/bloc/client_bloc.dart';
import 'package:flutter_frontend/core/widgets/custom_app_bar.dart';
import 'package:flutter_frontend/core/theme/app_theme.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/custom_text_field.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/details_card_widget.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/form_submit_button.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/loading_indicator.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/error_state_widget.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/client_profile_widget.dart';

class ClientEditScreen extends StatefulWidget {
  static const routeName = '/client-edit';

  final String clientId;
  final String workshopId;

  const ClientEditScreen({
    super.key,
    required this.clientId,
    required this.workshopId,
  });

  @override
  State<ClientEditScreen> createState() => _ClientEditScreenState();
}

class _ClientEditScreenState extends State<ClientEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _controllersInitialized = false;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _loadClientDetails();
  }

  void _loadClientDetails() {
    if (mounted) {
      context.read<ClientBloc>().add(LoadClientDetailsEvent(
        workshopId: widget.workshopId,
        clientId: widget.clientId,
      ));
    }
  }

  void _initializeControllers(ClientDetailsLoaded state) {
    if (_controllersInitialized) return;
    final client = state.client;
    _firstNameController = TextEditingController(text: client.firstName);
    _lastNameController = TextEditingController(text: client.lastName);
    _emailController = TextEditingController(text: client.email);
    _phoneController = TextEditingController(text: client.phone ?? '');
    _addressController = TextEditingController(text: client.address ?? '');
    _controllersInitialized = true;
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      context.read<ClientBloc>().add(UpdateClientEvent(
        workshopId: widget.workshopId,
        clientId: widget.clientId,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        segment: '', // Segment functionality commented out for now
      ));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getInitials(String firstName, String lastName) {
    String initials = '';
    if (firstName.isNotEmpty) {
      initials += firstName[0];
    }
    if (lastName.isNotEmpty) {
      initials += lastName[0];
    }
    return initials.isNotEmpty ? initials.toUpperCase() : '?';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edytuj Klienta',
        feature: 'clients',
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
            tooltip: 'Zapisz zmiany',
          ),
        ],
      ),
      body: BlocConsumer<ClientBloc, ClientState>(
        listener: (context, state) {
          if (state is ClientOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.read<ClientBloc>().add(LoadClientsEvent(
              workshopId: widget.workshopId,
            ));
            Navigator.of(context).pop(true);
          } else if (state is ClientError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ClientDetailsLoaded) {
            _initializeControllers(state);
          } else if (state is ClientUnauthenticated) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        },
        builder: (context, state) {
          if (state is ClientLoading) {
            return const LoadingIndicator();
          }
          if (state is ClientError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: _loadClientDetails,
            );
          }
          if (state is ClientDetailsLoaded) {
            _initializeControllers(state);
            return _buildBody(state);
          }
          return const Center(
            child: Text(
              'Nie znaleziono klienta',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(ClientDetailsLoaded state) {
    final client = state.client;
    final clientFeatureColor = AppTheme.getFeatureColor('clients');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client Profile Card
            ClientProfileWidget(
              firstName: client.firstName,
              lastName: client.lastName,
              phone: client.phone,
              email: client.email,
              address: client.address,
              initials: _getInitials(client.firstName, client.lastName),
            ),
            
            const SizedBox(height: 16.0),
            
            // Personal Information Section
            DetailsCardWidget(
              title: 'Dane osobowe',
              subtitle: 'Podstawowe informacje o kliencie',
              icon: Icons.person,
              iconBackgroundColor: clientFeatureColor.withValues(alpha: 0.1),
              iconColor: clientFeatureColor,
              initiallyExpanded: true,
              children: [
                CustomTextField(
                  controller: _firstNameController,
                  labelText: 'Imię',
                  prefixIcon: Icons.person_outline,
                  validator: (value) => value?.isEmpty ?? true ? 'Imię jest wymagane' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _lastNameController,
                  labelText: 'Nazwisko',
                  prefixIcon: Icons.person,
                  validator: (value) => value?.isEmpty ?? true ? 'Nazwisko jest wymagane' : null,
                ),
              ],
            ),
            
            const SizedBox(height: 16.0),
            
            // Contact Information Section
            DetailsCardWidget(
              title: 'Dane kontaktowe',
              subtitle: 'Email, telefon i adres',
              icon: Icons.contact_phone,
              iconBackgroundColor: Colors.blue.shade100,
              iconColor: Colors.blue.shade600,
              initiallyExpanded: true,
              children: [
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Email jest wymagany';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                      return 'Nieprawidłowy format email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Telefon',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  hintText: 'Opcjonalnie - numer telefonu',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _addressController,
                  labelText: 'Adres',
                  prefixIcon: Icons.home,
                  maxLines: 2,
                  hintText: 'Opcjonalnie - adres zamieszkania',
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Save Button
            FormSubmitButton(
              label: 'Zapisz zmiany',
              onPressed: _saveForm,
              isSubmitting: _isLoading,
              backgroundColor: clientFeatureColor,
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
      _firstNameController.dispose();
      _lastNameController.dispose();
      _emailController.dispose();
      _phoneController.dispose();
      _addressController.dispose();
    }
    super.dispose();
  }
}
