import 'package:flutter/material.dart';
import '../models/client.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/appointments/appointments_screen.dart';
import '../screens/appointments/completed_appointments_screen.dart';
import '../screens/appointments/canceled_appointments_screen.dart';
import '../screens/appointments/appointment_details_screen.dart';
import '../screens/appointments/add_appointment_screen.dart';
import '../screens/workshop/workshop_list_screen.dart';
import '../screens/clients/clients_screen.dart';
import '../screens/clients/client_details_screen.dart';
import '../screens/employee/employee_details_screen.dart';
import '../screens/vehicles/vehicle_list_screen.dart';
import '../screens/vehicles/client_vehicle_list_screen.dart';
import '../screens/vehicles/vehicle_details_screen.dart';

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    LoginScreen.routeName: (context) => const LoginScreen(),
    RegisterScreen.routeName: (context) => const RegisterScreen(),
    HomeScreen.routeName: (context) => HomeScreen(),
    AppointmentsScreen.routeName: (context) => const AppointmentsScreen(),
    CompletedAppointmentsScreen.routeName: (context) => const CompletedAppointmentsScreen(),
    CanceledAppointmentsScreen.routeName: (context) => const CanceledAppointmentsScreen(),
    AppointmentDetailsScreen.routeName: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
      final workshopId = args['workshopId']!;
      final appointmentId = args['appointmentId']!;
      return AppointmentDetailsScreen(
        workshopId: workshopId,
        appointmentId: appointmentId,
      );
    },
    AddAppointmentScreen.routeName: (context) => const AddAppointmentScreen(),
    WorkshopListScreen.routeName: (context) => const WorkshopListScreen(),
    ClientsScreen.routeName: (context) => const ClientsScreen(),
    EmployeeDetailsScreen.routeName: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final workshopId = args['workshopId']!;
          final employeeId = args['employeeId']!;
          return EmployeeDetailsScreen(workshopId: workshopId, employeeId: employeeId);
        },
        VehicleListScreen.routeName: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final workshopId = args['workshopId']!;
          return VehicleListScreen(workshopId: workshopId);
        },
        ClientVehicleListScreen.routeName: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final workshopId = args['workshopId']!;
          final clientId = args['clientId']!;
          return ClientVehicleListScreen(workshopId: workshopId, clientId: clientId);
        },
        VehicleDetailsScreen.routeName: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final workshopId = args['workshopId']!;
          final vehicleId = args['vehicleId']!;
          return VehicleDetailsScreen(workshopId: workshopId, vehicleId: vehicleId);
        },
        ClientDetailsScreen.routeName: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<dynamic, dynamic>;
          final client = args['client'] as Client;
          return ClientDetailsScreen(client: client);
        },
  };
}
