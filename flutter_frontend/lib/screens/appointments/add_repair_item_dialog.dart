import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/appointment_service.dart';
import '../../providers/auth_provider.dart';

class AddRepairItemDialog extends StatefulWidget {
  final String workshopId;
  final String appointmentId;

  const AddRepairItemDialog({
    Key? key,
    required this.workshopId,
    required this.appointmentId,
  }) : super(key: key);

  @override
  _AddRepairItemDialogState createState() => _AddRepairItemDialogState();
}

class _AddRepairItemDialogState extends State<AddRepairItemDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _description;
  String _status = 'pending';
  int _order = 0;
  double? _cost;
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken!;

    try {
      await AppointmentService.createRepairItem(
        accessToken,
        widget.workshopId,
        widget.appointmentId,
        _description!,
        _status,
        _order,
        _cost ?? 0.0,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dodaj Element Naprawy'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Opis
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Opis'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Wprowadź opis' : null,
                      onSaved: (value) {
                        _description = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Status
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Status'),
                      value: _status,
                      items: const [
                        DropdownMenuItem(value: 'pending', child: Text('Do wykonania')),
                        DropdownMenuItem(value: 'in_progress', child: Text('W trakcie')),
                        DropdownMenuItem(value: 'completed', child: Text('Zakończone')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _status = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Priorytet (Order)
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Priorytet (Order)'),
                      initialValue: '0', // Domyślna wartość
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Wprowadź priorytet';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Wprowadź poprawną liczbę';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _order = int.parse(value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    // Koszt
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Koszt'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Wprowadź koszt';
                        }
                        if (double.tryParse(value.replaceAll(',', '.')) == null) {
                          return 'Wprowadź poprawną kwotę';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _cost = double.parse(value!.replaceAll(',', '.'));
                      },
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Anuluj'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Dodaj'),
        ),
      ],
    );
  }
}
