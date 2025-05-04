import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/vehicle_bloc.dart';
import '../../domain/entities/service_record.dart';

class VehicleServiceHistoryScreen extends StatefulWidget {
  static const routeName = '/vehicle-service-history';

  final String workshopId;
  final String vehicleId;

  const VehicleServiceHistoryScreen({
    super.key,
    required this.workshopId,
    required this.vehicleId,
  });

  @override
  State<VehicleServiceHistoryScreen> createState() => _VehicleServiceHistoryScreenState();
}

class _VehicleServiceHistoryScreenState extends State<VehicleServiceHistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadServiceRecords();
  }

  void _loadServiceRecords() {
    context.read<VehicleBloc>().add(
          LoadServiceRecordsEvent(
            workshopId: widget.workshopId,
            vehicleId: widget.vehicleId,
          ),
        );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('yyyy-MM-dd HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildServiceRecordsList(List<ServiceRecord> records) {
    if (records.isEmpty) {
      return const Center(
        child: Text('Brak rekordów serwisowych dla tego pojazdu.'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadServiceRecords(),
      child: ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text('Data: ${record.date}, Przebieg: ${record.mileage} km'),
              subtitle: Text(record.description),
              trailing: Text(_formatDate(record.createdAt)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadServiceRecords,
              icon: const Icon(Icons.refresh),
              label: const Text('Ponów próbę'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historia Serwisowa Pojazdu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Odśwież',
            onPressed: _loadServiceRecords,
          ),
        ],
      ),
      body: BlocBuilder<VehicleBloc, VehicleState>(
        builder: (context, state) {
          return switch (state) {
            VehicleLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            ServiceRecordsLoaded(serviceRecords: final records) => 
              _buildServiceRecordsList(records),
            VehicleError(message: final message) => 
              _buildErrorView(message),
            VehicleUnauthenticated() => _buildErrorView(
                'Brak dostępu do danych użytkownika.\nZaloguj się, aby wyświetlić historię serwisową.',
              ),
            _ => const Center(
                child: Text('Nieoczekiwany błąd. Spróbuj ponownie później.'),
              ),
          };
        },
      ),
    );
  }
}
