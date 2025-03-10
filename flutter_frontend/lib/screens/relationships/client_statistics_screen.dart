import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../providers/auth_provider.dart';
import '../../services/client_service.dart';
import '../../services/appointment_service.dart';
import '../../data/models/client.dart';
import '../../data/models/appointment.dart';

// Plik z klasą SegmentColors
import '../../core/utils/colors.dart';

class ClientsStatisticsScreen extends StatefulWidget {
  static const routeName = '/clients-statistics';

  const ClientsStatisticsScreen({super.key});

  @override
  _ClientsStatisticsScreenState createState() => _ClientsStatisticsScreenState();
}

class _ClientsStatisticsScreenState extends State<ClientsStatisticsScreen> {
  // Asynchroniczne ładowanie danych
  late Future<void> _futureData;

  // Listy klientów i wizyt
  List<Client> _clients = [];
  List<Appointment> _appointments = [];

  // Błąd (jeżeli wystąpi)
  String? _errorMessage;

  // Statystyki
  Map<String, int> _clientSegmentCounts = {};
  Map<String, double> _segmentTotalValues = {};
  Map<String, double> _segmentAverageValues = {};

  // Filtry
  late int _selectedMonth;
  late int _selectedYear;
  bool _showWholeYear = false;

  @override
  void initState() {
    super.initState();
    // Ustaw domyślnie bieżący miesiąc i rok
    _selectedMonth = DateTime.now().month;
    _selectedYear = DateTime.now().year;

    // Ładujemy ewentualne zapisane kolory z SharedPreferences 
    // (jeśli chcesz, można też wywołać to w main.dart).
    SegmentColors.loadColors().then((_) {
      setState(() {});
    });

    // Ładujemy dane
    _futureData = _loadData();
  }

  /// Metoda główna: pobiera wszystkich klientów i wizyty, filtruje po dacie, oblicza statystyki.
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
      final results = await Future.wait([
        ClientService.getClients(accessToken, workshopId),
        AppointmentService().getAppointments(accessToken, workshopId),
      ]);

      final allClients = results[0] as List<Client>;
      final allAppointments = results[1] as List<Appointment>;

      _clients = allClients;

      // Filtruj wizyty po roku / miesiącu (chyba że "cały rok").
      final filteredAppointments = allAppointments.where((appt) {
        final d = appt.createdAt;
        if (_showWholeYear) {
          return d.year == _selectedYear;
        } else {
          return d.year == _selectedYear && d.month == _selectedMonth;
        }
      }).toList();

      _appointments = filteredAppointments;

      _calculateStatistics();

