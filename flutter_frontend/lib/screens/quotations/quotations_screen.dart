import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/quotation.dart';
import '../../services/quotation_service.dart';
import 'package:intl/intl.dart';
import 'quotation_details_screen.dart';
import 'add_quotation_screen.dart';

class QuotationsScreen extends StatefulWidget {
  static const routeName = '/quotations';

  const QuotationsScreen({super.key});

  @override
  _QuotationsScreenState createState() => _QuotationsScreenState();
}

class _QuotationsScreenState extends State<QuotationsScreen> {
  late Future<List<Quotation>> _quotationsFuture;
  String? _workshopId;

  @override
  void initState() {
    super.initState();
    _quotationsFuture = _fetchQuotations();
  }

  Future<List<Quotation>> _fetchQuotations() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      throw Exception('Brak danych użytkownika');
    }

    bool isWorkshopOwner = user.roles.contains('workshop_owner');
    bool isAssignedToWorkshop = user.employeeProfiles.isNotEmpty;

    if (isWorkshopOwner && isAssignedToWorkshop) {
      final employee = user.employeeProfiles.first;
      _workshopId = employee.workshopId;

      if (_workshopId == null) {
        throw Exception('Brak ID warsztatu');
      }

      List<Quotation> quotations = await QuotationService.getQuotations(
        authProvider.accessToken!,
        _workshopId!,
      );

      quotations.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return quotations;
    } else {
      throw Exception('Nie masz uprawnień do wyświetlenia tej strony');
    }
  }

  Future<void> _refreshQuotations() async {
    setState(() {
      _quotationsFuture = _fetchQuotations();
    });
  }

  Future<void> _deleteQuotation(String quotationId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;

    if (accessToken == null || _workshopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Brak wymaganych danych do usunięcia wyceny')),
      );
      return;
    }

    try {
      await QuotationService.deleteQuotation(accessToken, _workshopId!, quotationId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wycena została usunięta')),
      );
      _refreshQuotations();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas usuwania wyceny: $e')),
      );
    }
  }

  void _confirmDeleteQuotation(String quotationId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Potwierdzenie usunięcia'),
          content: const Text('Czy na pewno chcesz usunąć tę wycenę?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteQuotation(quotationId);
              },
              child: const Text('Usuń'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wyceny'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Dodaj wycenę',
            onPressed: _navigateToAddQuotation,
          ),
        ],
      ),
      body: FutureBuilder<List<Quotation>>(
        future: _quotationsFuture,
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
                      onPressed: _refreshQuotations,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Ponów próbę'),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Brak wycen.',
                style: TextStyle(fontSize: 16),
              ),
            );
          } else {
            final quotations = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshQuotations,
              child: ListView.separated(
                padding: const EdgeInsets.all(8.0),
                itemCount: quotations.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  return _buildQuotationItem(quotations[index]);
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddQuotation,
        tooltip: 'Dodaj wycenę',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuotationItem(Quotation quotation) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: const Icon(Icons.description, size: 40, color: Colors.blue),
        title: Text(
          'Wycena: ${quotation.quotationNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Klient: ${quotation.client.firstName} ${quotation.client.lastName}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Pojazd: ${quotation.vehicle.make} ${quotation.vehicle.model}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Data: ${DateFormat('dd-MM-yyyy HH:mm').format(quotation.createdAt.toLocal())}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Koszt całkowity: ${quotation.totalCost?.toStringAsFixed(2) ?? '0.00'} zł',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (_workshopId != null) {
            Navigator.pushNamed(
              context,
              QuotationDetailsScreen.routeName,
              arguments: {
                'workshopId': _workshopId!,
                'quotationId': quotation.id,
              },
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Brak wymaganych danych do nawigacji')),
            );
          }
        },
        onLongPress: () {
          _confirmDeleteQuotation(quotation.id);
        },
      ),
    );
  }

  void _navigateToAddQuotation() async {
    final result = await Navigator.pushNamed(
      context,
      AddQuotationScreen.routeName,
    );

    if (result == true) {
      _refreshQuotations();
    }
  }
}