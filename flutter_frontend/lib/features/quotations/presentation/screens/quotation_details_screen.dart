import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/features/clients/domain/entities/client.dart';
import 'package:flutter_frontend/features/quotations/domain/entities/quotation.dart';
import 'package:flutter_frontend/features/quotations/domain/entities/quotation_part.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/contact_button_widget.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/cost_summary_widget.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/detail_row_widget.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/details_card_widget.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/client_profile_widget.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/vehicle_profile_widget.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/part_form_widget.dart';
import 'package:flutter_frontend/core/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
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

// Form validation mixin - consistent with AppointmentDetailsScreen
mixin FormValidatorMixin {
  String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName nie może być puste';
    }
    return null;
  }

  String? validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName nie może być puste';
    }
    if (double.tryParse(value) == null) {
      return '$fieldName musi być liczbą';
    }
    return null;
  }

  String? validatePositiveNumber(String? value, String fieldName) {
    final numberError = validateNumber(value, fieldName);
    if (numberError != null) {
      return numberError;
    }
    if (double.parse(value!) <= 0) {
      return '$fieldName musi być większe od zera';
    }
    return null;
  }
}

class _QuotationDetailsScreenState extends State<QuotationDetailsScreen> with FormValidatorMixin {
  // Controllers for form inputs
  final _partNameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _partCostController = TextEditingController(text: '0.0');
  final _serviceCostController = TextEditingController(text: '0.0');
  final _buyCostPartController = TextEditingController(text: '0.0');

  // Parts suggestions for autocomplete
  List<String> _partsSuggestions = [];
  bool _isSuggestionsLoaded = false;

  // Calculate totals
  double getTotalPartCost(List<QuotationPart> parts) => 
    parts.fold(0, (sum, item) => sum + (item.costPart * item.quantity));
  
  double getTotalServiceCost(List<QuotationPart> parts) => 
    parts.fold(0, (sum, item) => sum + (item.costService));
  
  double getTotalBuyCostPart(List<QuotationPart> parts) => 
    parts.fold(0, (sum, item) => sum + (item.buyCostPart * item.quantity));
  
  double getTotalMargin(List<QuotationPart> parts) => 
    getTotalPartCost(parts) - getTotalBuyCostPart(parts);
  
