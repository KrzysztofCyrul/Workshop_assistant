import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workshop_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/workshop_service.dart';

class WorkshopListScreen extends StatefulWidget {
  static const routeName = '/workshop-list';
  @override
  _WorkshopListScreenState createState() => _WorkshopListScreenState();
}

class _WorkshopListScreenState extends State<WorkshopListScreen> {
  @override
  void initState() {
    super.initState();
    _fetchWorkshops();
  }

  Future<void> _fetchWorkshops() async {
    final accessToken = Provider.of<AuthProvider>(context, listen: false).accessToken!;
    await Provider.of<WorkshopProvider>(context, listen: false).fetchWorkshops(accessToken);
  }

  void _requestAssignment(String workshopId) async {
    final accessToken = Provider.of<AuthProvider>(context, listen: false).accessToken!;
    try {
      await WorkshopService.requestAssignment(workshopId, accessToken);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Prośba o dołączenie została wysłana')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd wysyłania prośby: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final workshopProvider = Provider.of<WorkshopProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista warsztatów'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchWorkshops,
        child: ListView.builder(
          itemCount: workshopProvider.workshops.length,
          itemBuilder: (context, index) {
            final workshop = workshopProvider.workshops[index];
            return ListTile(
              title: Text(workshop.name),
              subtitle: Text(workshop.address),
              trailing: ElevatedButton(
                onPressed: () => _requestAssignment(workshop.id),
                child: Text('Dołącz'),
              ),
            );
          },
        ),
      ),
    );
  }
}
