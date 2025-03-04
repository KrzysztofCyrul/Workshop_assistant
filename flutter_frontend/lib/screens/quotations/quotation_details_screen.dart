import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/quotation.dart';
import '../../models/quotation_repair_item.dart';
import '../../models/quotation_part.dart';
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
  final List<QuotationRepairItem> repairItems = [];

  final TextEditingController partNameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController partCostController = TextEditingController();

  final TextEditingController repairDescriptionController = TextEditingController();
  final TextEditingController repairCostController = TextEditingController();

  List<String> partsSuggestions = [];
  bool isSuggestionsLoaded = false;

  double get totalPartCost => parts.fold(0, (sum, item) => sum + (item.costPart * item.quantity));
  double get totalRepairCost => repairItems.fold(0, (sum, item) => sum + item.cost);

  @override
  void initState() {
    super.initState();
    _quotationFuture = _fetchQuotationDetails();
    partCostController.text = '0';
    repairCostController.text = '0';
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
        repairItems.clear();
        repairItems.addAll(quotation.repairItems);

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
                  partNameController.text = value;
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
        IconButton(
          icon: const Icon(Icons.add, color: Colors.green),
          onPressed: _addPart,
          tooltip: 'Dodaj część',
        ),
      ],
    );
  }

  void _addPart() async {
    if (partNameController.text.isEmpty || 
        quantityController.text.isEmpty || 
        partCostController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wypełnij wszystkie pola')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken!;

    final newPart = QuotationPart(
      id: UniqueKey().toString(),
      quotationId: widget.quotationId,
      name: partNameController.text.trim(),
      description: '',
      quantity: int.parse(quantityController.text),
      costPart: double.parse(partCostController.text),
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

  void _addRepairItem() async {
    if (repairDescriptionController.text.isEmpty || repairCostController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wypełnij wszystkie pola')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken!;

    final newRepairItem = QuotationRepairItem(
      id: UniqueKey().toString(),
      quotationId: widget.quotationId,
      description: repairDescriptionController.text.trim(),
      cost: double.parse(repairCostController.text),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      order: repairItems.length + 1,
    );

    try {
      await QuotationService.createQuotationRepairItem(
        accessToken: accessToken,
        workshopId: widget.workshopId,
        quotationId: widget.quotationId,
        description: newRepairItem.description,
        cost: newRepairItem.cost,
        order: newRepairItem.order,
      );

      setState(() {
        repairItems.add(newRepairItem);
      });

      repairDescriptionController.clear();
      repairCostController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Element naprawy został dodany')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błąd podczas dodawania elementu naprawy')),
      );
      print('Error adding repair item: $e');
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
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Opis',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Koszt',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Akcje',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ),
    ],
    rows: repairItems.asMap().entries.map((entry) {
      final index = entry.key;
      final repairItem = entry.value;

      return DataRow(
        cells: [
          DataCell(
            Align(
              alignment: Alignment.centerLeft,
              child: TextFormField(
                initialValue: repairItem.description,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                textAlign: TextAlign.left,
                onFieldSubmitted: (newValue) {
                  _editRepairItemValue(index, 'description', newValue);
                },
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerRight,
              child: TextFormField(
                initialValue: repairItem.cost.toStringAsFixed(2),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                textAlign: TextAlign.right,
                onFieldSubmitted: (newValue) {
                  _editRepairItemValue(index, 'cost', double.tryParse(newValue) ?? repairItem.cost);
                },
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeRepairItem(index),
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

Widget _buildPartsTable() {
  return DataTable(
    columnSpacing: MediaQuery.of(context).size.width * 0.02,
    headingRowColor: WidgetStateColor.resolveWith((states) => Colors.green.shade100),
    dataRowColor: WidgetStateColor.resolveWith((states) {
      return states.contains(WidgetState.selected) ? Colors.green.shade50 : Colors.grey.shade100;
    }),
    columns: const [
      DataColumn(
        label: Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Część',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Ilość',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Cena',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Suma',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Akcje',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
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
              alignment: Alignment.centerLeft,
              child: TextFormField(
                initialValue: part.name,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                textAlign: TextAlign.left,
                onFieldSubmitted: (newValue) {
                  _editPartValue(index, 'name', newValue);
                },
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerLeft,
              child: TextFormField(
                initialValue: part.quantity.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                textAlign: TextAlign.left,
                onFieldSubmitted: (newValue) {
                  _editPartValue(index, 'quantity', int.tryParse(newValue) ?? part.quantity);
                },
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerLeft,
              child: TextFormField(
                initialValue: part.costPart.toStringAsFixed(2),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                textAlign: TextAlign.left,
                onFieldSubmitted: (newValue) {
                  _editPartValue(index, 'costPart', double.tryParse(newValue) ?? part.costPart);
                },
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                (part.costPart * part.quantity).toStringAsFixed(2),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removePart(index),
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

  void _editRepairItemValue(int index, String field, dynamic newValue) async {
    final repairItem = repairItems[index];
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken!;

    QuotationRepairItem updatedRepairItem;
    switch (field) {
      case 'description':
        updatedRepairItem = repairItem.copyWith(description: newValue);
        break;
      case 'cost':
        updatedRepairItem = repairItem.copyWith(cost: newValue);
        break;
      default:
        return;
    }

    setState(() {
      repairItems[index] = updatedRepairItem;
    });

    try {
      await QuotationService.updateQuotationRepairItem(
        accessToken: accessToken,
        workshopId: widget.workshopId,
        quotationId: widget.quotationId,
        repairItemId: repairItem.id,
        description: updatedRepairItem.description,
        cost: updatedRepairItem.cost,
        order: updatedRepairItem.order,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Zaktualizowano pole: $field')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas aktualizacji pola: $field - $e')),
      );

      setState(() {
        repairItems[index] = repairItem;
      });
    }
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

  void _removeRepairItem(int index) async {
    final repairItem = repairItems[index];
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken!;

    try {
      await QuotationService.deleteQuotationRepairItem(
        accessToken: accessToken,
        workshopId: widget.workshopId,
        quotationId: widget.quotationId,
        repairItemId: repairItem.id,
      );

      setState(() {
        repairItems.removeAt(index);
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

                  // Formularz dodawania elementu naprawy
                  _buildSectionTitle('Elementy Naprawy'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: repairDescriptionController,
                          decoration: const InputDecoration(labelText: 'Opis'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: repairCostController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Koszt'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.green),
                        onPressed: _addRepairItem,
                      ),
                    ],
                  ),
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
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Suma cen części: ${totalPartCost.toStringAsFixed(2)} PLN'),
                        Text('Suma cen usług: ${totalRepairCost.toStringAsFixed(2)} PLN'),
                        Text(
                          'Łączna cena: ${(totalPartCost + totalRepairCost).toStringAsFixed(2)} PLN',
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