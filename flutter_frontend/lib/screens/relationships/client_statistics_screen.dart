import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../services/client_service.dart';
import '../../services/appointment_service.dart';
import '../../models/client.dart';
import '../../models/appointment.dart';

class ClientsStatisticsScreen extends StatefulWidget {
  static const routeName = '/clients-statistics';

  const ClientsStatisticsScreen({Key? key}) : super(key: key);

  @override
  _ClientsStatisticsScreenState createState() => _ClientsStatisticsScreenState();
}

class _ClientsStatisticsScreenState extends State<ClientsStatisticsScreen> {
  late Future<void> _futureData;
  List<Client> _clients = [];
  List<Appointment> _appointments = [];
  String? _errorMessage;

  Map<String, int> _clientSegmentCounts = {};
  Map<String, double> _segmentTotalValues = {};
  Map<String, double> _segmentAverageValues = {};

  @override
  void initState() {
    super.initState();
    _futureData = _loadData();
  }

  String getDisplaySegmentName(String segment) {
  const Map<String, String> segmentAbbreviations = {
    'Brak segmentu': 'BS',
  };

  return segmentAbbreviations[segment] ?? segment;
}


  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;
    final workshopId = authProvider.user?.employeeProfiles.first.workshopId;

    if (accessToken == null || workshopId == null) {
      setState(() {
        _errorMessage = 'Brak tokenu lub warsztatu';
      });
      return;
    }

