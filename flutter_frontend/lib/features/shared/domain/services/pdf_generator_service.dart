import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../workshop/domain/entities/workshop.dart';

/// Universal PDF generator service for appointments and quotations
class PdfGeneratorService {
  static const int maxRowsPerPage = 15; // Maximum items per page to avoid overflow

  Future<void> generateAndPrint({
    required PdfDocumentData documentData,
    required List<PdfTableItem> items,
  }) async {
    final pdf = pw.Document();

    final font = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(font);

    final boldFont = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
    final boldTtf = pw.Font.ttf(boldFont);

    // Calculate totals
    final totalPartsCost = _calculateTotalPartsCost(items);
    final totalServiceCost = _calculateTotalServiceCost(items);
    final totalCost = totalPartsCost + totalServiceCost;

    // Calculate how many pages we need
    final totalPages = items.isEmpty ? 1 : (items.length / maxRowsPerPage).ceil();
    
    for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      final startIndex = pageIndex * maxRowsPerPage;
      final endIndex = (startIndex + maxRowsPerPage < items.length) 
          ? startIndex + maxRowsPerPage 
          : items.length;
      
      final pageItems = items.isEmpty ? <PdfTableItem>[] : items.sublist(startIndex, endIndex);
      final isFirstPage = pageIndex == 0;
      final isLastPage = pageIndex == totalPages - 1;
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildPdfContent(
              documentData: documentData,
              items: pageItems,
              ttf: ttf,
              boldTtf: boldTtf,
              totalPartsCost: totalPartsCost,
              totalServiceCost: totalServiceCost,
              totalCost: totalCost,
              isFirstPage: isFirstPage,
              isLastPage: isLastPage,
              pageIndex: pageIndex + 1,
              totalPages: totalPages,
            );
          },
        ),
      );
    }

    final fileName = _generateFileName(documentData);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: fileName,
    );
  }

  pw.Widget _buildPdfContent({
    required PdfDocumentData documentData,
    required List<PdfTableItem> items,
    required pw.Font ttf,
    required pw.Font boldTtf,
    required double totalPartsCost,
    required double totalServiceCost,
    required double totalCost,
    required bool isFirstPage,
    required bool isLastPage,
    required int pageIndex,
    required int totalPages,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // Header only on first page
        if (isFirstPage) ...[
          _buildHeader(documentData, boldTtf),
          pw.SizedBox(height: 20),
          _buildInfoTable(documentData, ttf),
          pw.SizedBox(height: 20),
        ] else ...[
          // Page header for subsequent pages
          pw.Text(
            '${documentData.documentType} - Strona $pageIndex z $totalPages',
            style: pw.TextStyle(font: boldTtf, fontSize: 16),
          ),
          pw.SizedBox(height: 20),
        ],
        
        // Items table (always include header if there are items)
        if (items.isNotEmpty) _buildItemsTable(items, ttf, boldTtf, documentData.tableHeaders),
        
        // Spacer to push content down
        pw.Spacer(),
          // Summary only on last page
        if (isLastPage) ...[
          pw.SizedBox(height: 20),
          _buildSummaryTable(totalPartsCost, totalServiceCost, totalCost, ttf, boldTtf),
          pw.SizedBox(height: 20),
          _buildCompanyInfo(ttf, documentData.workshop),
        ],
      ],
    );
  }

  pw.Widget _buildHeader(PdfDocumentData documentData, pw.Font boldTtf) {
    return pw.Column(
      children: [
        pw.Text(
          documentData.title,
          style: pw.TextStyle(font: boldTtf, fontSize: 20),
        ),
        if (documentData.subtitle != null)
          pw.Text(
            documentData.subtitle!,
            style: pw.TextStyle(font: boldTtf, fontSize: 12),
          ),
      ],
    );
  }

  pw.Widget _buildInfoTable(PdfDocumentData documentData, pw.Font ttf) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: const {
        0: pw.FlexColumnWidth(1),
        1: pw.FlexColumnWidth(3),
      },
      children: documentData.infoRows.map((row) => _buildInfoRow(row.label, row.value, ttf)).toList(),
    );
  }

  pw.TableRow _buildInfoRow(String label, String value, pw.Font ttf) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6.0),
          child: pw.Text(label, style: pw.TextStyle(font: ttf)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6.0),
          child: pw.Text(value, style: pw.TextStyle(font: ttf)),
        ),
      ],
    );
  }

  pw.Widget _buildItemsTable(List<PdfTableItem> items, pw.Font ttf, pw.Font boldTtf, List<String> headers) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: const {
        0: pw.FlexColumnWidth(2),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1),
        3: pw.FlexColumnWidth(1),
        4: pw.FlexColumnWidth(1),
      },
      children: [
        _buildTableHeader(headers, boldTtf),
        ...items.map((item) => _buildItemRow(item, ttf)),
      ],
    );
  }

  pw.TableRow _buildTableHeader(List<String> headers, pw.Font boldTtf) {
    return pw.TableRow(
      children: headers
          .map((header) => pw.Padding(
                padding: const pw.EdgeInsets.all(6.0),
                child: pw.Text(header, style: pw.TextStyle(font: boldTtf)),
              ))
          .toList(),
    );
  }

  pw.TableRow _buildItemRow(PdfTableItem item, pw.Font ttf) {
    return pw.TableRow(
      children: [
        _buildTableCell(item.name, ttf),
        _buildTableCell(item.quantity.toString(), ttf),
        _buildTableCell(item.costPart.toStringAsFixed(2), ttf),
        _buildTableCell((item.costPart * item.quantity).toStringAsFixed(2), ttf),
        _buildTableCell(item.costService.toStringAsFixed(2), ttf),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, pw.Font ttf) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8.0),
      child: pw.Text(text, style: pw.TextStyle(font: ttf)),
    );
  }

  pw.Widget _buildSummaryTable(
    double totalPartsCost,
    double totalServiceCost,
    double totalCost,
    pw.Font ttf,
    pw.Font boldTtf,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(2),
      },
      children: [
        _buildSummaryRow('SUMA CZĘŚCI (PLN):', totalPartsCost, ttf, boldTtf),
        _buildSummaryRow('SUMA USŁUG (PLN):', totalServiceCost, ttf, boldTtf),
        _buildSummaryRow('CAŁKOWITA SUMA (PLN):', totalCost, ttf, boldTtf),
      ],
    );
  }

  pw.TableRow _buildSummaryRow(String label, double value, pw.Font ttf, pw.Font boldTtf) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6.0),
          child: pw.Text(label, style: pw.TextStyle(font: boldTtf)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6.0),
          child: pw.Text(value.toStringAsFixed(2), style: pw.TextStyle(font: ttf)),
        ),
      ],
    );
  }  pw.Widget _buildCompanyInfo(pw.Font ttf, Workshop workshop) {
    final companyInfo = <String>[
      workshop.name.isNotEmpty ? workshop.name : 'Warsztat',
      workshop.address.isNotEmpty ? workshop.address : '',
      workshop.postCode.isNotEmpty ? workshop.postCode : '',
      workshop.nipNumber.isNotEmpty ? 'NIP ${workshop.nipNumber}' : '',
      workshop.email.isNotEmpty ? workshop.email : '',
      workshop.phoneNumber.isNotEmpty ? workshop.phoneNumber : '',
    ].where((text) => text.isNotEmpty).toList();

    return pw.Column(
      children: companyInfo
          .map((text) => pw.Text(
                text,
                style: pw.TextStyle(font: ttf, fontSize: 14),
              ))
          .toList(),
    );
  }

  double _calculateTotalPartsCost(List<PdfTableItem> items) {
    return items.fold(0, (sum, item) => sum + (item.costPart * item.quantity));
  }

  double _calculateTotalServiceCost(List<PdfTableItem> items) {
    return items.fold(0, (sum, item) => sum + item.costService);
  }

  String _generateFileName(PdfDocumentData documentData) {
    return documentData.fileName;
  }
}

/// Data class for PDF document information
class PdfDocumentData {
  final String title;
  final String? subtitle;
  final String documentType;
  final List<PdfInfoRow> infoRows;
  final List<String> tableHeaders;
  final String fileName;
  final Workshop workshop;

  PdfDocumentData({
    required this.title,
    this.subtitle,
    required this.documentType,
    required this.infoRows,
    required this.tableHeaders,
    required this.fileName,
    required this.workshop,
  });
}

/// Data class for info table rows
class PdfInfoRow {
  final String label;
  final String value;

  PdfInfoRow({
    required this.label,
    required this.value,
  });
}

/// Data class for table items (parts/quotation items)
class PdfTableItem {
  final String name;
  final int quantity;
  final double costPart;
  final double costService;

  PdfTableItem({
    required this.name,
    required this.quantity,
    required this.costPart,
    required this.costService,
  });
}
