import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/features/appointments/presentation/bloc/appointment_bloc.dart';
import 'package:flutter_frontend/core/di/injector_container.dart' as di;

// Auth screens
import 'package:flutter_frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_frontend/features/auth/presentation/screens/register_screen.dart';

// Client screens
import 'package:flutter_frontend/features/clients/presentation/screens/add_client_screen.dart';
import 'package:flutter_frontend/features/clients/presentation/screens/client_details_screen.dart';
import 'package:flutter_frontend/features/clients/presentation/screens/client_edit_screen.dart';
import 'package:flutter_frontend/features/clients/presentation/screens/clients_list_screen.dart';

// Vehicle screens
import 'package:flutter_frontend/features/vehicles/presentation/screens/add_vehicle_screen.dart';
import 'package:flutter_frontend/features/vehicles/presentation/screens/client_vehicles_screen.dart';
import 'package:flutter_frontend/features/vehicles/presentation/screens/vehicle_details_screen.dart';
import 'package:flutter_frontend/features/vehicles/presentation/screens/vehicle_edit_screen.dart';
import 'package:flutter_frontend/features/vehicles/presentation/screens/vehicle_list_screen.dart';

// Appointment screens
import 'package:flutter_frontend/features/appointments/presentation/screens/appointments_list_screen.dart';
import 'package:flutter_frontend/features/appointments/presentation/screens/appointment_details_screen.dart';

// import '../screens/appointments/completed_appointments_screen.dart';
// import '../screens/appointments/pending_appointments_screen.dart';
// import '../screens/appointments/appointment_details_screen.dart';
import '../screens/appointments/add_appointment_screen.dart';
// import '../screens/appointments/canceled_appointments_screen.dart';

// Workshop screens
import 'package:flutter_frontend/features/workshop/presentation/screens/add_workshop_screen.dart';
import 'package:flutter_frontend/features/workshop/presentation/screens/get_temporary_code_screen.dart';
import 'package:flutter_frontend/features/workshop/presentation/screens/use_code_screen.dart';

