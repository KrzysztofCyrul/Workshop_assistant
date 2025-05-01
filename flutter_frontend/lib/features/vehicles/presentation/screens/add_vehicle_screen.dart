// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_frontend/features/vehicles/presentation/bloc/vehicle_bloc.dart';
// import 'package:flutter_frontend/features/clients/presentation/bloc/client_bloc.dart';
// import 'package:flutter_frontend/features/auth/presentation/bloc/auth_bloc.dart';
// import 'package:flutter_frontend/features/clients/domain/entities/client.dart';
// import 'package:flutter_frontend/widgets/client_search_widget.dart';

// class AddVehicleScreen extends StatefulWidget {
//   static const routeName = '/add-vehicle';

//   final String workshopId;
//   final Client? selectedClient;

//   const AddVehicleScreen({
//     super.key,
//     required this.workshopId,
//     this.selectedClient,
//   });

//   @override
//   _AddVehicleScreenState createState() => _AddVehicleScreenState();
// }

// class _AddVehicleScreenState extends State<AddVehicleScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _makeController = TextEditingController();
//   final _modelController = TextEditingController();
//   final _yearController = TextEditingController();
//   final _vinController = TextEditingController();
//   final _licensePlateController = TextEditingController();
//   final _mileageController = TextEditingController();

//   String? _selectedClientId;

//   @override
//   void initState() {
//     super.initState();
//     _selectedClientId = widget.selectedClient?.id;
//     _loadClients();
//   }

//   void _loadClients() {
//     context.read<ClientBloc>().add(LoadClientsEvent(workshopId: widget.workshopId));
//   }

//   void _submitForm() {
//     if (!_formKey.currentState!.validate()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Proszę poprawić błędy w formularzu')),
//       );
//       return;
//     }

//     if (_selectedClientId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Wybierz klienta')),
//       );
//       return;
//     }

//     context.read<VehicleBloc>().add(AddVehicleEvent(
//       workshopId: widget.workshopId,
//       clientId: _selectedClientId!,
//       make: _makeController.text,
//       model: _modelController.text,
//       year: int.tryParse(_yearController.text) ?? 0,
//       vin: _vinController.text,
//       licensePlate: _licensePlateController.text,
//       mileage: int.tryParse(_mileageController.text) ?? 0,
//     ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Dodaj Pojazd'),
//       ),
//       body: BlocListener<VehicleBloc, VehicleState>(
//         listener: (context, state) {
//           if (state is VehicleOperationSuccess) {
//             Navigator.of(context).pop(true);
//           } else if (state is VehicleError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.message)),
//             );
//           }
//         },
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 BlocBuilder<ClientBloc, ClientState>(
//                   builder: (context, state) {
//                     return ClientSearchWidget(
//                       selectedClient: widget.selectedClient,
//                       clients: state is ClientsLoaded ? state.clients : [],
//                       onChanged: (client) {
//                         setState(() {
//                           _selectedClientId = client?.id;
//                         });
//                       },
//                       validator: (client) => client == null ? 'Wybierz klienta' : null,
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 _buildTextField(_makeController, 'Marka', required: true),
//                 const SizedBox(height: 16),
//                 _buildTextField(_modelController, 'Model', required: true),
//                 const SizedBox(height: 16),
//                 _buildTextField(_yearController, 'Rok produkcji', keyboardType: TextInputType.number),
//                 const SizedBox(height: 16),
//                 _buildTextField(_vinController, 'VIN'),
//                 const SizedBox(height: 16),
//                 _buildTextField(_licensePlateController, 'Numer rejestracyjny', required: true),
//                 const SizedBox(height: 16),
//                 _buildTextField(_mileageController, 'Przebieg (km)', keyboardType: TextInputType.number),
//                 const SizedBox(height: 20),
//                 BlocBuilder<VehicleBloc, VehicleState>(
//                   builder: (context, state) {
//                     return SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: state is VehicleLoading ? null : _submitForm,
//                         child: state is VehicleLoading
//                             ? const CircularProgressIndicator()
//                             : const Text('Dodaj Pojazd'),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(
//     TextEditingController controller,
//     String labelText, {
//     bool required = false,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: labelText,
//         border: const OutlineInputBorder(),
//       ),
//       keyboardType: keyboardType,
//       validator: required
//           ? (value) => value == null || value.isEmpty ? '$labelText jest wymagany' : null
//           : null,
//     );
//   }

//   @override
//   void dispose() {
//     _makeController.dispose();
//     _modelController.dispose();
//     _yearController.dispose();
//     _vinController.dispose();
//     _licensePlateController.dispose();
//     _mileageController.dispose();
//     super.dispose();
//   }
// }