  // Helper method for getting initials (like in AppointmentDetailsScreen)
  String _getInitials(String firstName, String lastName) {
    String initials = '';
    if (firstName.isNotEmpty) {
      initials += firstName[0];
    }
    if (lastName.isNotEmpty) {
      initials += lastName[0];
    }
    return initials.isNotEmpty ? initials.toUpperCase() : '?';
  }

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
    if (!_isSuggestionsLoaded) {
      try {
        final String response = await rootBundle.loadString('assets/parts.json');
        final List<dynamic> data = json.decode(response);
        setState(() {
          _partsSuggestions = List<String>.from(data);
          _isSuggestionsLoaded = true;
        });
      } catch (e) {
        debugPrint('Error loading parts suggestions: $e');
      }
    }
  }

  void _addPart() {
    if (_partNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proszę wprowadzić nazwę części')),
      );
      return;
    }

    // Parse values with fallbacks for empty fields
    final quantity = int.tryParse(_quantityController.text) ?? 1;
    final costPart = double.tryParse(_partCostController.text) ?? 0.0;
    final costService = double.tryParse(_serviceCostController.text) ?? 0.0;
    final buyCostPart = double.tryParse(_buyCostPartController.text) ?? 0.0;
    
    // Add part via BLoC
    context.read<QuotationBloc>().add(
      AddQuotationPartEvent(
        workshopId: widget.workshopId,
        quotationId: widget.quotationId,
        name: _partNameController.text.trim(),
        description: null,
        quantity: quantity,
        costPart: costPart,
        costService: costService,
        buyCostPart: buyCostPart,
      ),
    );

    // Clear input fields
    _partNameController.clear();
    _quantityController.text = '1';
    _partCostController.text = '0.0';
    _serviceCostController.text = '0.0';
    _buyCostPartController.text = '0.0';
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
    final buyCostPart = field == 'buyCostPart' ? newValue as double : part.buyCostPart;
    
    // Update part via BLoC
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

  Future<void> _confirmDeletePart(String partId) async {
    // Display confirmation dialog like in AppointmentDetailsScreen
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Potwierdzenie usunięcia'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Czy na pewno chcesz usunąć tę część?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Anuluj'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Usuń'),
            ),
          ],
        );
      },
    );

    // If user confirmed deletion
    if (shouldDelete == true) {
      if (!mounted) return;

      _deletePart(partId);
    }
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
            children: [
              pw.Text('WYCENA nr ${quotation.quotationNumber}',
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
                        child: pw.Text('Pojazd:', style: pw.TextStyle(font: ttf)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6.0),
                        child: pw.Text(
                            '${quotation.vehicle.make} ${quotation.vehicle.model} ${quotation.vehicle.licensePlate}',
                            style: pw.TextStyle(font: ttf)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6.0),
                        child: pw.Text('VIN::', style: pw.TextStyle(font: ttf)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6.0),
                        child: pw.Text(
                            quotation.vehicle.vin,
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
    );
    
    // Generate file name based on quotation information
    final fileName = 'Wycena_${quotation.quotationNumber}_${DateFormat('ddMMyyyy').format(quotation.createdAt.toLocal())}.pdf';
    
    // Print the PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: fileName,
    );
  }
  Widget _buildDetailRow(String label, String value, {IconData? icon, Color? iconColor}) {
    return DetailRowWidget(
      label: label,
      value: value,
      icon: icon,
      iconColor: iconColor ?? Colors.blue,
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
  }

  Widget _buildAddPartForm() {
    return PartFormWidget(
      partNameController: _partNameController,
      quantityController: _quantityController,
      partCostController: _partCostController,
      serviceCostController: _serviceCostController,
      buyCostPartController: _buyCostPartController,
      partsSuggestions: _partsSuggestions,
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

    // Handle empty list
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
                  minWidth: constraints.maxWidth,
                ),
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 10.0,
                    horizontalMargin: 16.0,
                    headingRowHeight: 48.0,
                    dataRowHeight: 56.0,
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
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Text(
                                  (part.costPart * part.quantity).toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
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
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () => _confirmDeletePart(part.id),
                                tooltip: 'Usuń część',
                                splashRadius: 20,
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
    return DetailsCardWidget(
      title: 'Szczegóły Wyceny',
      subtitle: 'Nr: ${quotation.quotationNumber}',
      icon: Icons.description,
      iconBackgroundColor: Colors.blue.shade50,
      iconColor: Colors.blue,
      initiallyExpanded: false,
      children: [
        _buildDetailRow(
          'Data utworzenia',
          DateFormat('dd-MM-yyyy HH:mm').format(quotation.createdAt.toLocal()),
          icon: Icons.calendar_today,
          iconColor: Colors.blue,
        ),
        _buildDetailRow(
          'Koszt całkowity',
          '${quotation.totalCost?.toStringAsFixed(2) ?? '0.00'} PLN',
          icon: Icons.attach_money,
          iconColor: Colors.green,
        ),
      ],
    );
  }
  Widget _buildClientDetailsCard(Client client) {
    return DetailsCardWidget(
      title: 'Szczegóły Klienta',
      subtitle: '${client.firstName} ${client.lastName}',
      icon: Icons.person,
      iconBackgroundColor: Colors.purple.shade100,
      iconColor: Colors.purple,
      trailing: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            _getInitials(client.firstName, client.lastName),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      children: [
        ClientProfileWidget(
          firstName: client.firstName,
          lastName: client.lastName,
          phone: client.phone,
          email: client.email,
          address: client.address,
          initials: _getInitials(client.firstName, client.lastName),
        ),
        
        const SizedBox(height: 16),
        Row(
          children: [
            if (client.phone != null && client.phone!.isNotEmpty)
              ContactButtonWidget(
                icon: Icons.phone,
                label: 'Zadzwoń',
                color: Colors.green,
                onPressed: () {
                  try {
                    final uri = Uri.parse('tel:${client.phone}');
                    launchUrl(uri);
                  } catch (e) {
                    debugPrint('Nie można wykonać połączenia: $e');
                  }
                },
              ),
            if (client.email.isNotEmpty)
              ContactButtonWidget(
                icon: Icons.email,
                label: 'Email',
                color: Colors.orange,
                onPressed: () {
                  try {
                    final uri = Uri.parse('mailto:${client.email}');
                    launchUrl(uri);
                  } catch (e) {
                    debugPrint('Nie można wysłać email: $e');
                  }
                },
              ),
            if (client.address != null && client.address!.isNotEmpty)
              ContactButtonWidget(
                icon: Icons.map,
                label: 'Mapa',
                color: Colors.blue,
                onPressed: () {
                  try {
                    final encodedAddress = Uri.encodeComponent(client.address!);
                    final uri = Uri.parse('https://maps.google.com/?q=$encodedAddress');
                    launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    debugPrint('Nie można otworzyć mapy: $e');
                  }
                },
              ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          'Email',
          client.email,
          icon: Icons.email,
          iconColor: Colors.orange,
        ),
        if (client.address != null)
          _buildDetailRow(
            'Adres',
            client.address ?? '',
            icon: Icons.home,
            iconColor: Colors.blue,
          ),
      ],
    );
  }
  Widget _buildVehicleDetailsCard(Vehicle vehicle) {
    return DetailsCardWidget(
      title: 'Dane Pojazdu',
      subtitle: '${vehicle.make} ${vehicle.model}',
      icon: Icons.directions_car,
      iconBackgroundColor: Colors.teal.shade50,
      iconColor: Colors.teal,
      children: [
        VehicleProfileWidget(
          make: vehicle.make,
          model: vehicle.model,
          licensePlate: vehicle.licensePlate,
        ),
        _buildDetailRow(
          'Nr. rejestracyjny',
          vehicle.licensePlate,
          icon: Icons.confirmation_number,
          iconColor: Colors.amber,
        ),
        _buildDetailRow(
          'VIN',
          vehicle.vin,
          icon: Icons.pin,
          iconColor: Colors.indigo,
        ),
        _buildDetailRow(
          'Rok produkcji',
          vehicle.year.toString(),
          icon: Icons.date_range,
          iconColor: Colors.green,
        ),
        _buildDetailRow(
          'Przebieg',
          '${vehicle.mileage} km',
          icon: Icons.speed,
          iconColor: Colors.red,
        ),
      ],
    );
  }
  Widget _buildCostSummaryCard(List<QuotationPart> parts) {
    final totalPartsCost = getTotalPartCost(parts);
    final totalServiceCost = getTotalServiceCost(parts);
    final totalMargin = getTotalMargin(parts);

    return CostSummaryWidget(
      totalPartsCost: totalPartsCost,
      totalServiceCost: totalServiceCost,
      totalMargin: totalMargin,
    );
  }

  Widget _buildContent(BuildContext context, Quotation quotation) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuotationDetailsCard(context, quotation),
          const SizedBox(height: 16.0),
          _buildVehicleDetailsCard(quotation.vehicle),
          const SizedBox(height: 16.0),
          _buildClientDetailsCard(quotation.client),
          const SizedBox(height: 16.0),
          _buildSectionTitle('Części i Usługi'),
          _buildAddPartForm(),
          const SizedBox(height: 16),
          _buildPartsTable(quotation.parts.cast<QuotationPart>()),
          const SizedBox(height: 16),
          _buildCostSummaryCard(quotation.parts.cast<QuotationPart>()),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _AppBarBuilder(
        onPrintPressed: _generatePdf,
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    return BlocConsumer<QuotationBloc, QuotationState>(
      listener: (context, state) {
        if (state is QuotationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is QuotationOperationSuccess || state is QuotationOperationSuccessWithDetails) {
          // Obsługa obu typów stanów sukcesu
          final message = state is QuotationOperationSuccess 
              ? state.message 
              : (state as QuotationOperationSuccessWithDetails).message;
              
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is QuotationUnauthenticated) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      buildWhen: (previous, current) {
        // Avoid rebuilding for operation success states that don't carry details
        if (previous is QuotationDetailsLoaded && current is QuotationOperationSuccess) {
          return false;
        }
        // Only rebuild for states that affect the UI
        return current is QuotationLoading || 
               current is QuotationDetailsLoaded || 
               current is QuotationOperationSuccessWithDetails || 
               current is QuotationError;
      },
      builder: (context, state) {
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
    _partNameController.dispose();
    _quantityController.dispose();
    _partCostController.dispose();
    _serviceCostController.dispose();
    _buyCostPartController.dispose();
    super.dispose();
  }
}

class _AppBarBuilder extends StatelessWidget implements PreferredSizeWidget {
  final Function(Quotation) onPrintPressed;

  const _AppBarBuilder({
    required this.onPrintPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: 'Wycena',
      feature: 'quotations',
      titleWidget: BlocBuilder<QuotationBloc, QuotationState>(
        buildWhen: (previous, current) {
          if (previous is QuotationLoading && current is QuotationLoading) {
            return false;
          }
          return true;
        },
        builder: (context, state) {
          if (state is QuotationDetailsLoaded) {
            final quotation = state.quotation;
            return Text(
              'Wycena ${quotation.quotationNumber} - ${quotation.vehicle.make} ${quotation.vehicle.model}', 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
            );
          } else if (state is QuotationOperationSuccessWithDetails) {
            final quotation = state.quotation;
            return Text(
              'Wycena ${quotation.quotationNumber} - ${quotation.vehicle.make} ${quotation.vehicle.model}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
            );
          }
          return const Text('Ładowanie...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20));
        },
      ),
      actions: _buildAppBarActions(context),
    );
  }
  
  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      BlocBuilder<QuotationBloc, QuotationState>(
        builder: (context, state) {
          if (state is! QuotationDetailsLoaded && state is! QuotationOperationSuccessWithDetails) {
            return const SizedBox.shrink();
          }
          
          final quotation = state is QuotationDetailsLoaded 
              ? state.quotation 
              : (state as QuotationOperationSuccessWithDetails).quotation;
          
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
