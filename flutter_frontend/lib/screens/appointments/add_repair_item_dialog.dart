import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/appointment_service.dart';
import '../../providers/auth_provider.dart';

class AddMultipleRepairItemsDialog extends StatefulWidget {
  final String workshopId;
  final String appointmentId;

  const AddMultipleRepairItemsDialog({
    super.key,
    required this.workshopId,
    required this.appointmentId,
  });

  @override
  _AddMultipleRepairItemsDialogState createState() =>
      _AddMultipleRepairItemsDialogState();
}

class _AddMultipleRepairItemsDialogState
    extends State<AddMultipleRepairItemsDialog> {
  final List<Map<String, dynamic>> _repairItems = [];
  bool _isLoading = false;

  void _addRepairItem() {
    setState(() {
      _repairItems.add({
        'description': '',
        'status': 'pending',
        'priority': false, // Default priority off
        'cost': 0.0,
      });
    });
  }

  void _removeRepairItem(int index) {
    setState(() {
      _repairItems.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (_repairItems.any((item) => item['description'].isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uzupełnij opisy wszystkich elementów')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken!;

    try {
      for (final item in _repairItems) {
        await AppointmentService.createRepairItem(
          accessToken,
          widget.workshopId,
          widget.appointmentId,
          item['description'],
          item['status'],
          item['priority'] ? 1 : 0, // Map priority to order
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dodaj Elementy Naprawy'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _repairItems.length + 1,
                itemBuilder: (context, index) {
                  if (index == _repairItems.length) {
                    return TextButton.icon(
                      onPressed: _addRepairItem,
                      icon: const Icon(Icons.add),
                      label: const Text('Dodaj Element'),
                    );
                  }
                  final item = _repairItems[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          TextFormField(
                            initialValue: item['description'],
                            decoration: const InputDecoration(labelText: 'Opis'),
                            onChanged: (value) {
                              item['description'] = value;
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DropdownButton<String>(
                                value: item['status'],
                                items: const [
                                  DropdownMenuItem(
                                      value: 'pending', child: Text('Do wykonania')),
                                  DropdownMenuItem(
                                      value: 'in_progress', child: Text('W trakcie')),
                                  DropdownMenuItem(
                                      value: 'completed', child: Text('Zakończone')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    item['status'] = value!;
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  item['priority']
                                      ? Icons.star
                                      : Icons.star_border,
                                  color:
                                      item['priority'] ? Colors.amber : Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    item['priority'] = !item['priority'];
                                  });
                                },
                                tooltip: 'Priorytet',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: item['cost'].toStringAsFixed(2),
                            decoration: const InputDecoration(labelText: 'Koszt'),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            onChanged: (value) {
                              item['cost'] = double.tryParse(value) ?? 0.0;
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _removeRepairItem(index),
                              child: const Text('Usuń',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Anuluj'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Zatwierdź'),
        ),
      ],
    );
  }
}