// Other screens
import '../screens/home/home_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/employee/employee_details_screen.dart';
import '../screens/service_records/X_service_history_screen.dart';
import '../screens/relationships/client_statistics_screen.dart';
import '../screens/settings/email_settings_screen.dart';
import '../screens/relationships/send_email_screen.dart';
// import '../screens/employee/use_code_screen.dart';
import '../screens/quotations/add_quotation_screen.dart';
import '../screens/quotations/quotation_details_screen.dart';
import '../screens/quotations/quotations_screen.dart';

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    // Auth routes
    LoginScreen.routeName: (context) => const LoginScreen(),
    RegisterScreen.routeName: (context) => const RegisterScreen(),

    // Main routes
    HomeScreen.routeName: (context) => const HomeScreen(),
    SettingsScreen.routeName: (context) => const SettingsScreen(),

    // Appointment routes
    AppointmentsListScreen.routeName: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args == null || args['workshopId'] == null) {
        return _buildErrorScreen('Brak wymaganych parametrów dla AppointmentsListScreen');
      }
      return AppointmentsListScreen(workshopId: args['workshopId']! as String);
    },
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
      }      return BlocProvider(
        create: (context) => di.getIt<AppointmentBloc>()
          ..add(LoadAppointmentDetailsEvent(
            workshopId: workshopId,
            appointmentId: appointmentId,
          )),
        child: AppointmentDetailsScreen(
          workshopId: workshopId,
          appointmentId: appointmentId,
        ),
      );
    },
    // AddAppointmentScreen.routeName: (context) => const AddAppointmentScreen(),

    // Client routes
    ClientsListScreen.routeName: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args == null || args['workshopId'] == null) {
        return _buildErrorScreen('Brak wymaganych parametrów dla ClientListScreen');
      }
      return ClientsListScreen(workshopId: args['workshopId']! as String);
    },
    AddClientScreen.routeName: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
      if (args == null || args['workshopId'] == null) {
        return _buildErrorScreen('Brak wymaganych parametrów dla AddClientScreen');
      }
      return AddClientScreen(workshopId: args['workshopId']!);
    },
    ClientEditScreen.routeName: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
      if (args == null || args['workshopId'] == null || args['clientId'] == null) {
        return _buildErrorScreen('Brak wymaganych parametrów dla ClientEditScreen');
      }
      return ClientEditScreen(workshopId: args['workshopId']!, clientId: args['clientId']!);
    },
    ClientDetailsScreen.routeName: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final workshopId = args['workshopId']!;
      final clientId = args['clientId']!;
      return ClientDetailsScreen(workshopId: workshopId, clientId: clientId);
    },

    // Vehicle routes
    VehicleListScreen.routeName: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args == null || args['workshopId'] == null) {
        return _buildErrorScreen('Brak wymaganych parametrów dla VehicleListScreen');
      }
      return VehicleListScreen(workshopId: args['workshopId']! as String);
    },
    AddVehicleScreen.routeName: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args == null) return const AddVehicleScreen(workshopId: '');

      return AddVehicleScreen(
        workshopId: args['workshopId'] as String,
        selectedClient: args['selectedClient'],
      );
    },
    ClientVehicleListScreen.routeName: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final workshopId = args['workshopId']!;
      final clientId = args['clientId']!;
      return ClientVehicleListScreen(workshopId: workshopId, clientId: clientId);
    },
    VehicleDetailsScreen.routeName: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args == null || args['workshopId'] == null || args['vehicleId'] == null) {
        return _buildErrorScreen('Brak wymaganych parametrów dla VehicleDetailsScreen');
      }
      return VehicleDetailsScreen(
        workshopId: args['workshopId']! as String,
        vehicleId: args['vehicleId']! as String,
      );
    },
    VehicleEditScreen.routeName: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args == null || args['workshopId'] == null || args['vehicleId'] == null) {
        return _buildErrorScreen('Brak wymaganych parametrów dla VehicleEditScreen');
      }
      return VehicleEditScreen(
        workshopId: args['workshopId']! as String,
        vehicleId: args['vehicleId']! as String,
      );
    },
    VehicleServiceHistoryScreen.routeName: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final workshopId = args['workshopId']!;
      final vehicleId = args['vehicleId']!;
      return VehicleServiceHistoryScreen(workshopId: workshopId, vehicleId: vehicleId);
    },

    // Workshop routes
    AddWorkshopScreen.routeName: (context) => const AddWorkshopScreen(),
    GetTemporaryCodeScreen.routeName: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args == null || args['workshopId'] == null) {
        return _buildErrorScreen('Brak wymaganych parametrów dla GetTemporaryCodeScreen');
      }
      return GetTemporaryCodeScreen(workshopId: args['workshopId']! as String);
    },

    UseCodeScreen.routeName: (context) => const UseCodeScreen(),



    // Employee routes
    EmployeeDetailsScreen.routeName: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args == null || args['workshopId'] == null || args['employeeId'] == null) {
        return _buildErrorScreen('Brak wymaganych parametrów dla EmployeeDetailsScreen');
      }
      return EmployeeDetailsScreen(
        workshopId: args['workshopId']! as String,
        employeeId: args['employeeId']! as String,
      );
    },

    // Quotation routes
    AddQuotationScreen.routeName: (context) => const AddQuotationScreen(),
    QuotationDetailsScreen.routeName: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final workshopId = args['workshopId']!;
      final quotationId = args['quotationId']!;
      return QuotationDetailsScreen(workshopId: workshopId, quotationId: quotationId);
    },
    QuotationsScreen.routeName: (context) => const QuotationsScreen(),

    // Other routes
    ClientsStatisticsScreen.routeName: (context) => const ClientsStatisticsScreen(),
    EmailSettingsScreen.routeName: (context) => const EmailSettingsScreen(),
    SendEmailScreen.routeName: (context) => const SendEmailScreen(),
  };

  static Widget _buildErrorScreen(String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Błąd')),
      body: Center(
        child: Text(message),
      ),
    );
  }
}