import 'package:flutter/material.dart';
import 'package:flutter_frontend/providers/vehicle_provider.dart';
import 'package:provider/provider.dart';
import 'providers/service_record_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/workshop_provider.dart';
import 'providers/client_provider.dart';
import 'providers/email_provider.dart';
import 'routes/app_routes.dart';
import 'screens/auth/login_screen.dart';
import 'providers/employee_provider.dart';
import 'screens/appointments/appointments_screen.dart';
import 'utils/colors.dart';
import 'providers/temporary_code_provider.dart';
import 'providers/generate_code_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SegmentColors.loadColors();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WorkshopProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => ServiceRecordProvider()),    
        ChangeNotifierProvider(create: (_) => EmailProvider()),    
        ChangeNotifierProvider(create: (_) => TemporaryCodeProvider()),
        ChangeNotifierProvider(create: (_) => GenerateCodeProvider()),
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
          ? AppointmentsScreen.routeName
          : LoginScreen.routeName,
    );
  }
}
