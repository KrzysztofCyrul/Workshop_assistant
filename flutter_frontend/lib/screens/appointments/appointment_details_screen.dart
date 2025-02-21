import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/appointment.dart';
import '../../models/repair_item.dart';
import '../../models/part.dart';
import '../../services/appointment_service.dart';
import '../../providers/auth_provider.dart';
import '../service_records/service_history_screen.dart';
import 'add_repair_item_dialog.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  static const routeName = '/appointment-details';

  final String workshopId;
  final String appointmentId;

  const AppointmentDetailsScreen({
    Key? key,
    required this.workshopId,
    required this.appointmentId,
  }) : super(key: key);

  @override
  _AppointmentDetailsScreenState createState() => _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  late Future<Appointment> _appointmentFuture;
  Appointment? _currentAppointment; // Przechowujemy załadowaną wizytę

  final List<Part> parts = [];
  final List<RepairItem> repairItems = [];

  List<String> partsSuggestions = []; // Globalna zmienna do przechowywania części
  bool isSuggestionsLoaded = false; // Flaga wczytania danych

  final TextEditingController partNameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController partCostController = TextEditingController();
  final TextEditingController serviceCostController = TextEditingController();

  final TextEditingController repairDescriptionController = TextEditingController();
  final TextEditingController repairCostController = TextEditingController();
  final TextEditingController estimatedDurationController = TextEditingController();

  double get totalPartCost => parts.fold(0, (sum, item) => sum + (item.costPart * item.quantity));
  double get totalServiceCost => repairItems.fold(0, (sum, item) => sum + item.cost);

  @override
  void initState() {
    super.initState();
    _appointmentFuture = _fetchAppointmentDetails();
    partCostController.text = '0';
    repairCostController.text = '0';
    serviceCostController.text = '0';
  }
  

  Future<Appointment> _fetchAppointmentDetails() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken!;

    try {
      final appointment = await AppointmentService.getAppointmentDetails(
        accessToken,
        widget.workshopId,
        widget.appointmentId,
      );
      setState(() {
        _currentAppointment = appointment;
        repairItems.clear();
        repairItems.addAll(appointment.repairItems);

        parts.clear();
        parts.addAll(appointment.parts);
      });
      return appointment;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas pobierania szczegółów zlecenia: $e')),
      );
      throw Exception('Błąd podczas pobierania szczegółów zlecenia.');
    }
  }


  double _calculateDiscountedCost(double originalCost, String? segment) {
    double discountPercentage;
    switch (segment) {
      case 'A':
        discountPercentage = 0.10;
        break;
      case 'B':
        discountPercentage = 0.06;
        break;
      case 'C':
        discountPercentage = 0.03;
        break;
      case 'D':
      default:
        discountPercentage = 0.0;
        break;
    }
    return originalCost * (1 - discountPercentage);
  }

  Future<void> _navigateToAddRepairItem() async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AddMultipleRepairItemsDialog(
          appointmentId: widget.appointmentId,
          workshopId: widget.workshopId,
        );
      },
    );

    if (result == true) {
      // Jeśli element został dodany, odśwież szczegóły zlecenia
      setState(() {
        _appointmentFuture = _fetchAppointmentDetails();
      });
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Do wykonania';
      case 'in_progress':
        return 'W trakcie';
      case 'completed':
        return 'Zakończone';
      case 'canceled':
        return 'Anulowane';
      default:
        return status;
    }
  }

  String _formatDuration(Duration duration) {
    double hours = duration.inMinutes / 60;
    return hours.toStringAsFixed(2).replaceAll('.', ',');
  }

  double _calculateTotalCost(List<RepairItem> repairItems) {
    return repairItems.fold(0.0, (sum, item) => sum + item.cost);
  }

  Duration _calculateTotalEstimatedDuration(List<RepairItem> repairItems) {
    return repairItems.fold(Duration.zero, (sum, item) => sum + (item.estimatedDuration ?? Duration.zero));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            ),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