      setState(() {
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Błąd podczas pobierania danych: $e';
      });
    }
  }

  /// Obliczanie danych statystycznych
  void _calculateStatistics() {
    _clientSegmentCounts = {};
    _segmentTotalValues = {};
    _segmentAverageValues = {};

    // Zlicz klientów w segmentach
    for (var client in _clients) {
      final segment = client.segment ?? 'Brak segmentu';
      _clientSegmentCounts[segment] = (_clientSegmentCounts[segment] ?? 0) + 1;
    }

    // Suma i średnia kosztów wizyt w segmentach
    final Map<String, List<double>> segmentValues = {};
    for (var appointment in _appointments) {
      final segment = appointment.client.segment ?? 'Brak segmentu';
      final totalCost = appointment.repairItems.fold<double>(
        0.0,
        (prev, item) => prev,
      );
      segmentValues.putIfAbsent(segment, () => []).add(totalCost);
    }

    segmentValues.forEach((segment, costs) {
      final total = costs.fold<double>(0.0, (prev, cost) => prev + cost);
      final average = costs.isNotEmpty ? total / costs.length : 0.0;
      _segmentTotalValues[segment] = total;
      _segmentAverageValues[segment] = average;
    });

    // Uzupełnij brakujące segmenty zerami
    for (final segment in _clientSegmentCounts.keys) {
      _segmentTotalValues.putIfAbsent(segment, () => 0.0);
      _segmentAverageValues.putIfAbsent(segment, () => 0.0);
    }
  }

  /// Funkcja pomocnicza do skracania nazw (opcjonalne)
  String getDisplaySegmentName(String segment) {
    // np. 'A' -> 'Segment A', 'B' -> 'Segment B', itp.
    // Lub 'Brak segmentu' -> 'BS'...
    switch (segment) {
      case 'A':
        return 'Segment A';
      case 'B':
        return 'Segment B';
      case 'C':
        return 'Segment C';
      case 'D':
        return 'Segment D';
      case 'Brak segmentu':
        return 'Brak';
      default:
        return segment;
    }
  }

  /// Mapa: segment -> kolor (korzystamy z SegmentColors)
  Color getSegmentColor(String segment) {
    switch (segment) {
      case 'A':
        return SegmentColors.segmentA;
      case 'B':
        return SegmentColors.segmentB;
      case 'C':
        return SegmentColors.segmentC;
      case 'D':
        return SegmentColors.segmentD;
      case 'Brak segmentu':
        return SegmentColors.defaultColor;
      default:
        return SegmentColors.defaultColor;
    }
  }

  /// Element legendy (kolor + nazwa + %)
  Widget _buildLegendItem({
    required String segment,
    required double percentage,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: getSegmentColor(segment),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${getDisplaySegmentName(segment)}: ${percentage.toStringAsFixed(1)}%',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  /// Budowa sekcji wykresu kołowego
  List<PieChartSectionData> _buildPieChartSections(
    Map<String, int> segmentCounts,
    int totalClients,
  ) {
    // Zamieniamy mapę na listę par segment->liczba
    final entries = segmentCounts.entries.toList();

    // Sortujemy malejąco po liczbie klientów
    entries.sort((a, b) => b.value.compareTo(a.value));

    return List.generate(entries.length, (index) {
      final segment = entries[index].key;
      final count = entries[index].value;

      // Unikamy dzielenia przez 0
      final fraction = totalClients == 0 ? 0.0 : count / totalClients;

      return PieChartSectionData(
        color: getSegmentColor(segment), // kluczowe
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

  /// Reset filtrów
  void _resetFilters() {
    setState(() {
      _selectedMonth = DateTime.now().month;
      _selectedYear = DateTime.now().year;
      _showWholeYear = false;
      _futureData = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Przygotuj dane do wyświetlenia
    final totalClients = _clients.length;
    final segmentCounts = _clientSegmentCounts;
    final pieSections = _buildPieChartSections(segmentCounts, totalClients);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statystyki Klientów'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _futureData = _loadData();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _futureData,
        builder: (context, snapshot) {
          // 1. Loader w trakcie pobierania danych
          if (snapshot.connectionState == ConnectionState.waiting && _clients.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Obsługa błędów
          if (_errorMessage != null) {
            return Center(child: Text(_errorMessage!));
          }
          // 3. Brak klientów
          if (_clients.isEmpty) {
            return const Center(child: Text('Brak klientów'));
          }

          // Filtry czasu
          final List<int> months = List.generate(12, (i) => i + 1);
          final currentYear = DateTime.now().year;
          final List<int> years = List.generate(11, (i) => currentYear - 5 + i);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Filtry (rok, cały rok, miesiąc) ---
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: _selectedYear,
                                decoration: const InputDecoration(
                                  labelText: 'Rok',
                                  border: OutlineInputBorder(),
                                ),
                                items: years.map((year) {
                                  return DropdownMenuItem<int>(
                                    value: year,
                                    child: Text(year.toString()),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedYear = value;
                                      _futureData = _loadData();
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _showWholeYear,
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          _showWholeYear = val;
                                          _futureData = _loadData();
                                        });
                                      }
                                    },
                                  ),
                                  const Expanded(
                                    child: Text('Cały rok'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: IgnorePointer(
                                ignoring: _showWholeYear,
                                child: Opacity(
                                  opacity: _showWholeYear ? 0.5 : 1.0,
                                  child: DropdownButtonFormField<int>(
                                    value: _selectedMonth,
                                    decoration: const InputDecoration(
                                      labelText: 'Miesiąc',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: months.map((m) {
                                      return DropdownMenuItem<int>(
                                        value: m,
                                        child: Text(m.toString()),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null && !_showWholeYear) {
                                        setState(() {
                                          _selectedMonth = value;
                                          _futureData = _loadData();
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _resetFilters,
                              child: const Text('Reset'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // --- Tabela DataTable: segment, liczba, suma, średnia ---
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
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
                                  label: SizedBox(
                                    width: screenWidth * 0.2,
                                    child: const Text(
                                      'Seg.',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: screenWidth * 0.2,
                                    child: const Text(
                                      'Liczba',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: screenWidth * 0.3,
                                    child: const Text(
                                      'Sum (PLN)',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: screenWidth * 0.3,
                                    child: const Text(
                                      'Avg (PLN)',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                              rows: _clientSegmentCounts.keys.map((segment) {
                                final count = _clientSegmentCounts[segment] ?? 0;
                                final totalValue = _segmentTotalValues[segment] ?? 0.0;
                                final averageValue = _segmentAverageValues[segment] ?? 0.0;
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

                // --- Wykres słupkowy (łączna wartość w segmentach) ---
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Łączna Wartość Klientów\n'
                          '${_showWholeYear ? 'Rok: $_selectedYear' : 'Mies. $_selectedMonth/$_selectedYear'}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                                    final segKey = segmentCounts.keys.elementAt(group.x.toInt());
                                    final segValue = rod.toY.toStringAsFixed(2);
                                    return BarTooltipItem(
                                      '${getDisplaySegmentName(segKey)}\n',
                                      const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: segValue,
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
                                      final index = value.toInt();
                                      if (index < segmentCounts.keys.length) {
                                        final seg = segmentCounts.keys.elementAt(index);
                                        return Text(
                                          getDisplaySegmentName(seg),
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      }
                                      return const Text('');
                                    },
                                    reservedSize: 30,
                                    interval: 1,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: false,
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
                              barGroups: segmentCounts.keys
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final index = entry.key;
                                final segment = entry.value;
                                final totalValue = _segmentTotalValues[segment] ?? 0.0;

                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      fromY: 0,
                                      toY: totalValue,
                                      color: getSegmentColor(segment), // kluczowe
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
                        // Legenda do wykresu słupkowego
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: segmentCounts.keys.map((segment) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: getSegmentColor(segment),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(getDisplaySegmentName(segment)),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // --- Wykres kołowy (podział klientów) ---
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          _showWholeYear
                              ? 'Procentowy podział klientów (rok $_selectedYear)'
                              : 'Procentowy podział klientów (mies. $_selectedMonth/$_selectedYear)',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 250,
                          child: PieChart(
                            // Klucz można dodać, jeśli chcesz
                            // key: ValueKey(_appointments),
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
                        // Legenda
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: pieSections.asMap().entries.map((entry) {
                            int index = entry.key;
                            // segment wyciągamy z posortowanej listy
                            final segment = segmentCounts.entries.toList()[index].key;
                            final segCount = segmentCounts[segment] ?? 0;
                            double percentage = 0;
                            if (totalClients > 0) {
                              percentage = (segCount / totalClients) * 100;
                            }
                            return _buildLegendItem(
                              segment: segment,
                              percentage: percentage,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                
                // --- Podsumowanie liczby klientów ---
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
              ],
            ),
          );
        },
      ),
    );
  }
}
