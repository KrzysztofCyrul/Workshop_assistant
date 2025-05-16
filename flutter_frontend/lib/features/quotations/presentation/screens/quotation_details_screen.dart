import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/features/clients/domain/entities/client.dart';
import 'package:flutter_frontend/features/quotations/domain/entities/quotation.dart';
import 'package:flutter_frontend/features/quotations/domain/entities/quotation_part.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/part_form_widget.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_frontend/features/quotations/presentation/bloc/quotation_bloc.dart';
import 'package:flutter_frontend/features/vehicles/domain/entities/vehicle.dart';

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
  State<QuotationDetailsScreen> createState() => _QuotationDetailsScreenState();
}

class _QuotationDetailsScreenState extends State<QuotationDetailsScreen> {
  // Controllers for form inputs
  final partNameController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final partCostController = TextEditingController(text: '0.0');
  final serviceCostController = TextEditingController(text: '0.0');
  final buyCostPartController = TextEditingController(text: '0.0');

  // Parts suggestions for autocomplete
  List<String> partsSuggestions = [];
  bool isSuggestionsLoaded = false;

  // Calculate totals
  double getTotalPartCost(List<QuotationPart> parts) => 
    parts.fold(0, (sum, item) => sum + (item.costPart * item.quantity));
  
  double getTotalServiceCost(List<QuotationPart> parts) => 
    parts.fold(0, (sum, item) => sum + (item.costService));
  
  double getTotalBuyCostPart(List<QuotationPart> parts) => 
    parts.fold(0, (sum, item) => sum + (item.buyCostPart * item.quantity));
  