void _addPart() async {
  // Sprawdzenie, czy wszystkie wymagane pola zostały wypełnione
  if (partNameController.text.isEmpty || 
      quantityController.text.isEmpty || 
      partCostController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wypełnij wszystkie pola')),
    );
    return;
  }

  // Pobranie dostępu do tokenu i przygotowanie danych nowej części
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final accessToken = authProvider.accessToken!;

  final newPart = Part(
    id: UniqueKey().toString(),
    appointmentId: widget.appointmentId,
    name: partNameController.text.trim(),
    description: '', // Pole 'description', można rozszerzyć formularz
    quantity: int.parse(quantityController.text),
    costPart: double.parse(partCostController.text),
    costService: double.parse(serviceCostController.text),
  );

  try {
    // Wywołanie API w celu zapisania nowej części
    await AppointmentService.createPart(
      accessToken,
      widget.workshopId,
      widget.appointmentId,
      newPart.name,
      newPart.description,
      newPart.quantity,
      newPart.costPart,
      newPart.costService,
    );

    // Aktualizacja lokalnej listy części i podpowiedzi
    setState(() {
      parts.add(newPart); // Dodanie nowej części do listy wyświetlanej na ekranie
      if (!partsSuggestions.contains(newPart.name)) {
        partsSuggestions.add(newPart.name); // Dodanie nowej części do podpowiedzi
      }
    });

    // Czyszczenie pól formularza po dodaniu
    partNameController.clear();
    quantityController.clear();
    partCostController.clear();
    serviceCostController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Część została dodana')),
    );
  } catch (e) {
    // Obsługa błędów podczas dodawania części
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Błąd podczas dodawania części')),
    );
    print('Error adding part: $e');
  }
}

  void _editPart(int index) async {
    final part = parts[index];
    partNameController.text = part.name;
    quantityController.text = part.quantity.toString();
    partCostController.text = part.costPart.toString();
    serviceCostController.text = part.costService.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edytuj część'),
          content: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: partNameController,
                  decoration: const InputDecoration(labelText: 'Część'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Ilość'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: partCostController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Cena części'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: serviceCostController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Cena usługi'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final accessToken = authProvider.accessToken!;

                try {
                  // Aktualizuj część w backendzie
                  await AppointmentService.updatePart(
                    accessToken,
                    widget.workshopId,
                    widget.appointmentId,
                    part.id, // Użyj ID części
                    name: partNameController.text,
                    description: '',
                    quantity: int.parse(quantityController.text),
                    costPart: double.parse(partCostController.text),
                    costService: double.parse(serviceCostController.text),
                  );

                  // Aktualizuj lokalną listę
                  setState(() {
                    parts[index] = part.copyWith(
                      name: partNameController.text,
                      quantity: int.parse(quantityController.text),
                      costPart: double.parse(partCostController.text),
                      costService: double.parse(serviceCostController.text),
                    );
                  });
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Błąd podczas aktualizacji części')),
                  );
                }
              },
              child: const Text('Zapisz'),
            ),
          ],
        );
      },
    );
  }

  void _editPartValue(int index, String field, dynamic newValue) async {
    final part = parts[index];
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken!;

    // Aktualizacja pola lokalnie
    Part updatedPart;
    switch (field) {
      case 'name':
        updatedPart = part.copyWith(name: newValue);
        break;
      case 'quantity':
        updatedPart = part.copyWith(quantity: newValue);
        break;
      case 'costPart':
        updatedPart = part.copyWith(costPart: newValue);
        break;
      case 'costService':
        updatedPart = part.copyWith(costService: newValue);
        break;
      default:
        return;
    }

    setState(() {
      parts[index] = updatedPart;
    });

    // Aktualizacja w backendzie
    try {
      await AppointmentService.updatePart(
        accessToken,
        widget.workshopId,
        widget.appointmentId,
        part.id,
        name: updatedPart.name,
        description: part.description,
        quantity: updatedPart.quantity,
        costPart: updatedPart.costPart,
        costService: updatedPart.costService,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Zaktualizowano pole: $field')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas aktualizacji pola: $field - $e')),
      );

      // Przywracanie starej wartości w przypadku błędu
      setState(() {
        parts[index] = part;
      });
    }
  }

