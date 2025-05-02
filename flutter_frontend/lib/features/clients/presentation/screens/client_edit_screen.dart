import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/features/clients/domain/entities/client.dart';
import 'package:flutter_frontend/features/clients/presentation/bloc/client_bloc.dart';
import 'package:flutter_frontend/features/clients/presentation/widgets/client_form_widget.dart';

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
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  String? _selectedSegment;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadClientDetails();
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  void _loadClientDetails() {
    context.read<ClientBloc>().add(LoadClientDetailsEvent(
          workshopId: widget.workshopId,
          clientId: widget.clientId,
        ));
  }

  void _updateControllersWithClient(Client client) {
    _firstNameController.text = client.firstName;
    _lastNameController.text = client.lastName;
    _emailController.text = client.email;
    _phoneController.text = client.phone ?? '';
    _addressController.text = client.address ?? '';
    setState(() {
      _selectedSegment = client.segment;
    });
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    context.read<ClientBloc>().add(UpdateClientEvent(
          workshopId: widget.workshopId,
          clientId: widget.clientId,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          address: _addressController.text,
          segment: _selectedSegment ?? '',
        ));
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
        title: const Text('Edytuj Klienta'),
      ),
      body: BlocConsumer<ClientBloc, ClientState>(
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
            // Dodajemy event ładowania klientów przed zamknięciem ekranu
            context.read<ClientBloc>().add(LoadClientsEvent(
              workshopId: widget.workshopId,
            ));
            Navigator.of(context).pop(true); // Dodajemy true jako rezultat
          } else if (state is ClientDetailsLoaded) {
            _updateControllersWithClient(state.client);
          } else if (state is ClientUnauthenticated) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        },
        builder: (context, state) {
          if (state is ClientLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ClientFormWidget(
              formKey: _formKey,
              firstNameController: _firstNameController,
              lastNameController: _lastNameController,
              emailController: _emailController,
              phoneController: _phoneController,
              addressController: _addressController,
              // selectedSegment: _selectedSegment,
              // onSegmentChanged: (value) => setState(() => _selectedSegment = value),
              isSubmitting: _isSubmitting,
              onSubmit: _submitForm,
            ),
          );
        },
      ),
    );
  }
}
