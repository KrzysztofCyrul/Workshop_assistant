import 'package:flutter/material.dart';
import 'general_settings_screen.dart';
import 'segment_colors_screen.dart';
import 'email_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ustawienia'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.settings), text: 'Ogólne'),
              Tab(icon: Icon(Icons.palette), text: 'Kolory Segmentów'),
              Tab(icon: Icon(Icons.email), text: 'E-mail'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            GeneralSettingsScreen(),
            SegmentColorsScreen(),
            EmailSettingsScreen(),
          ],
        ),
      ),
    );
  }
}
