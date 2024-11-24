import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/appointments/appointments_screen.dart';
import '../screens/appointments/appointment_details_screen.dart';
import '../screens/workshop/workshop_list_screen.dart';
// Importuj inne ekrany

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    LoginScreen.routeName: (context) => LoginScreen(),
    RegisterScreen.routeName: (context) => RegisterScreen(),
    HomeScreen.routeName: (context) => HomeScreen(),
    AppointmentsScreen.routeName: (context) => AppointmentsScreen(),
    AppointmentDetailsScreen.routeName: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
      final workshopId = args['workshopId']!;
      final appointmentId = args['appointmentId']!;
      return AppointmentDetailsScreen(
        workshopId: workshopId,
        appointmentId: appointmentId,
      );
    },
    WorkshopListScreen.routeName: (context) => WorkshopListScreen(),
    // Dodaj inne trasy tutaj
  };
}
