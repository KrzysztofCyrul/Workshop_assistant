import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'general_settings_screen.dart';
import 'segment_colors_screen.dart';
import 'email_settings_screen.dart';
import 'X_generate_code_screen.dart';
import '../../providers/auth_provider.dart'; // Importujemy AuthProvider

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final workshopId = authProvider.user?.employeeProfiles.first.workshopId;

    if (workshopId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ustawienia'),
        ),
        body: const Center(
          child: Text('Brak przypisanego warsztatu.'),
        ),
      );
    }

    return DefaultTabController(
      length: 4, // Zwiększamy długość na 4, ponieważ mamy 4 zakładki
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ustawienia'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.settings), text: 'Ogólne'),
              Tab(icon: Icon(Icons.palette), text: 'Kolory Segmentów'),
              Tab(icon: Icon(Icons.email), text: 'E-mail'),
              Tab(icon: Icon(Icons.code), text: 'Kod dostępu'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const GeneralSettingsScreen(),
            const SegmentColorsScreen(),
            const EmailSettingsScreen(),
            GenerateCodeScreen(workshopId: workshopId), // Przekazujemy workshopId
          ],
        ),
      ),
    );
  }
}