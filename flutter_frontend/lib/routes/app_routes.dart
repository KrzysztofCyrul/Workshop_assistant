import 'package:flutter/material.dart';
import 'package:flutter_frontend/screens/clients/edit_client_screen.dart';
import '../models/client.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/appointments/appointments_screen.dart';
import '../screens/appointments/completed_appointments_screen.dart';
import '../screens/appointments/canceled_appointments_screen.dart';
import '../screens/appointments/appointment_details_screen.dart';
import '../screens/appointments/add_appointment_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/workshop/workshop_list_screen.dart';
import '../screens/clients/clients_screen.dart';
import '../screens/clients/client_details_screen.dart';
import '../screens/employee/employee_details_screen.dart';
import '../screens/vehicles/vehicle_list_screen.dart';
import '../screens/vehicles/client_vehicle_list_screen.dart';
import '../screens/vehicles/vehicle_details_screen.dart';
import '../screens/clients/add_client_screen.dart';
import '../screens/vehicles/add_vehicle_screen.dart';
import '../screens/appointments/appointment_calendar_screen.dart';
import '../screens/service_records/service_history_screen.dart';
import '../screens/workshop/add_workshop_screen.dart';
import '../screens/relationships/client_statistics_screen.dart';
import '../screens/settings/email_settings_screen.dart';
import '../screens/relationships/send_email_screen.dart';

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    LoginScreen.routeName: (context) => const LoginScreen(),
    RegisterScreen.routeName: (context) => const RegisterScreen(),
    HomeScreen.routeName: (context) => const HomeScreen(),
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
    AppointmentCalendarScreen.routeName: (context) => const AppointmentCalendarScreen(),
    WorkshopListScreen.routeName: (context) => const WorkshopListScreen(),
    ClientsScreen.routeName: (context) => const ClientsScreen(),
    AddClientScreen.routeName: (context) => AddClientScreen(),
EditClientScreen.routeName: (context) {
  final client = ModalRoute.of(context)!.settings.arguments as Client;
  return EditClientScreen(client: client);
},
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
    AddVehicleScreen.routeName: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final workshopId = args['workshopId']!;
      return AddVehicleScreen(workshopId: workshopId);
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
  final client = ModalRoute.of(context)!.settings.arguments as Client;
  return ClientDetailsScreen(client: client);
},
    SettingsScreen.routeName: (context) => SettingsScreen(),
    VehicleServiceHistoryScreen.routeName: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final workshopId = args['workshopId']!;
      final vehicleId = args['vehicleId']!;
      return VehicleServiceHistoryScreen(workshopId: workshopId, vehicleId: vehicleId);
    },
    CreateWorkshopScreen.routeName: (context) => const CreateWorkshopScreen(),
    ClientsStatisticsScreen.routeName: (context) => const ClientsStatisticsScreen(),
    EmailSettingsScreen.routeName: (context) => EmailSettingsScreen(),
    SendEmailScreen.routeName: (context) => const SendEmailScreen(),
  };
}
