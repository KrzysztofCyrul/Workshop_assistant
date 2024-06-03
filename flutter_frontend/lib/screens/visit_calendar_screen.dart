import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/visit_provider.dart';
import '../models/visit.dart';
import 'add_visit_screen.dart';

class VisitCalendarScreen extends StatefulWidget {
  @override
  _VisitCalendarScreenState createState() => _VisitCalendarScreenState();
}

class _VisitCalendarScreenState extends State<VisitCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Visit>> _visitsMap = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    Provider.of<VisitProvider>(context, listen: false).fetchVisits().then((_) {
      setState(() {
        _visitsMap = _getVisitsMap(Provider.of<VisitProvider>(context, listen: false).visits);
      });
    });
  }

  Map<DateTime, List<Visit>> _getVisitsMap(List<Visit> visits) {
    Map<DateTime, List<Visit>> map = {};
    for (var visit in visits) {
      DateTime visitDate = DateFormat('yyyy-MM-dd').parse(visit.date);
      DateTime key = DateTime(visitDate.year, visitDate.month, visitDate.day); // Normalize the date
      if (!map.containsKey(key)) {
        map[key] = [];
      }
      map[key]!.add(visit);
    }
    // print('Visits Map: $map');  // Debug statement
    return map;
  }

  Color _getDayColor(int visitCount) {
    if (visitCount == 0 || visitCount == 1) {
      return Colors.green;
    } else if (visitCount == 2 || visitCount == 3) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this visit?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text('Confirm'),
            onPressed: () {
              Provider.of<VisitProvider>(context, listen: false).deleteVisit(id);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            headerStyle: HeaderStyle(
              formatButtonVisible : false,
            ),
            focusedDay: _focusedDay,
            firstDay: DateTime(2000),
            lastDay: DateTime(2101),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              DateTime key = DateTime(day.year, day.month, day.day); // Normalize the date
              return _visitsMap[key] ?? [];
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  int visitCount = events.length;
                  return Positioned(
                    // right: 1,
                    bottom: 1,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getDayColor(visitCount),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$visitCount',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  );
                } else {
                  return null;
                }
              },
            ),
          ),
          Expanded(
            child: Consumer<VisitProvider>(
              builder: (context, visitProvider, child) {
                if (visitProvider.loading) {
                  return Center(child: CircularProgressIndicator());
                } else if (visitProvider.error != null) {
                  return Center(child: Text('Failed to load data: ${visitProvider.error}'));
                } else {
                  final visits = visitProvider.visits.where((visit) => visit.date == DateFormat('yyyy-MM-dd').format(_selectedDay!)).toList();
                  return ListView.builder(
                    itemCount: visits.length,
                    itemBuilder: (context, index) {
                      final visit = visits[index];
                      return VisitItem(visit: visit);
                    },
                  );
                }
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddVisitScreen(date: _selectedDay)),
              ).then((_) {
                Provider.of<VisitProvider>(context, listen: false).fetchVisits();
              });
            },
            child: Text('Add Visit'),
          ),
        ],
      ),
    );
  }
}

class VisitItem extends StatefulWidget {
  final Visit visit;

  VisitItem({required this.visit});

  @override
  _VisitItemState createState() => _VisitItemState();
}

class _VisitItemState extends State<VisitItem> {
  bool _isExpanded = false;

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this visit?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text('Confirm'),
            onPressed: () {
              Provider.of<VisitProvider>(context, listen: false).deleteVisit(id);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visitProvider = Provider.of<VisitProvider>(context);
    final visit = widget.visit;

    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
                '${visit.date} ${visit.cars.map((car) => '${car.brand} ${car.model}\nTablica: ${car.licensePlate.toUpperCase()}').join(", ")}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () =>
                      _confirmDelete(context, visit.id),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.red, // Color for delete button
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.delete, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          if (_isExpanded)
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Id: ${visit.id} \nSamochód: ${visit.cars.map((car) => '${car.brand} ${car.model} ${car.year} \nVIN: ${car.vin.toUpperCase()} \nTablica: ${car.licensePlate.toUpperCase()}').join(", ")}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Klient: ${visit.cars.map((car) => car.client).map((client) => '${client.firstName} ${client.phone}').join(", ")}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Mechanik: ${visit.mechanics.map((mechanic) => '${mechanic.firstName} ${mechanic.lastName}').join(", ")}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    visit.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ...visit.description.split(',').map((line) {
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            line.trim(),
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  ButtonBar(children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (context) => AddVisitScreen(visit: visit),
                          ),
                        )
                            .then((_) {
                          visitProvider.fetchVisits();
                        });
                      },
                      child: Text('Edytuj'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _confirmDelete(context, visit.id);
                      },
                      child: Text('Usuń'),
                    ),
                  ]),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
