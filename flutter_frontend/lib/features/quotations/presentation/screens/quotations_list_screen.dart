import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/features/quotations/presentation/screens/quotation_details_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_frontend/features/quotations/presentation/bloc/quotation_bloc.dart';
import 'package:flutter_frontend/models/quotation.dart';
import 'package:flutter_frontend/features/quotations/presentation/screens/add_quotation_screen.dart';

class QuotationsListScreen extends StatefulWidget {
  static const routeName = '/quotations';
  final String workshopId;

  const QuotationsListScreen({
    super.key,
    required this.workshopId,
  });

  @override
  State<QuotationsListScreen> createState() => _QuotationsListScreenState();
}

class _QuotationsListScreenState extends State<QuotationsListScreen> {  @override
  void initState() {
    super.initState();
    _loadQuotations();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadQuotations();
  }
  
  @override
  void didUpdateWidget(QuotationsListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workshopId != widget.workshopId) {
      _loadQuotations();
    }
  }

  void _loadQuotations() {
    // Reset to initial state first to ensure we always load fresh data
    context.read<QuotationBloc>().add(ResetQuotationStateEvent());
    context.read<QuotationBloc>().add(
      LoadQuotationsEvent(workshopId: widget.workshopId),
    );
  }

  Future<void> _refreshQuotations() async {
    _loadQuotations();
    return Future.delayed(const Duration(milliseconds: 500));
  }

  void _navigateToAddQuotation() async {
    final result = await Navigator.pushNamed(
      context,
      AddQuotationScreen.routeName,
      arguments: {'workshopId': widget.workshopId},
    );

    if (result == true) {
      _refreshQuotations();
    }
  }
  void _navigateToQuotationDetails(String quotationId) async {
    await Navigator.pushNamed(
      context,
      QuotationDetailsScreen.routeName,
      arguments: {
        'workshopId': widget.workshopId,
        'quotationId': quotationId,
      },
    );
    
    // Reload quotations when returning from details screen
    _refreshQuotations();
  }
  void _confirmDeleteQuotation(String quotationId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber.shade700),
              const SizedBox(width: 12),
              const Text('Potwierdzenie usunięcia'),
            ],
          ),
          content: const Text(
            'Czy na pewno chcesz usunąć tę wycenę? Ta operacja jest nieodwracalna.',
            style: TextStyle(fontSize: 15),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('Anuluj'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete_forever, size: 18),
              label: const Text('Usuń wycenę'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red.shade600,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<QuotationBloc>().add(
                  DeleteQuotationEvent(
                    workshopId: widget.workshopId,
                    quotationId: quotationId,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
  Widget _buildQuotationItem(Quotation quotation) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToQuotationDetails(quotation.id),
        onLongPress: () => _confirmDeleteQuotation(quotation.id),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.description, size: 24, color: Colors.blue.shade700),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wycena: ${quotation.quotationNumber}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('dd.MM.yyyy, HH:mm').format(quotation.createdAt.toLocal()),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios, 
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${quotation.client.firstName} ${quotation.client.lastName}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.directions_car, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${quotation.vehicle.make} ${quotation.vehicle.model} (${quotation.vehicle.licensePlate})',
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Koszt: ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    '${quotation.totalCost?.toStringAsFixed(2) ?? '0.00'} zł',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.description_outlined, 
              size: 80, 
              color: Colors.blue.shade300
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Brak wycen',
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold, 
              color: Colors.blue.shade800
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Nie dodano jeszcze żadnych wycen dla tego warsztatu',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _navigateToAddQuotation,
            icon: const Icon(Icons.add),
            label: const Text('Dodaj pierwszą wycenę'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wyceny',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 3,
        centerTitle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Dodaj wycenę',
            onPressed: _navigateToAddQuotation,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Odśwież',
            onPressed: _refreshQuotations,
          ),
          const SizedBox(width: 8),
        ],
      ),body: BlocConsumer<QuotationBloc, QuotationState>(
        listener: (context, state) {
          if (state is QuotationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is QuotationOperationSuccess) {
            final isDeleteSuccess = state.message.contains('usunięta');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      isDeleteSuccess ? Icons.delete_forever : Icons.check_circle,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: isDeleteSuccess ? Colors.red.shade600 : Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.08,
                  left: 16,
                  right: 16,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
            _loadQuotations(); // Reload after successful operation
          }
          if (state is QuotationUnauthenticated) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
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
                      onPressed: _refreshQuotations,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Spróbuj ponownie'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is QuotationsLoaded) {
            if (state.quotations.isEmpty) {
              return _buildEmptyState();
            } else {
              return RefreshIndicator(
                onRefresh: _refreshQuotations,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: state.quotations.length,
                  itemBuilder: (context, index) {
                    return _buildQuotationItem(state.quotations[index]);
                  },
                ),
              );
            }
          } else {
            // Initial state or any other state
            return const Center(child: CircularProgressIndicator());
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
}