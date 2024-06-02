// lib/screens/visit_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/visit_provider.dart';
import 'add_visit_screen.dart';
import '../models/visit.dart';

class VisitScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visits'),
      ),
      body: SafeArea(
        child: Consumer<VisitProvider>(
          builder: (context, visitProvider, child) {
            if (visitProvider.loading) {
              return Center(child: CircularProgressIndicator());
            } else if (visitProvider.error != null) {
              return Center(
                  child: Text('Failed to load data: ${visitProvider.error}'));
            } else {
              return ListView.builder(
                itemCount: visitProvider.visits.length,
                itemBuilder: (context, index) {
                  final visit = visitProvider.visits[index];
                  return VisitItem(visit: visit);
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddVisitScreen()),
          );
        },
        child: Icon(Icons.add),
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
    final visitProvider = Provider.of<VisitProvider>(context);
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
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                    'Mechanicy: ${visit.mechanics.map((mechanic) => '${mechanic.firstName} ${mechanic.lastName}').join(", ")}',
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
                            final newStrikedLines =
                            Map<int, bool>.from(visit.strikedLines);
                            newStrikedLines[index] = value ?? false;
                            visitProvider.updateStrikedLines(
                                visit.id, newStrikedLines);
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
                  ButtonBar(children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AddVisitScreen(visit: visit),
                          ),
                        );
                      },
                      child: Text('Edytuj'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        visitProvider.archiveVisit(visit.id);
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

  static const Map<String, Color> _statusColorMapping = {
    'in_progress': Colors.green,
    'pending': Colors.orange,
    'done': Colors.red,
    'default': Colors.grey,
  };
}
