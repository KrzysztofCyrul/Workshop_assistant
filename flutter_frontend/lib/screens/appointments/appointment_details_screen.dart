import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/appointment.dart';
import '../../data/models/repair_item.dart';
import '../../data/models/part.dart';
import '../../services/appointment_service.dart';
import '../../providers/auth_provider.dart';
import '../service_records/service_history_screen.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  static const routeName = '/appointment-details';

  final String workshopId;
  final String appointmentId;

  const AppointmentDetailsScreen({
    super.key,
    required this.workshopId,
    required this.appointmentId,
  });

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
  final TextEditingController buyCostPartController = TextEditingController();

  final TextEditingController repairDescriptionController = TextEditingController();
  final TextEditingController repairCostController = TextEditingController();
  final TextEditingController estimatedDurationController = TextEditingController();

  double get totalBuyCostPart => parts.fold(0, (sum, item) => sum + (item.buyCostPart * item.quantity));
  double get totalPartCost => parts.fold(0, (sum, item) => sum + (item.costPart * item.quantity));
  double get totalServiceCost => parts.fold(0, (sum, item) => sum + item.costService);
  double get totalMargin => totalPartCost - totalBuyCostPart;

  @override
  void initState() {
    super.initState();
    _appointmentFuture = _fetchAppointmentDetails();
    quantityController.text = '1';
    partCostController.text = '0.0';
    serviceCostController.text = '0.0';
    buyCostPartController.text = '0.0';
  }

  Future<Appointment> _fetchAppointmentDetails() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken!;

    try {
      final appointmentService = AppointmentService();
      final appointment = await appointmentService.getAppointmentDetails(
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
    if (partNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wypełnij wszystkie pola')),
      );
      return;
    }

    // Ustawienie domyślnej wartości 0, jeśli pola kosztu części lub usługi są puste
    final quantiny = quantityController.text.isEmpty ? 1 : int.parse(quantityController.text);
    final costPart = partCostController.text.isEmpty ? 0.0 : double.parse(partCostController.text);
    final costService = serviceCostController.text.isEmpty ? 0.0 : double.parse(serviceCostController.text);
    final buyCostPart = buyCostPartController.text.isEmpty ? 0.0 : double.parse(buyCostPartController.text);
    

    // Pobranie dostępu do tokenu i przygotowanie danych nowej części
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken!;

    final newPart = Part(
      id: UniqueKey().toString(),
      appointmentId: widget.appointmentId,
      name: partNameController.text.trim(),
      description: '', // Pole 'description', można rozszerzyć formularz
      quantity: quantiny,
      costPart: costPart,
      costService: costService,
      buyCostPart: buyCostPart,
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
        newPart.buyCostPart,
      );

      // Aktualizacja lokalnej listy części i podpowiedzi
      setState(() {
      _appointmentFuture = _fetchAppointmentDetails();
      });

      // Czyszczenie pól formularza po dodaniu
      partNameController.clear();
      quantityController.clear();
      partCostController.clear();
      serviceCostController.clear();
      buyCostPartController.clear();
      FocusScope.of(context).unfocus(); // Ukryj klawiaturę
      setState(() {}); // Wymuś odświeżenie widgetu

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Część została dodana')),
      );
    } catch (e) {
      // Obsługa błędów podczas dodawania części
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błąd podczas dodawania części')),
      );
    }
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
      case 'buyCostPart':
        updatedPart = part.copyWith(buyCostPart: newValue);
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
        buyCostPart: updatedPart.buyCostPart,
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
      _appointmentFuture = _fetchAppointmentDetails(); // Odśwież szczegóły wizyty
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
      DataColumn(label: Center(
          child: Text(
            'Hurtowa',
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
            textAlign: TextAlign.end,
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
            Align(
              alignment: Alignment.centerLeft, // Wyrównanie zawartości do środka
              child: TextFormField(
                initialValue: part.name,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero, // Usunięcie paddingu
                  isDense: true, // Zmniejszenie domyślnej wysokości
                ),
                textAlign: TextAlign.start, // Wyśrodkowanie tekstu
                onChanged: (newValue) {
                  _editPartValue(index, 'name', newValue);
                },
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerLeft, // Wyrównanie zawartości do środka
              child: TextFormField(
                initialValue: part.quantity.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero, // Usunięcie paddingu
                  isDense: true, // Zmniejszenie domyślnej wysokości
                ),
                textAlign: TextAlign.start, // Wyśrodkowanie tekstu
                onChanged: (newValue) {
                  _editPartValue(index, 'quantity', int.tryParse(newValue) ?? part.quantity);
                },
              ),
            ),
          ),
                    DataCell(
            Align(
              alignment: Alignment.centerLeft,
              child: TextFormField(
                initialValue: part.buyCostPart.toStringAsFixed(2),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                textAlign: TextAlign.left, // Wyśrodkowanie tekstu
                onChanged: (newValue) {
                  _editPartValue(index, 'buyCostPart', double.tryParse(newValue) ?? part.buyCostPart);
                },
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerLeft, // Wyrównanie zawartości do środka
              child: TextFormField(
                initialValue: part.costPart.toStringAsFixed(2),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero, // Usunięcie paddingu
                  isDense: true, // Zmniejszenie domyślnej wysokości
                ),
                textAlign: TextAlign.left, // Wyśrodkowanie tekstu
                onChanged: (newValue) {
                  _editPartValue(index, 'costPart', double.tryParse(newValue) ?? part.costPart);
                },
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerLeft, // Wyrównanie zawartości do środka
              child: Text(
                (part.costPart * part.quantity).toStringAsFixed(2),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerLeft, // Wyrównanie zawartości do środka
              child: TextFormField(
                initialValue: part.costService.toStringAsFixed(2),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero, // Usunięcie paddingu
                  isDense: true, // Zmniejszenie domyślnej wysokości
                ),
                textAlign: TextAlign.left, // Wyśrodkowanie tekstu
                onChanged: (newValue) {
                  _editPartValue(index, 'costService', double.tryParse(newValue) ?? part.costService);
                },
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerLeft, // Wyrównanie akcji do prawej strony
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDeletePartItem(index),
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
            },
            child: const Text('Usuń'),
          ),
        ],
      );
    },
  );
}

  void _addRepairItem() async {
    if (repairDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wypełnij wszystkie pola')),
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
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
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
        newRepairItem.order
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
        order: updatedItem.order,

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
                onChanged: (newValue) {
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
      }
    }
  }

  Widget _buildAddPartForm() {
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
                return part.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              partNameController.text = selection; // Aktualizuj partNameController po wybraniu podpowiedzi
            },
            fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
              // Synchronizuj partNameController z textEditingController
              partNameController.addListener(() {
                if (partNameController.text != textEditingController.text) {
                  textEditingController.text = partNameController.text;
                }
              });

              return TextField(
                controller: partNameController, // Używamy partNameController
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: 'Część',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                ),
                onChanged: (value) {
                  partNameController.text = value; // Aktualizuj partNameController
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
            controller: buyCostPartController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Cena Hurtowa',
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
          onPressed: _addPart,
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
            onPressed: () async {
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
      _appointmentFuture = _fetchAppointmentDetails(); // Odśwież szczegóły wizyty
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Element naprawy został usunięty')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Błąd podczas usuwania elementu naprawy')),
    );
  }
}


