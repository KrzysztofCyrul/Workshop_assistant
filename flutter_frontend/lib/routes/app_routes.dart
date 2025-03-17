import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/screens/vehicles/vehicle_details_screen.dart';
import 'package:flutter_frontend/presentation/screens/vehicles/vehicle_edit_screen.dart';
import 'package:flutter_frontend/screens/clients/edit_client_screen.dart';
import '../data/models/client.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/appointments/appointments_screen.dart';
import '../screens/appointments/completed_appointments_screen.dart';
import '../screens/appointments/pending_appointments_screen.dart';
import '../screens/appointments/appointment_details_screen.dart';
import '../screens/appointments/add_appointment_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/clients/clients_screen.dart';
import '../screens/clients/client_details_screen.dart';
import '../screens/employee/employee_details_screen.dart';
import '../screens/vehicles/vehicle_list_screen.dart';
import '../screens/vehicles/client_vehicle_list_screen.dart';
import '../screens/clients/add_client_screen.dart';
import '../screens/vehicles/add_vehicle_screen.dart';
import '../screens/appointments/appointment_calendar_screen.dart';
import '../screens/service_records/service_history_screen.dart';
import '../screens/workshop/add_workshop_screen.dart';
import '../screens/relationships/client_statistics_screen.dart';
import '../screens/settings/email_settings_screen.dart';
import '../screens/relationships/send_email_screen.dart';
import '../screens/appointments/canceled_appointments_screen.dart';
import '../screens/employee/use_code_screen.dart';
import '../screens/quotations/add_quotation_screen.dart';
import '../screens/quotations/quotation_details_screen.dart';
import '../screens/quotations/quotations_screen.dart';

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    LoginScreen.routeName: (context) => const LoginScreen(),
    RegisterScreen.routeName: (context) => const RegisterScreen(),
    HomeScreen.routeName: (context) => const HomeScreen(),
    AppointmentsScreen.routeName: (context) => const AppointmentsScreen(),
    CompletedAppointmentsScreen.routeName: (context) => const CompletedAppointmentsScreen(),
    CanceledAppointmentsScreen.routeName: (context) => const CanceledAppointmentsScreen(),
    PendingAppointmentsScreen.routeName: (context) => const PendingAppointmentsScreen(),
AppointmentDetailsScreen.routeName: (context) {
  final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
  
  if (args == null) {
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    return const Scaffold(
      body: Center(
        child: Text('Błąd: Brak wymaganych argumentów.'),
      ),
    );
  }

  final workshopId = args['workshopId'];
  final appointmentId = args['appointmentId'];

  if (workshopId == null || appointmentId == null) {
    return const Scaffold(
      body: Center(
        child: Text('Błąd: Brak wymaganych argumentów.'),
      ),
    );
  }

  return AppointmentDetailsScreen(
    workshopId: workshopId,
    appointmentId: appointmentId,
  );
},
    AddAppointmentScreen.routeName: (context) => const AddAppointmentScreen(),
    AppointmentCalendarScreen.routeName: (context) => const AppointmentCalendarScreen(),
    ClientsScreen.routeName: (context) => const ClientsScreen(),
    AddClientScreen.routeName: (context) => const AddClientScreen(),
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
  final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
  
  if (args == null || 
      args['workshopId'] == null || 
      args['vehicleId'] == null) {
    return _buildErrorScreen('Brak wymaganych parametrów');
  }

  return VehicleDetailsScreen(
    workshopId: args['workshopId']! as String,
    vehicleId: args['vehicleId']! as String,
  );
},
    ClientDetailsScreen.routeName: (context) {
      final client = ModalRoute.of(context)!.settings.arguments as Client;
      return ClientDetailsScreen(client: client);
    },
    SettingsScreen.routeName: (context) => const SettingsScreen(),
    VehicleServiceHistoryScreen.routeName: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final workshopId = args['workshopId']!;
      final vehicleId = args['vehicleId']!;
      return VehicleServiceHistoryScreen(workshopId: workshopId, vehicleId: vehicleId);
    },
    CreateWorkshopScreen.routeName: (context) => const CreateWorkshopScreen(),
    ClientsStatisticsScreen.routeName: (context) => const ClientsStatisticsScreen(),
    EmailSettingsScreen.routeName: (context) => const EmailSettingsScreen(),
    SendEmailScreen.routeName: (context) => const SendEmailScreen(),
    UseCodeScreen.routeName: (context) => const UseCodeScreen(),
    AddQuotationScreen.routeName: (context) => const AddQuotationScreen(),
    QuotationDetailsScreen.routeName: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final workshopId = args['workshopId']!;
      final quotationId = args['quotationId']!;
      return QuotationDetailsScreen(workshopId: workshopId, quotationId: quotationId);
    },
    QuotationsScreen.routeName: (context) => const QuotationsScreen(),
    VehicleEditScreen.routeName: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final workshopId = args['workshopId']!;
      final vehicleId = args['vehicleId']!;
      return VehicleEditScreen(workshopId: workshopId, vehicleId: vehicleId);
    },
  };
}

Widget _buildErrorScreen(String message) {
  return Scaffold(
    appBar: AppBar(title: const Text('Błąd')),
    body: Center(
      child: Text(message),
    ),
  );
}