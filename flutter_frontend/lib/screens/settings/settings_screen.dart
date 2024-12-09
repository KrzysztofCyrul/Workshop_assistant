import 'package:flutter/material.dart';
import 'general_settings_screen.dart';
import 'segment_colors_screen.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ustawienia'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.settings), text: 'Ogólne'),
              Tab(icon: Icon(Icons.palette), text: 'Kolory Segmentów'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            GeneralSettingsScreen(),
            SegmentColorsScreen(),
          ],
        ),
      ),
    );
  }
}
