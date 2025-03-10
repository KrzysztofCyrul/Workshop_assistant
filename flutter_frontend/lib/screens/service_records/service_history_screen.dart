import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_record_provider.dart';
import '../../data/models/service_record.dart';

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
  _VehicleServiceHistoryScreenState createState() => _VehicleServiceHistoryScreenState();
}

class _VehicleServiceHistoryScreenState extends State<VehicleServiceHistoryScreen> {
  late Future<void> _serviceRecordsFuture;

  @override
  void initState() {
    super.initState();
    _serviceRecordsFuture = _fetchServiceRecords();
  }

  Future<void> _fetchServiceRecords() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;
    if (accessToken != null) {
      await Provider.of<ServiceRecordProvider>(context, listen: false)
          .fetchServiceRecords(accessToken, widget.workshopId, widget.vehicleId);
    } else {
      throw Exception('Brak dostępu do danych użytkownika.');
    }
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
      return const Center(child: Text('Brak rekordów serwisowych dla tego pojazdu.'));
    }

    return RefreshIndicator(
      onRefresh: _fetchServiceRecords,
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;

    if (accessToken == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Historia Serwisowa Pojazdu')),
        body: const Center(
          child: Text(
            'Brak dostępu do danych użytkownika.\nZaloguj się, aby wyświetlić historię serwisową.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final serviceRecordProvider = Provider.of<ServiceRecordProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historia Serwisowa Pojazdu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Odśwież',
            onPressed: _fetchServiceRecords,
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _serviceRecordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || serviceRecordProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Błąd: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _fetchServiceRecords,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Ponów próbę'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            if (serviceRecordProvider.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        serviceRecordProvider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _fetchServiceRecords,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Ponów próbę'),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return _buildServiceRecordsList(serviceRecordProvider.serviceRecords);
            }
          }
        },
      ),
    );
  }
}
