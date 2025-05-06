import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../entities/appointment.dart';
import '../entities/part.dart';
import '../entities/repair_item.dart';

class AppointmentPdfGenerator {
  Future<void> generateAndPrint(
    Appointment appointment,
    List<Part> parts,
    List<RepairItem> repairItems,
  ) async {
    final pdf = pw.Document();

    final font = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(font);

    final boldFont = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
    final boldTtf = pw.Font.ttf(boldFont);

    final totalPartsCost = _calculateTotalPartsCost(parts);
    final totalServiceCost = _calculateTotalServiceCost(parts);
    final totalCost = totalPartsCost + totalServiceCost;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return _buildPdfContent(
            appointment: appointment,
            parts: parts,
            ttf: ttf,
            boldTtf: boldTtf,
            totalPartsCost: totalPartsCost,
            totalServiceCost: totalServiceCost,
            totalCost: totalCost,
          );
        },
      ),
    );

    final fileName = _generateFileName(appointment);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: fileName,
    );
  }

  pw.Widget _buildPdfContent({
    required Appointment appointment,
    required List<Part> parts,
    required pw.Font ttf,
    required pw.Font boldTtf,
    required double totalPartsCost,
    required double totalServiceCost,
    required double totalCost,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        _buildHeader(appointment, boldTtf),
        pw.SizedBox(height: 20),
        _buildVehicleAndClientInfo(appointment, ttf),
        pw.SizedBox(height: 20),
        _buildPartsTable(parts, ttf, boldTtf),
        pw.SizedBox(height: 20),
        _buildSummaryTable(totalPartsCost, totalServiceCost, totalCost, ttf, boldTtf),
        pw.SizedBox(height: 20),
        _buildCompanyInfo(ttf),
      ],
    );
  }

  pw.Widget _buildHeader(Appointment appointment, pw.Font boldTtf) {
    return pw.Text(
      'ZLECENIE NAPRAWY - ${DateFormat('dd.MM.yyyy').format(appointment.scheduledTime.toLocal())}',
      style: pw.TextStyle(font: boldTtf, fontSize: 20),
    );
  }

  pw.Widget _buildVehicleAndClientInfo(Appointment appointment, pw.Font ttf) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        _buildInfoRow('Pojazd:', 
          '${appointment.vehicle.licensePlate} ${appointment.vehicle.make} ${appointment.vehicle.model}',
          ttf),
        _buildInfoRow('Numer telefonu:', '${appointment.client.phone}', ttf),
      ],
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

  pw.Widget _buildPartsTable(List<Part> parts, pw.Font ttf, pw.Font boldTtf) {
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
        _buildPartsTableHeader(boldTtf),
        ...parts.map((part) => _buildPartRow(part, ttf)),
      ],
    );
  }

  pw.TableRow _buildPartsTableHeader(pw.Font boldTtf) {
    final headers = ['DO ZROBIENIA', 'ILOŚĆ', 'CZĘŚCI (PLN)', 'RAZEM (PLN)', 'USŁUGA (PLN)'];
    return pw.TableRow(
      children: headers.map((header) => pw.Padding(
        padding: const pw.EdgeInsets.all(6.0),
        child: pw.Text(header, style: pw.TextStyle(font: boldTtf)),
      )).toList(),
    );
  }

  pw.TableRow _buildPartRow(Part part, pw.Font ttf) {
    return pw.TableRow(
      children: [
        _buildTableCell(part.name, ttf),
        _buildTableCell(part.quantity.toString(), ttf),
        _buildTableCell(part.costPart.toStringAsFixed(2), ttf),
        _buildTableCell((part.costPart * part.quantity).toStringAsFixed(2), ttf),
        _buildTableCell(part.costService.toStringAsFixed(2), ttf),
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
  }

  pw.Widget _buildCompanyInfo(pw.Font ttf) {
    final companyInfo = [
      'IN-CARS Beata Inglot',
      'Malawa 827',
      '36–007 Krasne',
      'NIP 8131190318',
      'serwisincars@gmail.com',
    ];

    return pw.Column(
      children: companyInfo.map((text) => pw.Text(
        text,
        style: pw.TextStyle(font: ttf, fontSize: 14),
      )).toList(),
    );
  }

  double _calculateTotalPartsCost(List<Part> parts) {
    return parts.fold(0, (sum, part) => sum + (part.costPart * part.quantity));
  }

  double _calculateTotalServiceCost(List<Part> parts) {
    return parts.fold(0, (sum, part) => sum + part.costService);
  }

  String _generateFileName(Appointment appointment) {
    return '${appointment.vehicle.make}_${appointment.vehicle.model}_${DateFormat('ddMMyyyy').format(appointment.scheduledTime.toLocal())}.pdf';
  }
}