import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/workshop_provider.dart';
import 'providers/client_provider.dart';
import 'routes/app_routes.dart';
import 'screens/auth/login_screen.dart';
import 'screens/appointments/home_appointments_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WorkshopProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return MaterialApp(
      title: 'Warsztat Samochodowy',
      theme: ThemeData(
        fontFamily: null,
        primarySwatch: Colors.blue,
      ),
      routes: AppRoutes.routes,
      initialRoute: authProvider.isAuthenticated
          ? HomeAppointmentsScreen.routeName
          : LoginScreen.routeName,
    );
  }
}