Future<void> _removePart(int index) async {
  final part = parts[index];
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final accessToken = authProvider.accessToken!;

  try {
    await AppointmentService.deletePart(
      accessToken,
      widget.workshopId,
      widget.appointmentId,
      part.id,
    );

    setState(() {
      parts.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Część została usunięta')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Błąd podczas usuwania części')),
    );
  }
}

  Widget _buildPartsTable() {
  return DataTable(
    columnSpacing: MediaQuery.of(context).size.width * 0.02,
    headingRowColor: WidgetStateColor.resolveWith((states) => Colors.green.shade100),
    dataRowColor: WidgetStateColor.resolveWith((states) {
      return states.contains(WidgetState.selected) ? Colors.green.shade50 : Colors.grey.shade100;
    }),
    columns: const [
      DataColumn(
        label: Center(
          child: Text(
            'Część',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      DataColumn(
        label: Center(
          child: Text(
            'Ilość',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      DataColumn(
        label: Center(
          child: Text(
            'Części',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      DataColumn(
        label: Center(
          child: Text(
            'Suma',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      DataColumn(
        label: Center(
          child: Text(
            'Usługa',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      DataColumn(
        label: Center(
          child: Text(
            'Akcje',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ],
    rows: parts.asMap().entries.map((entry) {
      final index = entry.key;
      final part = entry.value;

      return DataRow(
        cells: [
          DataCell(
            Center(
              child: TextFormField(
                initialValue: part.name,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero, // Usunięcie domyślnego paddingu
                ),
                textAlign: TextAlign.center, // Wyśrodkowanie tekstu
                onFieldSubmitted: (newValue) {
                  _editPartValue(index, 'name', newValue);
                },
              ),
            ),
          ),
          DataCell(
            Center(
              child: TextFormField(
                initialValue: part.quantity.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero, // Usunięcie domyślnego paddingu
                ),
                textAlign: TextAlign.center, // Wyśrodkowanie tekstu
                onFieldSubmitted: (newValue) {
                  _editPartValue(index, 'quantity', int.tryParse(newValue) ?? part.quantity);
                },
              ),
            ),
          ),
          DataCell(
            Center(
              child: TextFormField(
                initialValue: part.costPart.toStringAsFixed(2),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero, // Usunięcie domyślnego paddingu
                ),
                textAlign: TextAlign.center, // Wyśrodkowanie tekstu
                onFieldSubmitted: (newValue) {
                  _editPartValue(index, 'costPart', double.tryParse(newValue) ?? part.costPart);
                },
              ),
            ),
          ),
          DataCell(
            Center(
              child: Text(
                (part.costPart * part.quantity).toStringAsFixed(2),
                textAlign: TextAlign.center, // Wyśrodkowanie tekstu
              ),
            ),
          ),
          DataCell(
            Center(
              child: TextFormField(
                initialValue: part.costService.toStringAsFixed(2),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero, // Usunięcie domyślnego paddingu
                ),
                textAlign: TextAlign.center, // Wyśrodkowanie tekstu
                onFieldSubmitted: (newValue) {
                  _editPartValue(index, 'costService', double.tryParse(newValue) ?? part.costService);
                },
              ),
            ),
          ),
          DataCell(
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeletePartItem(index),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }).toList(),
  );
}

void _confirmDeletePartItem(int index) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Potwierdzenie usunięcia'),
        content: Text('Czy na pewno chcesz usunąć część "${parts[index].name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _removePart(index);
              Navigator.of(context).pop();
              setState(() {
                _appointmentFuture = _fetchAppointmentDetails();
              });
            },
            child: const Text('Usuń'),
          ),
        ],
      );
    },
  );
}

  void _addRepairItem() async {
    if (repairDescriptionController.text.isEmpty || repairCostController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wypełnij wszystkie pola')),
      );
      return;
    }

    // Sprawdź poprawność danych wejściowych
    final double? cost = double.tryParse(repairCostController.text);

    if (cost == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wprowadź poprawne dane')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken!;

    // Przygotowanie nowego elementu naprawy
    final newRepairItem = RepairItem(
      id: UniqueKey().toString(),
      appointmentId: widget.appointmentId,
      description: repairDescriptionController.text,
      isCompleted: false,
      status: 'pending',
      estimatedDuration: null,
      actualDuration: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      cost: cost,
      order: repairItems.length + 1,
    );

    try {
      // Wywołanie metody serwisowej do zapisania elementu w backendzie
      await AppointmentService.createRepairItem(
        accessToken,
        widget.workshopId,
        widget.appointmentId,
        newRepairItem.description ?? '',
        newRepairItem.status,
        newRepairItem.order,
        newRepairItem.cost,
      );

      // Aktualizacja lokalnej listy
      setState(() {
        repairItems.add(newRepairItem);
      });

      // Czyszczenie pól
      repairDescriptionController.clear();
      repairCostController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błąd podczas dodawania elementu naprawy')),
      );
    }
  }

  void _editRepairItemValue(int index, String field, dynamic value) async {
    final item = repairItems[index];

    final updatedItem = item.copyWith(
      description: field == 'description' ? value : item.description,
      cost: field == 'cost' ? value : item.cost,
      estimatedDuration: field == 'estimatedDuration' ? value : item.estimatedDuration,
    );

    setState(() {
      repairItems[index] = updatedItem;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = authProvider.accessToken!;

      await AppointmentService.updateRepairItem(
        accessToken,
        widget.workshopId,
        widget.appointmentId,
        item.id,
        description: updatedItem.description ?? '',
        status: updatedItem.status,
        cost: updatedItem.cost,
        order: updatedItem.order,
        estimatedDuration: updatedItem.estimatedDuration,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błąd podczas aktualizacji elementu naprawy')),
      );
    }
  }

  Widget _buildRepairItemsTable() {
  return DataTable(
    columnSpacing: MediaQuery.of(context).size.width * 0.02, // Dostosowanie odstępów
    headingRowColor: WidgetStateColor.resolveWith((states) => Colors.blue.shade100),
    dataRowColor: WidgetStateColor.resolveWith((states) {
      return states.contains(WidgetState.selected) ? Colors.blue.shade50 : Colors.grey.shade100;
    }),
    columns: const [
      DataColumn(
        label: Expanded(
          child: Center(
            child: Text(
              'Opis',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Center(
            child: Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Center(
            child: Text(
              'Koszt',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Center(
            child: Text(
              'Czas',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Center(
            child: Text(
              'Akcje',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ],
    rows: repairItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return DataRow(
        cells: [
          DataCell(
            TextFormField(
              initialValue: item.description ?? 'Brak opisu',
              decoration: const InputDecoration(border: InputBorder.none),
              onFieldSubmitted: (newValue) {
                _editRepairItemValue(index, 'description', newValue);
              },
            ),
          ),
          DataCell(
            GestureDetector(
              onTap: () => _showStatusChangeDialog(item),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getStatusIcon(item.status),
                    color: _getStatusColor(item.status),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          DataCell(
            Center(
              child: TextFormField(
                initialValue: item.cost.toStringAsFixed(2),
                decoration: const InputDecoration(border: InputBorder.none),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center, // Wyśrodkowanie tekstu
                onFieldSubmitted: (newValue) {
                  _editRepairItemValue(index, 'cost', double.parse(newValue));
                },
              ),
            ),
          ),
          DataCell(
            Center(
              child: Text(
                item.estimatedDuration != null ? _formatDuration(item.estimatedDuration!) : 'Brak',
                textAlign: TextAlign.center, // Wyśrodkowanie tekstu
              ),
            ),
          ),
          DataCell(
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteRepairItem(index),
                ),
              ],
            ),
          ),
        ],
      );
    }).toList(),
  );
}

 Future<void> _loadPartsSuggestions() async {
  if (!isSuggestionsLoaded) {
    try {
      // Wczytanie danych z pliku JSON
      final String response = await rootBundle.loadString('assets/parts.json');
      final List<dynamic> data = json.decode(response);
      partsSuggestions = List<String>.from(data);
      isSuggestionsLoaded = true; // Ustawienie flagi na true
    } catch (e) {
      print('Błąd podczas ładowania danych: $e');
    }
  }
}

Widget _buildAddPartForm() {
  // Ładowanie danych przy pierwszym uruchomieniu
  if (!isSuggestionsLoaded) {
    _loadPartsSuggestions();
  }

  return Row(
    children: [
      Expanded(
        flex: 3,
        child: Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return partsSuggestions.where((String part) {
              return part
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            partNameController.text = selection;
          },
          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: const InputDecoration(
                labelText: 'Część',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              ),
              onChanged: (value) {
                partNameController.text = value; // Synchronizuj wartość z kontrolerem
              },
            );
          },
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        flex: 2,
        child: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Ilość',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        flex: 2,
        child: TextField(
          controller: partCostController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Cena części',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        flex: 2,
        child: TextField(
          controller: serviceCostController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Cena usługi',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          ),
        ),
      ),
      const SizedBox(width: 8),
      IconButton(
        icon: const Icon(Icons.add, color: Colors.green),
        onPressed: _addPart, // Wywołanie funkcji dodania części
        tooltip: 'Dodaj część',
      ),
    ],
  );
}
  Widget _buildAddRepairItemForm() {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: TextField(
            controller: repairDescriptionController,
            decoration: const InputDecoration(
              labelText: 'Opis',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: TextField(
            controller: repairCostController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Koszt',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.green),
          onPressed: _addRepairItem,
          tooltip: 'Dodaj element naprawy',
        ),
      ],
    );
  }

  void _showStatusChangeDialog(RepairItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Zmień status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.pending, color: _getStatusColor('pending')),
                title: const Text('Do wykonania'),
                onTap: () => _updateRepairItemStatus(item, 'pending'),
              ),
              ListTile(
                leading: Icon(Icons.timelapse, color: _getStatusColor('in_progress')),
                title: const Text('W trakcie'),
                onTap: () => _updateRepairItemStatus(item, 'in_progress'),
              ),
              ListTile(
                leading: Icon(Icons.check_circle, color: _getStatusColor('completed')),
                title: const Text('Zakończone'),
                onTap: () => _updateRepairItemStatus(item, 'completed'),
              ),
              ListTile(
                leading: Icon(Icons.cancel, color: _getStatusColor('canceled')),
                title: const Text('Anulowane'),
                onTap: () => _updateRepairItemStatus(item, 'canceled'),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'in_progress':
        return Icons.timelapse;
      case 'completed':
        return Icons.check_circle;
      case 'canceled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _updateRepairItemStatus(RepairItem item, String newStatus) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken!;
    Navigator.pop(context); // Zamknięcie dialogu
    try {
      await AppointmentService.updateRepairItemStatus(
        accessToken,
        widget.workshopId,
        widget.appointmentId,
        item.id,
        newStatus == 'completed',
      );

      setState(() {
        item.status = newStatus;
        item.isCompleted = (newStatus == 'completed');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status elementu "${item.description}" został zaktualizowany.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas zmiany statusu: $e')),
      );
    }
  }

// Funkcja do potwierdzenia usunięcia
  void _confirmDeleteRepairItem(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Potwierdzenie usunięcia'),
          content: const Text('Czy na pewno chcesz usunąć ten element naprawy?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Zamknij dialog
              child: const Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: () {
                _removeRepairItem(index); // Usuń element
                Navigator.of(context).pop(); // Zamknij dialog
              },
              child: const Text('Usuń'),
            ),
          ],
        );
      },
    );
  }


  void _removeRepairItem(int index) async {
    final item = repairItems[index];
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken!;

    try {
      await AppointmentService.deleteRepairItem(
        accessToken,
        widget.workshopId,
        widget.appointmentId,
        item.id,
      );
      setState(() {
        repairItems.removeAt(index);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błąd podczas usuwania elementu naprawy')),
      );
    }
  }

  void _showRecommendations(BuildContext context, String recommendations) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Rekomendacje'),
        content: SingleChildScrollView(
          child: Text(recommendations),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Zamknij'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    // Wyliczamy dynamicznie akcje w AppBar w zależności od tego, czy mamy załadowane dane.
    List<Widget> appBarActions = [];

// Jeśli mamy dane o wizycie, dodaj ikonę historii jako pierwszą:
  if (_currentAppointment != null) {
    appBarActions.add(
      IconButton(
        icon: const Icon(Icons.history),
        tooltip: 'Historia pojazdu',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VehicleServiceHistoryScreen(
                workshopId: widget.workshopId,
                vehicleId: _currentAppointment!.vehicle.id,
              ),
            ),
          );
        },
      ),
    );

    // Dodaj przycisk do wyświetlania rekomendacji
    appBarActions.add(
      IconButton(
        icon: const Icon(Icons.recommend),
        tooltip: 'Pokaż rekomendacje',
        onPressed: () {
          _showRecommendations(context, _currentAppointment!.recommendations);
        },
      ),
    );
  }

    return Scaffold(
      appBar: AppBar(
        title: _currentAppointment == null
            ? const Text('Ładowanie...')
            : Text(
                '${DateFormat('dd-MM-yyyy').format(_currentAppointment!.scheduledTime.toLocal())} '
                '- ${_currentAppointment!.vehicle.make} ${_currentAppointment!.vehicle.model}',
              ),
        actions: appBarActions,
      ),
      body: FutureBuilder<Appointment>(
        future: _appointmentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _appointmentFuture = _fetchAppointmentDetails();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Ponów próbę'),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Nie znaleziono zlecenia'));
          } else {
            final appointment = snapshot.data!;
            final totalCost = _calculateTotalCost(appointment.repairItems);
            final totalEstimatedDuration = _calculateTotalEstimatedDuration(appointment.repairItems);
            final discountedCost = _calculateDiscountedCost(totalCost, appointment.client.segment);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Szczegóły zlecenia
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ExpansionTile(
                      title: const Text('Szczegóły Zlecenia'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                'Data',
                                DateFormat('dd-MM-yyyy HH:mm').format(appointment.scheduledTime.toLocal()),
                                icon: Icons.calendar_today,
                              ),
                              _buildDetailRow(
                                'Status',
                                _getStatusLabel(appointment.status),
                                icon: Icons.info,
                              ),
                              _buildDetailRow(
                                'Przebieg',
                                '${appointment.mileage} km',
                                icon: Icons.speed,
                              ),
                              _buildDetailRow(
                                'Szacowany czas',
                                _formatDuration(totalEstimatedDuration),
                                icon: Icons.timer,
                              ),
                              _buildDetailRow(
                                'Całkowity koszt',
                                '${totalCost.toStringAsFixed(2)} PLN',
                                icon: Icons.attach_money,
                              ),
                              _buildDetailRow(
                                'Koszt z rabatem',
                                '${discountedCost.toStringAsFixed(2)} PLN',
                                icon: Icons.money_off,
                              ),
                              if (appointment.notes != null && appointment.notes!.isNotEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Notatki:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              if (appointment.notes != null && appointment.notes!.isNotEmpty)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    appointment.notes!,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Szczegóły pojazdu
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ExpansionTile(
                      title: const Text('Szczegóły Pojazdu'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildDetailRow('Marka', appointment.vehicle.make),
                              _buildDetailRow('Model', appointment.vehicle.model),
                              _buildDetailRow('Rok', appointment.vehicle.year.toString()),
                              _buildDetailRow('VIN', appointment.vehicle.vin),
                              _buildDetailRow('Rejestracja', appointment.vehicle.licensePlate),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Szczegóły klienta
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ExpansionTile(
                      title: const Text('Szczegóły Klienta'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                'Imię i nazwisko',
                                '${appointment.client.firstName} ${appointment.client.lastName}',
                                icon: Icons.person,
                              ),
                              _buildDetailRow('Email', appointment.client.email, icon: Icons.email),
                              _buildDetailRow('Telefon', appointment.client.phone ?? 'Brak', icon: Icons.phone),
                              if (appointment.client.address != null) _buildDetailRow('Adres', appointment.client.address!, icon: Icons.home),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Formularz dodawania elementu naprawy
                  _buildSectionTitle('Elementy Naprawy'),
                  _buildAddRepairItemForm(),

                  const SizedBox(height: 16),

                  // Tabela elementów naprawy
                  Container(
                    width: double.infinity,
                    child: _buildRepairItemsTable(),
                  ),

                  const SizedBox(height: 16),

                  // Formularz dodawania części
                  _buildSectionTitle('Części'),
                  _buildAddPartForm(),
                  const SizedBox(height: 16),

                  // Tabela części
                  Container(
                    width: double.infinity,
                    child: _buildPartsTable(),
                  ),
                  // Podsumowanie kosztów
                  // Podsumowanie kosztów
const Divider(),
Padding(
  padding: const EdgeInsets.only(top: 16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Suma cen części: ${totalPartCost.toStringAsFixed(2)} PLN'),
      Text('Suma cen usług: ${totalServiceCost.toStringAsFixed(2)} PLN'),
      Text(
        'Łączna cena: ${(totalPartCost + totalServiceCost).toStringAsFixed(2)} PLN',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8), // Dodatkowy odstęp
      Text(
        'Cena po rabacie: ${_calculateDiscountedCost(totalPartCost + totalServiceCost, _currentAppointment?.client.segment).toStringAsFixed(2)} PLN',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green, // Możesz zmienić kolor na inny, aby wyróżnić cenę po rabacie
        ),
      ),
    ],
  ),
),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