    try {
      // Pobierz klientów i wizyty równolegle
      final results = await Future.wait([
        ClientService.getClients(accessToken, workshopId),
        AppointmentService.getAppointments(accessToken, workshopId),
      ]);

      _clients = results[0] as List<Client>;
      _appointments = results[1] as List<Appointment>;

      _calculateStatistics();
    } catch (e) {
      setState(() {
        _errorMessage = 'Błąd podczas pobierania danych: $e';
      });
    }
  }

  void _calculateStatistics() {
    // Inicjalizacja map
    _clientSegmentCounts = {};
    _segmentTotalValues = {};
    _segmentAverageValues = {};

    // Grupowanie klientów według segmentów
    for (var client in _clients) {
      final segment = client.segment ?? 'Brak segmentu';
      if (_clientSegmentCounts.containsKey(segment)) {
        _clientSegmentCounts[segment] = _clientSegmentCounts[segment]! + 1;
      } else {
        _clientSegmentCounts[segment] = 1;
      }
    }

    // Grupowanie wizyt według segmentów klientów
    Map<String, List<double>> segmentValues = {};

    for (var appointment in _appointments) {
      final segment = appointment.client.segment ?? 'Brak segmentu';
      // Suma kosztów wszystkich napraw w wizycie
      final totalCost = appointment.repairItems.fold<double>(
          0.0, (previousValue, item) => previousValue + item.cost);
      
      if (segmentValues.containsKey(segment)) {
        segmentValues[segment]!.add(totalCost);
      } else {
        segmentValues[segment] = [totalCost];
      }
    }

    // Obliczanie łącznych i średnich wartości
    segmentValues.forEach((segment, costs) {
      final total = costs.fold<double>(0.0, (prev, cost) => prev + cost);
      final average = costs.isNotEmpty ? total / costs.length : 0.0;

      _segmentTotalValues[segment] = total;
      _segmentAverageValues[segment] = average;
    });

    // Upewnij się, że segmenty bez wizyt mają 0 wartości
    _clientSegmentCounts.keys.forEach((segment) {
      _segmentTotalValues.putIfAbsent(segment, () => 0.0);
      _segmentAverageValues.putIfAbsent(segment, () => 0.0);
    });
  }

  Map<String, int> _countClientsBySegment() {
    return _clientSegmentCounts;
  }

  Map<String, double> _getSegmentTotalValues() {
    return _segmentTotalValues;
  }

  Map<String, double> _getSegmentAverageValues() {
    return _segmentAverageValues;
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, int> segmentCounts, int total) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.brown,
      Colors.indigo,
      Colors.cyan,
      Colors.pink,
    ];

    final entries = segmentCounts.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    return List.generate(entries.length, (index) {
      final count = entries[index].value;
      final fraction = count / total;

      return PieChartSectionData(
        color: index < colors.length ? colors[index] : Colors.black,
        value: fraction * 100,
        title: '${(fraction * 100).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildLegendItem({required String title, required double percentage, required Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$title: ${percentage.toStringAsFixed(1)}%',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statystyki Klientów'),
      ),
      body: FutureBuilder<void>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _clients.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (_errorMessage != null) {
            return Center(child: Text(_errorMessage!));
          } else if (_clients.isEmpty) {
            return const Center(child: Text('Brak klientów'));
          }

          final segmentCounts = _countClientsBySegment();
          final segmentTotalValues = _getSegmentTotalValues();
          final segmentAverageValues = _getSegmentAverageValues();
          final totalClients = _clients.length;

          // Przygotuj dane do wykresu
          final pieSections = _buildPieChartSections(segmentCounts, totalClients);
          final colors = [
            Colors.blue,
            Colors.red,
            Colors.green,
            Colors.orange,
            Colors.purple,
            Colors.teal,
            Colors.brown,
            Colors.indigo,
            Colors.cyan,
            Colors.pink,
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Podsumowanie liczby klientów
                Card(
                  color: Colors.blue.shade50,
                  elevation: 3,
                  child: ListTile(
                    leading: const Icon(Icons.group, color: Colors.blue, size: 40),
                    title: const Text(
                      'Łączna liczba klientów',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '$totalClients',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Wykres kołowy z legendą
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Procentowy podział klientów według segmentu',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 250,
                          child: PieChart(
                            PieChartData(
                              sections: pieSections,
                              centerSpaceRadius: 40,
                              sectionsSpace: 4,
                              borderData: FlBorderData(show: false),
                              pieTouchData: PieTouchData(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Legenda pod wykresem
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: pieSections.asMap().entries.map((entry) {
                            int index = entry.key;
                            String segment = segmentCounts.keys.elementAt(index);
                            return _buildLegendItem(
                              title: segment,
                              percentage: (segmentCounts[segment]! / totalClients) * 100,
                              color: index < colors.length ? colors[index] : Colors.black,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Lista segmentów z liczbą klientów, łączną wartością i średnią wartością
Card(
  elevation: 3,
  child: Padding(
    padding: const EdgeInsets.all(8.0), // Reduced padding
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Szczegóły segmentów',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            return DataTable(
              headingRowHeight: 25,
              dataRowHeight: 25,
              columnSpacing: 8,
              columns: [
                DataColumn(
                  label: Container(
                    width: screenWidth * 0.2,
                    child: const Text(
                      'Seg.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataColumn(
                  label: Container(
                    width: screenWidth * 0.2,
                    child: const Text(
                      'Liczba',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataColumn(
                  label: Container(
                    width: screenWidth * 0.3,
                    child: const Text(
                      'Sum (PLN)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataColumn(
                  label: Container(
                    width: screenWidth * 0.3,
                    child: const Text(
                      'Avg (PLN)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              rows: segmentCounts.keys.map((segment) {
                final count = segmentCounts[segment]!;
                final totalValue = segmentTotalValues[segment] ?? 0.0;
                final averageValue = segmentAverageValues[segment] ?? 0.0;
                final displaySegment = getDisplaySegmentName(segment);
                return DataRow(cells: [
                  DataCell(
                    Text(
                      displaySegment,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Text(
                      '$count',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Text(
                      totalValue.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Text(
                      averageValue.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]);
              }).toList(),
            );
          },
        ),
      ],
    ),
  ),
),
const SizedBox(height: 20),


                // Opcjonalnie: Wykres słupkowy pokazujący łączną wartość per segment
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Łączna Wartość Klientów według Segmentu',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 300,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: _segmentTotalValues.values.isNotEmpty
                                  ? (_segmentTotalValues.values.reduce((a, b) => a > b ? a : b) * 1.2)
                                  : 100,
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  tooltipPadding: const EdgeInsets.all(8.0),
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    String segment = segmentCounts.keys.elementAt(group.x.toInt());
                                    return BarTooltipItem(
                                      '$segment\n',
                                      const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: rod.toY.toStringAsFixed(2),
                                          style: const TextStyle(
                                            color: Colors.yellow,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (double value, TitleMeta meta) {
                                      if (value.toInt() < segmentCounts.keys.length) {
                                        return Text(segmentCounts.keys.elementAt(value.toInt()));
                                      }
                                      return const Text('');
                                    },
                                    reservedSize: 30,
                                    interval: 1,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (double value, TitleMeta meta) {
                                      if (value == 0) {
                                        return const Text('0');
                                      } else if (value % 5000 == 0) {
                                        return Text(value.toInt().toString());
                                      }
                                      return const Text('');
                                    },
                                    reservedSize: 40,
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: segmentCounts.keys.toList().asMap().entries.map((entry) {
                                int index = entry.key;
                                String segment = entry.value;
                                double totalValue = segmentTotalValues[segment] ?? 0.0;
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      fromY: 0,
                                      toY: totalValue,
                                      color: colors[index % colors.length],
                                      width: 22,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(segmentCounts.keys.length, (index) {
                            String segment = segmentCounts.keys.elementAt(index);
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: colors[index % colors.length],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(segment),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
