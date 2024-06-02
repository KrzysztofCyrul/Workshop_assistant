// lib/screens/add_visit_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/visit_provider.dart';
import '../models/visit.dart';
import 'package:intl/intl.dart';

class AddVisitScreen extends StatefulWidget {
  @override
  _AddVisitScreenState createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  Car? _selectedCar;
  Mechanic? _selectedMechanic;

  @override
  Widget build(BuildContext context) {
    final visitProvider = Provider.of<VisitProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Visit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Date'),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                    setState(() {
                      _dateController.text = formattedDate;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<Car>(
                value: _selectedCar,
                items: visitProvider.cars.map((car) {
                  return DropdownMenuItem<Car>(
                    value: car,
                    child: Text('${car.brand} ${car.model} (${car.year})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCar = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Select Car'),
                validator: (value) => value == null ? 'Please select a car' : null,
              ),
              DropdownButtonFormField<Mechanic>(
                value: _selectedMechanic,
                items: visitProvider.mechanics.map((mechanic) {
                  return DropdownMenuItem<Mechanic>(
                    value: mechanic,
                    child: Text('${mechanic.firstName} ${mechanic.lastName}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMechanic = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Select Mechanic'),
                validator: (value) => value == null ? 'Please select a mechanic' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await visitProvider.addVisit(
                        _nameController.text,
                        _descriptionController.text,
                        _dateController.text,
                        'pending', // Ustawienie domyślnego statusu na 'pending'
                        _selectedCar!,
                        _selectedMechanic!,
                      );
                      await visitProvider.fetchVisits(); // Odśwież listę wizyt
                      Navigator.pop(context);
                    } catch (e) {
                      print('Exception: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add visit')),
                      );
                    }
                  }
                },
                child: Text('Add Visit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