Future<void> generatePdf(Appointment appointment, List<Part> parts, List<RepairItem> repairItems) async {
  final pdf = pw.Document();

  final font = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
  final ttf = pw.Font.ttf(font);

  final boldFont = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
  final boldTtf = pw.Font.ttf(boldFont);

  double totalPartsCost = parts.fold(0, (sum, part) => sum + (part.costPart * part.quantity));
  double totalServiceCost = parts.fold(0, (sum, part) => sum + part.costService);
  double totalCost = totalPartsCost + totalServiceCost;

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              'ZLECENIE NAPRAWY - ${DateFormat('dd.MM.yyyy').format(appointment.scheduledTime.toLocal())}',
              style: pw.TextStyle(font: boldTtf, fontSize: 20),
            ),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6.0),
                        child: pw.Text('Pojazd:', style: pw.TextStyle(font: ttf)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6.0),
                        child: pw.Text('${appointment.vehicle.licensePlate} ${appointment.vehicle.make} ${appointment.vehicle.model} ', style: pw.TextStyle(font: ttf)),
                      ),
                    ],
                  ),
                   pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6.0),
                        child: pw.Text('Numer telefonu:', style: pw.TextStyle(font: ttf)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6.0),
                        child: pw.Text('${appointment.client.phone}', style: pw.TextStyle(font: ttf)),
                      ),
                    ],
                  ),
                ],
              ),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1),
                4: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6.0),
                      child: pw.Text('DO ZROBIENIA', style: pw.TextStyle(font: boldTtf)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6.0),
                      child: pw.Text('ILOŚĆ', style: pw.TextStyle(font: boldTtf)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6.0),
                      child: pw.Text('CZĘŚCI (PLN)', style: pw.TextStyle(font: boldTtf)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6.0),
                      child: pw.Text('RAZEM (PLN)', style: pw.TextStyle(font: boldTtf)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6.0),
                      child: pw.Text('USŁUGA (PLN)', style: pw.TextStyle(font: boldTtf)),
                    ),
                  ],
                ),
                for (var part in parts)
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(part.name, style: pw.TextStyle(font: ttf)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(part.quantity.toString(), style: pw.TextStyle(font: ttf)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(part.costPart.toStringAsFixed(2), style: pw.TextStyle(font: ttf)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text((part.costPart * part.quantity).toStringAsFixed(2), style: pw.TextStyle(font: ttf)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(part.costService.toStringAsFixed(2), style: pw.TextStyle(font: ttf)),
                      ),
                    ],
                  ),
              ],
            ),
            pw.SizedBox(height: 20),
            // Podsumowanie
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6.0),
                      child: pw.Text('SUMA CZĘŚCI (PLN):', style: pw.TextStyle(font: boldTtf)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6.0),
                      child: pw.Text(totalPartsCost.toStringAsFixed(2), style: pw.TextStyle(font: ttf)),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6.0),
                      child: pw.Text('SUMA USŁUG (PLN):', style: pw.TextStyle(font: boldTtf)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6.0),
                      child: pw.Text(totalServiceCost.toStringAsFixed(2), style: pw.TextStyle(font: ttf)),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6.0),
                      child: pw.Text('CAŁKOWITA SUMA (PLN):', style: pw.TextStyle(font: boldTtf)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6.0),
                      child: pw.Text(totalCost.toStringAsFixed(2), style: pw.TextStyle(font: ttf)),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text('IN-CARS Beata Inglot', style: pw.TextStyle(font: ttf, fontSize: 14)),
            pw.Text('Malawa 827', style: pw.TextStyle(font: ttf, fontSize: 14)),
            pw.Text('36–007 Krasne', style: pw.TextStyle(font: ttf, fontSize: 14)),
            pw.Text('NIP 8131190318', style: pw.TextStyle(font: ttf, fontSize: 14)),
            pw.Text('serwisincars@gmail.com', style: pw.TextStyle(font: ttf, fontSize: 14)),
          ],
        );
      },
    ),
  );

  // Zapisz PDF do pliku z automatycznie wygenerowaną nazwą
  final fileName = '${appointment.vehicle.make}_${appointment.vehicle.model}_${DateFormat('ddMMyyyy').format(appointment.scheduledTime.toLocal())}.pdf';
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
    name: fileName,
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

      appBarActions.add(
        IconButton(
          icon: const Icon(Icons.print),
          tooltip: 'Drukuj',
          onPressed: () {
            generatePdf(_currentAppointment!, parts, repairItems);
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notatki:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    initialValue: appointment.notes ?? '',
                    decoration: const InputDecoration(
                      hintText: 'Dodaj notatki...',
                      border: InputBorder.none,
                    ),
                    maxLines: 3,
                    onChanged: (newValue) async {
                      if (newValue != appointment.notes) {
                        try {
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          final accessToken = authProvider.accessToken!;

                          await AppointmentService.editNotesValue(
                            accessToken: accessToken,
                            workshopId: widget.workshopId,
                            appointmentId: widget.appointmentId,
                            newNotes: newValue,
                          );

                          setState(() {
                            _currentAppointment = _currentAppointment!.copyWith(notes: newValue);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notatki zostały zaktualizowane')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Błąd podczas aktualizacji notatek: $e')),
                          );
                        }
                      }
                    },
                  ),
                ],
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
                  _buildSectionTitle('Do naprawy'),
                  _buildAddRepairItemForm(),

                  const SizedBox(height: 16),

                  // Tabela elementów naprawy
                  SizedBox(
                    width: double.infinity,
                    child: _buildRepairItemsTable(),
                  ),

                  const SizedBox(height: 16),

                  // Formularz dodawania części
                  _buildSectionTitle('Części'),
                  _buildAddPartForm(),
                  const SizedBox(height: 16),

                  // Tabela części
                  SizedBox(
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
                        Text('Marża: ${totalMargin.toStringAsFixed(2)} PLN'),
                        Text('Suma cen usług: ${(totalServiceCost).toStringAsFixed(2)} PLN'),
                        Text(
                          'Łączna cena: ${(totalPartCost + totalServiceCost).toStringAsFixed(2)} PLN',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cena po rabacie: ${_calculateDiscountedCost(totalPartCost + totalServiceCost, _currentAppointment?.client.segment).toStringAsFixed(2)} PLN',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
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
