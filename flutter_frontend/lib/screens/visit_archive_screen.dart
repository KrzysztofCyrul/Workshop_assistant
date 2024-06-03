// lib/screens/visit_archive_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/visit_provider.dart';
import '../models/visit.dart';
import 'add_visit_screen.dart';
import 'package:intl/intl.dart';

class VisitArchiveScreen extends StatefulWidget {
  @override
  _VisitArchiveScreenState createState() => _VisitArchiveScreenState();
}

class _VisitArchiveScreenState extends State<VisitArchiveScreen> {
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    Provider.of<VisitProvider>(context, listen: false).fetchArchivedVisits();
  }

  void _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isStartDate ? _startDate : _endDate))
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Archived Visits'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: VisitSearchDelegate(
                  Provider.of<VisitProvider>(context, listen: false).visits,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Search',
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: _resetFilters,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, true),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _startDate == null
                              ? 'From'
                              : 'From: ${DateFormat('yyyy-MM-dd').format(_startDate!)}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, false),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _endDate == null
                              ? 'To'
                              : 'To: ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
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
                    final filteredVisits = visitProvider.visits
                        .where((visit) => visit.status == 'archived')
                        .where((visit) => _searchQuery.isEmpty ||
                        visit.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        visit.cars.any((car) =>
                        car.licensePlate.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            car.brand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            car.model.toLowerCase().contains(_searchQuery.toLowerCase())))
                        .where((visit) => _startDate == null || DateTime.parse(visit.date).isAfter(_startDate!))
                        .where((visit) => _endDate == null || DateTime.parse(visit.date).isBefore(_endDate!))
                        .toList();
                    return ListView.builder(
                      itemCount: filteredVisits.length,
                      itemBuilder: (context, index) {
                        final visit = filteredVisits[index];
                        return VisitItem(visit: visit);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VisitSearchDelegate extends SearchDelegate {
  final List<Visit> visits;

  VisitSearchDelegate(this.visits);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = visits
        .where((visit) =>
    visit.id.toLowerCase().contains(query.toLowerCase()) ||
        visit.cars.any((car) =>
        car.licensePlate.toLowerCase().contains(query.toLowerCase()) ||
            car.brand.toLowerCase().contains(query.toLowerCase()) ||
            car.model.toLowerCase().contains(query.toLowerCase())))
        .toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final visit = results[index];
        return ListTile(
          title: Text(visit.name),
          subtitle: Text(visit.date),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddVisitScreen(visit: visit),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = visits
        .where((visit) =>
    visit.id.toLowerCase().contains(query.toLowerCase()) ||
        visit.cars.any((car) =>
        car.licensePlate.toLowerCase().contains(query.toLowerCase()) ||
            car.brand.toLowerCase().contains(query.toLowerCase()) ||
            car.model.toLowerCase().contains(query.toLowerCase())))
        .toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final visit = suggestions[index];
        return ListTile(
          title: Text(visit.name),
          subtitle: Text(visit.date),
          onTap: () {
            query = visit.name;
            showResults(context);
          },
        );
      },
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
  void _confirmStatusChange(
      BuildContext context, String id, String currentStatus) {
    String newStatus;
    String confirmStatus;
    switch (currentStatus) {
      case "in_progress":
        newStatus = "pending";
        confirmStatus = "Oczekujący";
        break;
      case "pending":
        newStatus = "done";
        confirmStatus = "Zakończony";
        break;
      case "done":
        newStatus = "in_progress";
        confirmStatus = "W trakcie";
        break;
      default:
        newStatus = "in_progress";
        confirmStatus = "W trakcie";
        break;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Potwierdzenie zmiany statusu'),
        content: Text('Czy na pewno chcesz zmienić status na $confirmStatus?'),
        actions: [
          TextButton(
            child: Text('Anuluj'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text('Potwierdź'),
            onPressed: () {
              Provider.of<VisitProvider>(context, listen: false)
                  .updateStatus(id, newStatus);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visit = widget.visit;

    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
                '${visit.date} ${visit.cars.map((car) => '${car.brand} ${car.model}\nTablica: ${car.licensePlate}').join(", ")}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () =>
                      _confirmStatusChange(context, visit.id, visit.status),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _statusColorMapping[visit.status] ?? Colors.grey,
                      shape: BoxShape.circle,
                    ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Id: ${visit.id} \nSamochód: ${visit.cars.map((car) => '${car.brand} ${car.model} ${car.year} \nVIN: ${car.vin} \nTablica: ${car.licensePlate}').join(", ")}',
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
                  ...visit.description.split(',').asMap().entries.map((entry) {
                    final index = entry.key;
                    final line = entry.value;
                    final isStriked = visit.strikedLines[index] ?? false;
                    return Row(
                      children: [
                        Checkbox(
                          value: isStriked,
                          onChanged: (bool? value) {
                            setState(() {
                              final newStrikedLines = Map<int, bool>.from(visit.strikedLines);
                              newStrikedLines[index] = value ?? false;
                              Provider.of<VisitProvider>(context, listen: false).updateStrikedLines(visit.id, newStrikedLines);
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            line,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }
  static const Map<String, Color> _statusColorMapping = {
    'in_progress': Colors.green,
    'pending': Colors.orange,
    'done': Colors.red,
    'default': Colors.grey,
  };
}
