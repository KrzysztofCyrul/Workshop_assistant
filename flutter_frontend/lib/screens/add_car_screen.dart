// lib/screens/add_car_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/visit_provider.dart';
import '../models/visit.dart';

class AddCarScreen extends StatefulWidget {
  @override
  _AddCarScreenState createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _vinController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final visitProvider = Provider.of<VisitProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Car'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _brandController,
                  decoration: InputDecoration(labelText: 'Brand'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a brand';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _modelController,
                  decoration: InputDecoration(labelText: 'Model'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a model';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _yearController,
                  decoration: InputDecoration(labelText: 'Year'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a year';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _vinController,
                  decoration: InputDecoration(labelText: 'VIN'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a VIN';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _licensePlateController,
                  decoration: InputDecoration(labelText: 'License Plate'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a license plate';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _clientNameController,
                  decoration: InputDecoration(labelText: 'Client Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the client name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _clientPhoneController,
                  decoration: InputDecoration(labelText: 'Client Phone'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the client phone';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final newCar = Car(
                          id: DateTime.now().millisecondsSinceEpoch, // Example ID generation
                          brand: _brandController.text,
                          model: _modelController.text,
                          year: int.parse(_yearController.text),
                          vin: _vinController.text,
                          licensePlate: _licensePlateController.text,
                          client: Client(
                            id: DateTime.now().millisecondsSinceEpoch, // Example ID generation
                            firstName: _clientNameController.text,
                            email: '',
                            phone: _clientPhoneController.text,
                          ),
                          company: null,
                        );
                        await visitProvider.addCar(newCar);
                        Navigator.pop(context);
                      } catch (e) {
                        print('Exception: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add car')),
                        );
                      }
                    }
                  },
                  child: Text('Add Car'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
