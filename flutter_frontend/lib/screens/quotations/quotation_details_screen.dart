import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/quotation.dart';
import '../../data/models/quotation_part.dart';
import '../../services/quotation_service.dart';
import '../../providers/auth_provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class QuotationDetailsScreen extends StatefulWidget {
  static const routeName = '/quotation-details';

  final String workshopId;
  final String quotationId;

  const QuotationDetailsScreen({
    super.key,
    required this.workshopId,
    required this.quotationId,
  });

  @override
  _QuotationDetailsScreenState createState() => _QuotationDetailsScreenState();
}

class _QuotationDetailsScreenState extends State<QuotationDetailsScreen> {
  late Future<Quotation> _quotationFuture;
  Quotation? _currentQuotation;

  final List<QuotationPart> parts = [];

  final TextEditingController partNameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController partCostController = TextEditingController();
  final TextEditingController serviceCostController = TextEditingController();

  final TextEditingController repairDescriptionController = TextEditingController();
  final TextEditingController repairCostController = TextEditingController();

  List<String> partsSuggestions = [];
  bool isSuggestionsLoaded = false;

  double get totalPartCost => parts.fold(0, (sum, item) => sum + (item.costPart * item.quantity));
    double get totalServiceCost => parts.fold(0, (sum, item) => sum + (item.costService));

  @override
  void initState() {
    super.initState();
    _quotationFuture = _fetchQuotationDetails();
    quantityController.text = '1';
    partCostController.text = '0.0';
    serviceCostController.text = '0.0';
    _loadPartsSuggestions();
  }

  Future<Quotation> _fetchQuotationDetails() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken!;

    try {
      final quotation = await QuotationService.getQuotationDetails(
        accessToken,
        widget.workshopId,
        widget.quotationId,
      );
      setState(() {
        _currentQuotation = quotation;

        parts.clear();
        parts.addAll(quotation.parts);
      });
      return quotation;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas pobierania szczegółów wyceny: $e')),
      );
      throw Exception('Błąd podczas pobierania szczegółów wyceny.');
    }
  }

  Future<void> _loadPartsSuggestions() async {
    if (!isSuggestionsLoaded) {
      try {
        final String response = await rootBundle.loadString('assets/parts.json');
        final List<dynamic> data = json.decode(response);
        partsSuggestions = List<String>.from(data);
        isSuggestionsLoaded = true;
      } catch (e) {
        print('Błąd podczas ładowania danych: $e');
      }
    }
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

  void _addPart() async {
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

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken!;

    final newPart = QuotationPart(
      id: UniqueKey().toString(),
      quotationId: widget.quotationId,
      name: partNameController.text.trim(),
      description: '',
      quantity: quantiny,
      costPart: costPart,
      costService: costService,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await QuotationService.createQuotationPart(
        accessToken: accessToken,
        workshopId: widget.workshopId,
        quotationId: widget.quotationId,
        name: newPart.name,
        description: newPart.description,
        costPart: newPart.costPart,
        quantity: newPart.quantity,
      );

      setState(() {
        parts.add(newPart);
      });

      partNameController.clear();
      quantityController.clear();
      partCostController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Część została dodana')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błąd podczas dodawania części')),
      );
      print('Error adding part: $e');
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
                  textAlign: TextAlign.left, // Wyśrodkowanie tekstu
                  onChanged: (newValue) {
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
                  onChanged: (newValue) {
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
                  textAlign: TextAlign.left, // Wyśrodkowanie tekstu
                  onChanged: (newValue) {
                    _editPartValue(index, 'costPart', double.tryParse(newValue) ?? part.costPart);
                  },
                ),
              ),
            ),
            DataCell(
              Center(
                child: Text(
                  (part.costPart * part.quantity).toStringAsFixed(2),
                  textAlign: TextAlign.left,
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
                    contentPadding: EdgeInsets.zero,
                  ),
                  textAlign: TextAlign.left,
                  onChanged: (newValue) {
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
                      onPressed: () => _confirmDeleteQuotationPartItem(index),
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


  void _editPartValue(int index, String field, dynamic newValue) async {
    final part = parts[index];
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken!;

    QuotationPart updatedPart;
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

    try {
      await QuotationService.updateQuotationPart(
        accessToken: accessToken,
        workshopId: widget.workshopId,
        quotationId: widget.quotationId,
        partId: part.id,
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

      setState(() {
        parts[index] = part;
      });
    }
  }

  void _confirmDeleteQuotationPartItem(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Potwierdzenie'),
          content: const Text('Czy na pewno chcesz usunąć tę część?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Anuluj'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Usuń'),
              onPressed: () {
                Navigator.of(context).pop();
                _removePart(index);
              },
            ),
          ],
        );
      },
    );
  }

  void _removePart(int index) async {
    final part = parts[index];
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken!;

    try {
      await QuotationService.deleteQuotationPart(
        accessToken: accessToken,
        workshopId: widget.workshopId,
        quotationId: widget.quotationId,
        partId: part.id,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _currentQuotation == null
            ? const Text('Ładowanie...')
            : Text('Wycena ${_currentQuotation!.quotationNumber}'),
      ),
      body: FutureBuilder<Quotation>(
        future: _quotationFuture,
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
                          _quotationFuture = _fetchQuotationDetails();
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
            return const Center(child: Text('Nie znaleziono wyceny'));
          } else {
            final quotation = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Szczegóły wyceny
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ExpansionTile(
                      title: const Text('Szczegóły Wyceny'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                'Numer wyceny',
                                quotation.quotationNumber,
                                icon: Icons.description,
                              ),
                              _buildDetailRow(
                                'Data utworzenia',
                                DateFormat('dd-MM-yyyy HH:mm').format(quotation.createdAt.toLocal()),
                                icon: Icons.calendar_today,
                              ),
                              _buildDetailRow(
                                'Klient',
                                '${quotation.client.firstName} ${quotation.client.lastName}',
                                icon: Icons.person,
                              ),
                              _buildDetailRow(
                                'Pojazd',
                                '${quotation.vehicle.make} ${quotation.vehicle.model}',
                                icon: Icons.directions_car,
                              ),
                              _buildDetailRow(
                                'Koszt całkowity',
                                '${quotation.totalCost?.toStringAsFixed(2) ?? '0.00'} PLN',
                                icon: Icons.attach_money,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),

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