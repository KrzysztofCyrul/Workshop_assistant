// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/visit_provider.dart';
import 'screens/visit_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VisitProvider()..fetchVisits()),
      ],
      child: MaterialApp(
        title: 'Car Workshop Visits',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: VisitScreen(),
      ),
    );
  }
}
