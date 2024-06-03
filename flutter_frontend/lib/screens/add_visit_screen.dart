// lib/screens/add_visit_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../providers/visit_provider.dart';
import '../models/visit.dart';
import 'package:intl/intl.dart';
import 'add_car_screen.dart';

class AddVisitScreen extends StatefulWidget {
  final Visit? visit;

  AddVisitScreen({this.visit});

  @override
  _AddVisitScreenState createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _carController = TextEditingController();
  Car? _selectedCar;
  Mechanic? _selectedMechanic;

  @override
  void initState() {
    super.initState();
    if (widget.visit != null) {
      _nameController.text = widget.visit!.name;
      _descriptionController.text = widget.visit!.description;
      _dateController.text = widget.visit!.date;
      _selectedCar = widget.visit!.cars.isNotEmpty ? widget.visit!.cars.first : null;
      _selectedMechanic = widget.visit!.mechanics.isNotEmpty ? widget.visit!.mechanics.first : null;
      if (_selectedCar != null) {
        _carController.text = '${_selectedCar!.brand} ${_selectedCar!.model} (${_selectedCar!.year}) - ${_selectedCar!.licensePlate}';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final visitProvider = Provider.of<VisitProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.visit == null ? 'Add Visit' : 'Edit Visit'),
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
              Row(
                children: [
                  Expanded(
                    child: TypeAheadFormField<Car>(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _carController,
                        decoration: InputDecoration(labelText: 'Select Car'),
                      ),
                      suggestionsCallback: (pattern) {
                        return visitProvider.cars.where((car) =>
                        car.brand.toLowerCase().contains(pattern.toLowerCase()) ||
                            car.model.toLowerCase().contains(pattern.toLowerCase()) ||
                            car.year.toString().contains(pattern) ||
                            car.licensePlate.toLowerCase().contains(pattern.toLowerCase()));
                      },
                      itemBuilder: (context, Car car) {
                        return ListTile(
                          title: Text('${car.brand} ${car.model} (${car.year}) - ${car.licensePlate}'),
                        );
                      },
                      onSuggestionSelected: (Car car) {
                        setState(() {
                          _selectedCar = car;
                          _carController.text = '${car.brand} ${car.model} (${car.year}) - ${car.licensePlate}';
                        });
                      },
                      validator: (value) => _selectedCar == null ? 'Please select a car' : null,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddCarScreen()),
                      );
                      visitProvider.fetchVisits(); // refresh the cars list after adding a new car
                    },
                  ),
                ],
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
                      if (widget.visit == null) {
                        await visitProvider.addVisit(
                          _nameController.text,
                          _descriptionController.text,
                          _dateController.text,
                          'pending',
                          _selectedCar!,
                          _selectedMechanic!,
                        );
                      } else {
                        await visitProvider.editVisit(
                          widget.visit!.id,
                          _nameController.text,
                          _descriptionController.text,
                          _dateController.text,
                          widget.visit!.status,
                          _selectedCar!,
                          _selectedMechanic!,
                        );
                      }
                      await visitProvider.fetchVisits();
                      Navigator.pop(context);
                    } catch (e) {
                      print('Exception: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save visit')),
                      );
                    }
                  }
                },
                child: Text(widget.visit == null ? 'Add Visit' : 'Save Visit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