  double getTotalMargin(List<QuotationPart> parts) => 
    getTotalPartCost(parts) - getTotalBuyCostPart(parts);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadPartsSuggestions();
  }

  void _loadInitialData() {
    // Load quotation details
    context.read<QuotationBloc>().add(
      LoadQuotationDetailsEvent(
        workshopId: widget.workshopId, 
        quotationId: widget.quotationId,
      ),
    );
  }

  Future<void> _loadPartsSuggestions() async {
    if (!isSuggestionsLoaded) {
      try {
        final String response = await rootBundle.loadString('assets/parts.json');
        final List<dynamic> data = json.decode(response);
        setState(() {
          partsSuggestions = List<String>.from(data);
          isSuggestionsLoaded = true;
        });
      } catch (e) {
        debugPrint('Error loading parts suggestions: $e');
      }
    }
  }

  void _addPart() {
    if (partNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proszę wprowadzić nazwę części')),
      );
      return;
    }

    // Parse values with fallbacks for empty fields
    final quantity = int.tryParse(quantityController.text) ?? 1;
    final costPart = double.tryParse(partCostController.text) ?? 0.0;
    final costService = double.tryParse(serviceCostController.text) ?? 0.0;
    final buyCostPart = double.tryParse(buyCostPartController.text) ?? 0.0;    // Add part via BLoC
    context.read<QuotationBloc>().add(
      AddQuotationPartEvent(
        workshopId: widget.workshopId,
        quotationId: widget.quotationId,
        name: partNameController.text.trim(),
        description: null,
        quantity: quantity,
        costPart: costPart,
        costService: costService,
        buyCostPart: buyCostPart,
      ),
    );

    // Clear input fields
    partNameController.clear();
    quantityController.text = '1';
    partCostController.text = '0.0';
    serviceCostController.text = '0.0';
    buyCostPartController.text = '0.0';
  }

  void _editPartValue(String partId, String field, dynamic newValue) {
    final state = context.read<QuotationBloc>().state;
    if (state is! QuotationDetailsLoaded && state is! QuotationOperationSuccessWithDetails) {
      return;
    }

    final quotation = state is QuotationDetailsLoaded
        ? state.quotation
        : (state as QuotationOperationSuccessWithDetails).quotation;

    final part = quotation.parts.firstWhere((p) => p.id == partId);

    // Prepare updated values
    final name = field == 'name' ? newValue as String : part.name;
    final quantity = field == 'quantity' ? newValue as int : part.quantity;
    final costPart = field == 'costPart' ? newValue as double : part.costPart;
    final costService = field == 'costService' ? newValue as double : part.costService;
    final buyCostPart = field == 'buyCostPart' ? newValue as double : part.buyCostPart;    // Update part via BLoC
    context.read<QuotationBloc>().add(
      UpdateQuotationPartEvent(
        workshopId: widget.workshopId,
        quotationId: widget.quotationId,
        partId: partId,
        name: name,
        description: null,
        quantity: quantity,
        costPart: costPart,
        costService: costService,
        buyCostPart: buyCostPart,
      ),
    );
  }
  void _confirmDeletePart(String partId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: const Text(
            'Usuwanie części',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Czy na pewno chcesz usunąć tę część z wyceny?'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Anuluj', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              icon: const Icon(Icons.delete, size: 18),
              label: const Text('Usuń', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
                _deletePart(partId);
              },
            ),
          ],
        );
      },
    );
  }

  void _deletePart(String partId) {
    context.read<QuotationBloc>().add(
      DeleteQuotationPartEvent(
        workshopId: widget.workshopId,
        quotationId: widget.quotationId,
        partId: partId,
      ),
    );
  }

  Future<void> _generatePdf(Quotation quotation) async {
    final pdf = pw.Document();

    // Load fonts
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    final boldFontData = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
    final boldTtf = pw.Font.ttf(boldFontData);

    // Calculate totals
    final totalPartsCost = getTotalPartCost(quotation.parts.cast<QuotationPart>());
    final totalServiceCost = getTotalServiceCost(quotation.parts.cast<QuotationPart>());
    final totalCost = totalPartsCost + totalServiceCost;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [              pw.Text('WYCENA nr ${quotation.quotationNumber}',
                  style: pw.TextStyle(font: boldTtf, fontSize: 20)),
              pw.Text(
                  'Data: ${DateFormat('dd.MM.yyyy').format(quotation.createdAt)}',
                  style: pw.TextStyle(font: ttf, fontSize: 10)),
              pw.SizedBox(height: 20),
              
              // Client and vehicle information
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(3),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6.0),
                        child: pw.Text('Klient:', style: pw.TextStyle(font: ttf)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6.0),
                        child: pw.Text(
                            '${quotation.client.firstName} ${quotation.client.lastName}',
                            style: pw.TextStyle(font: ttf)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6.0),
                        child: pw.Text('Pojazd:', style: pw.TextStyle(font: ttf)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6.0),
                        child: pw.Text(
                            '${quotation.vehicle.licensePlate} ${quotation.vehicle.make} ${quotation.vehicle.model}',
                            style: pw.TextStyle(font: ttf)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6.0),
                        child: pw.Text('Telefon:', style: pw.TextStyle(font: ttf)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6.0),
                        child: pw.Text(
                            quotation.client.phone ?? "Brak",
                            style: pw.TextStyle(font: ttf)),
                      ),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 20),
              
              // Parts table
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
                  // Header row
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6.0),
                        child: pw.Text('Część', style: pw.TextStyle(font: boldTtf)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6.0),
                        child: pw.Text('Ilość', style: pw.TextStyle(font: boldTtf)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6.0),
                        child: pw.Text('Cena części (PLN)', style: pw.TextStyle(font: boldTtf)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6.0),
                        child: pw.Text('Razem (PLN)', style: pw.TextStyle(font: boldTtf)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6.0),
                        child: pw.Text('Usługa (PLN)', style: pw.TextStyle(font: boldTtf)),
                      ),
                    ],
                  ),
                  
                  // Parts rows
                  ...quotation.parts.map((part) => pw.TableRow(
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
                  )),
                ],
              ),
              
              pw.SizedBox(height: 20),
              
              // Summary table
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
              
              // Footer
              pw.Text('IN-CARS Beata Inglot', style: pw.TextStyle(font: ttf, fontSize: 10)),
              pw.Text('Malawa 827', style: pw.TextStyle(font: ttf, fontSize: 10)),
              pw.Text('36–007 Krasne', style: pw.TextStyle(font: ttf, fontSize: 10)),
              pw.Text('NIP 8131190318', style: pw.TextStyle(font: ttf, fontSize: 10)),
              pw.Text('serwisincars@gmail.com', style: pw.TextStyle(font: ttf, fontSize: 10)),
            ],
          );
        },
      ),
    );    // Generate file name based on quotation information
    final fileName = 'Wycena_${quotation.quotationNumber}_${DateFormat('ddMMyyyy').format(quotation.createdAt.toLocal())}.pdf';
    
    // Print the PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: fileName,
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
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
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
  }  Widget _buildAddPartForm() {
    return PartFormWidget(
      partNameController: partNameController,
      quantityController: quantityController,
      partCostController: partCostController,
      serviceCostController: serviceCostController,
      buyCostPartController: buyCostPartController,
      partsSuggestions: partsSuggestions,
      onAddPart: _addPart,
    );
  }
  Widget _buildPartsTable(List<QuotationPart> parts) {
    // Helper method for editable cells
    DataCell buildEditableCell(String initialValue, String fieldName, QuotationPart part,
        {TextInputType keyboardType = TextInputType.text, bool isNumber = false, bool alignCenter = false}) {
      final controller = TextEditingController(text: initialValue);
      return DataCell(
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
            isDense: true,
          ),
          textAlign: alignCenter ? TextAlign.center : TextAlign.start,
          style: const TextStyle(fontSize: 14),
          onFieldSubmitted: (newValue) {
            dynamic value = newValue;
            if (isNumber) {
              if (fieldName == 'quantity') {
                value = int.tryParse(newValue) ?? part.quantity;
              } else {
                value = double.tryParse(newValue) ?? 0.0;
              }
            }
            _editPartValue(part.id, fieldName, value);
          },
          onTapOutside: (_) {
            if (FocusScope.of(context).hasFocus) {
              dynamic value = controller.text;
              if (isNumber) {
                if (fieldName == 'quantity') {
                  value = int.tryParse(controller.text) ?? part.quantity;
                } else {
                  value = double.tryParse(controller.text) ?? 0.0;
                }
              }
              _editPartValue(part.id, fieldName, value);
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
        ),
      );
    }

    // Obsługa pustej listy
    if (parts.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        elevation: 2,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'Brak dodanych części',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth, // Ważne: ustawia minimalną szerokość na szerokość ekranu
                  ),
                  child: SingleChildScrollView(
                    child: DataTable(
                      columnSpacing: 10.0,
                      horizontalMargin: 16.0,
                      headingRowHeight: 48.0,
                      dataRowHeight: 56.0,
                      // Ustawienie dostosowania szerokości kolumny
                      border: TableBorder.all(
                        color: Colors.grey.shade300,
                        width: 1,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      headingRowColor: MaterialStateProperty.resolveWith(
                        (states) => Colors.green.shade100,
                      ),
                      dataRowColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.selected)) {
                          return Colors.green.shade50;
                        }
                        return states.any((element) => element == MaterialState.hovered) ? Colors.grey.shade200 : Colors.grey.shade50;
                      }),
                      columns: const [
                        DataColumn(
                          label: Expanded(
                            child: Center(
                              child: Text(
                                'Część',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Center(
                              child: Text(
                                'Ilość',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Center(
                              child: Text(
                                'Hurtowa',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Center(
                              child: Text(
                                'Części',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Center(
                              child: Text(
                                'Suma',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Center(
                              child: Text(
                                'Usługa',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
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
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                      rows: parts.map((part) {
                        return DataRow(
                          cells: [
                            // Part name
                            buildEditableCell(part.name, 'name', part),
                            // Quantity
                            buildEditableCell(
                              part.quantity.toString(), 
                              'quantity', 
                              part,
                              keyboardType: TextInputType.number, 
                              isNumber: true,
                              alignCenter: true,
                            ),
                            // Buy cost
                            buildEditableCell(
                              part.buyCostPart.toStringAsFixed(2), 
                              'buyCostPart',
                              part, 
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              isNumber: true,
                              alignCenter: true,
                            ),
                            // Part cost
                            buildEditableCell(
                              part.costPart.toStringAsFixed(2), 
                              'costPart', 
                              part,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              isNumber: true,
                              alignCenter: true,
                            ),
                            // Total cost (calculated)
                            DataCell(
                              Center(
                                child: Text(
                                  (part.costPart * part.quantity).toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            // Service cost
                            buildEditableCell(
                              part.costService.toStringAsFixed(2), 
                              'costService', 
                              part,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              isNumber: true,
                              alignCenter: true,
                            ),
                            // Actions
                            DataCell(
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _confirmDeletePart(part.id),
                                      tooltip: 'Usuń część',
                                      padding: const EdgeInsets.all(8.0),
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
          },
        ),
      ),
    );
  }

  Widget _buildQuotationDetailsCard(BuildContext context, Quotation quotation) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: const Icon(Icons.description, color: Colors.blue),
        ),
        title: const Text(
          'Szczegóły Wyceny',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),        subtitle: Text(
          'Nr: ${quotation.quotationNumber}',
          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildDetailRow(
                  'Data utworzenia',
                  DateFormat('dd-MM-yyyy HH:mm').format(quotation.createdAt.toLocal()),
                  icon: Icons.calendar_today,
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
    );
  }

  Widget _buildClientDetailsCard(Client client) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ExpansionTile(
        initiallyExpanded: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: const Icon(Icons.person, color: Colors.purple),
        ),
        title: const Text(
          'Dane Klienta',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '${client.firstName} ${client.lastName}',
          style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildDetailRow(
                  'Imię i nazwisko',
                  '${client.firstName} ${client.lastName}',
                  icon: Icons.person,
                ),
                if (client.phone != null)
                  _buildDetailRow(
                    'Telefon',
                    client.phone ?? '',
                    icon: Icons.phone,
                  ),
                _buildDetailRow(
                  'Email',
                  client.email,
                  icon: Icons.email,
                ),
                if (client.address != null)
                  _buildDetailRow(
                    'Adres',
                    client.address ?? '',
                    icon: Icons.home,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleDetailsCard(Vehicle vehicle) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ExpansionTile(
        initiallyExpanded: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: const Icon(Icons.directions_car, color: Colors.teal),
        ),
        title: const Text(
          'Dane Pojazdu',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '${vehicle.make} ${vehicle.model}',
          style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildDetailRow(
                  'Marka i model',
                  '${vehicle.make} ${vehicle.model}',
                  icon: Icons.directions_car,
                ),
                _buildDetailRow(
                  'Nr. rejestracyjny',
                  vehicle.licensePlate,
                  icon: Icons.app_registration,
                ),
                _buildDetailRow(
                  'VIN',
                  vehicle.vin,
                  icon: Icons.pin,
                ),
                _buildDetailRow(
                  'Rok produkcji',
                  vehicle.year.toString(),
                  icon: Icons.date_range,
                ),
                _buildDetailRow(
                  'Przebieg',
                  '${vehicle.mileage} km',
                  icon: Icons.speed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCostSummaryCard(List<QuotationPart> parts) {
    final totalPartsCost = getTotalPartCost(parts);
    final totalServiceCost = getTotalServiceCost(parts);
    final totalMargin = getTotalMargin(parts);
    final totalCost = totalPartsCost + totalServiceCost;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Podsumowanie kosztów',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildCostRow('Suma cen części:', totalPartsCost, false),
            _buildCostRow('Marża:', totalMargin, false),
            _buildCostRow('Suma cen usług:', totalServiceCost, false),
            const Divider(thickness: 1.0),
            _buildCostRow('Łączna cena:', totalCost, true),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCostRow(String label, double value, bool isTotal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16.0 : 14.0,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: isTotal
                ? BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.green.shade200),
                  )
                : null,
            child: Text(
              '${value.toStringAsFixed(2)} PLN',
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 16.0 : 14.0,
                color: isTotal ? Colors.green.shade800 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Quotation quotation) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Information cards
          _buildQuotationDetailsCard(context, quotation),
          const SizedBox(height: 8.0),
          _buildClientDetailsCard(quotation.client),
          const SizedBox(height: 8.0),
          _buildVehicleDetailsCard(quotation.vehicle),          // Parts section
          const SizedBox(height: 16),
          _buildSectionTitle('Części i Usługi'),
          _buildAddPartForm(),
          const SizedBox(height: 16),
          _buildPartsTable(quotation.parts.cast<QuotationPart>()),
          
          // Cost summary
          const SizedBox(height: 16),
          _buildCostSummaryCard(quotation.parts.cast<QuotationPart>()),
        ],
      ),
    );
  }  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuotationBloc, QuotationState>(
      buildWhen: (previous, current) {
        return current is QuotationDetailsLoaded || current is QuotationOperationSuccessWithDetails;
      },
      builder: (context, state) {
        Quotation? quotation;
        if (state is QuotationDetailsLoaded) {
          quotation = state.quotation;
        } else if (state is QuotationOperationSuccessWithDetails) {
          quotation = state.quotation;
        }
        
        return Scaffold(
          appBar: _AppBarBuilder(
            quotation: quotation,
            onPrintPressed: _onPrintButtonPressed,
          ),
          body: _buildBody(),
        );
      }
    );
  }
    void _onPrintButtonPressed(Quotation quotation) {
    _generatePdf(quotation);
    }
  
  Widget _buildBody() {
    return BlocConsumer<QuotationBloc, QuotationState>(
      listener: (context, state) {
        if (state is QuotationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is QuotationOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is QuotationUnauthenticated) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      builder: (context, state) {
        if (state is QuotationDetailsLoaded) {
        } else if (state is QuotationOperationSuccessWithDetails) {
        }
        
        if (state is QuotationLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is QuotationError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Wystąpił błąd',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadInitialData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Odśwież'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is QuotationDetailsLoaded || state is QuotationOperationSuccessWithDetails) {
          final quotation = state is QuotationDetailsLoaded 
              ? state.quotation 
              : (state as QuotationOperationSuccessWithDetails).quotation;
          
          return _buildContent(context, quotation);
        } else {
          return const Center(child: Text('Nie znaleziono wyceny'));
        }
      },
    );
  }

  @override
  void dispose() {
    partNameController.dispose();
    quantityController.dispose();
    partCostController.dispose();
    serviceCostController.dispose();
    buyCostPartController.dispose();
    super.dispose();
  }
}

class _AppBarBuilder extends StatelessWidget implements PreferredSizeWidget {
  final Quotation? quotation;
  final Function(Quotation) onPrintPressed;

  const _AppBarBuilder({
    required this.quotation,
    required this.onPrintPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: BlocBuilder<QuotationBloc, QuotationState>(
        buildWhen: (previous, current) {
          return current is QuotationDetailsLoaded || current is QuotationOperationSuccessWithDetails;
        },        builder: (context, state) {
          if (state is QuotationDetailsLoaded) {
            final quotation = state.quotation;
            return Text('Wycena ${quotation.quotationNumber} - ${quotation.vehicle.make} ${quotation.vehicle.model}');
          } else if (state is QuotationOperationSuccessWithDetails) {
            final quotation = state.quotation;
            return Text('Wycena ${quotation.quotationNumber} - ${quotation.vehicle.make} ${quotation.vehicle.model}');
          }
          return const Text('Ładowanie...');
        },
      ),
      actions: _buildAppBarActions(context),
    );
  }
  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      BlocBuilder<QuotationBloc, QuotationState>(
        builder: (context, state) {
          // Only show print button when we have a valid quotation state
          if (state is! QuotationDetailsLoaded && state is! QuotationOperationSuccessWithDetails) {
            return const SizedBox.shrink();
          }
          
          final quotation = state is QuotationDetailsLoaded 
              ? state.quotation 
              : (state as QuotationOperationSuccessWithDetails).quotation;
          
          // Use the quotation from the state, not the nullable one passed to the constructor
          return IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Drukuj wycenę',
            onPressed: () => onPrintPressed(quotation),
          );
        },
      ),
    ];
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
