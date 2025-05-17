import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/features/appointments/presentation/bloc/appointment_bloc.dart';
import 'package:flutter_frontend/features/quotations/presentation/bloc/quotation_bloc.dart';
import 'package:flutter_frontend/core/di/injector_container.dart' as di;
import 'package:flutter_frontend/core/widgets/custom_app_bar.dart';
// Auth screens
import 'package:flutter_frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_frontend/features/auth/presentation/screens/register_screen.dart';

// Client screens
import 'package:flutter_frontend/features/clients/presentation/screens/add_client_screen.dart';
import 'package:flutter_frontend/features/clients/presentation/screens/client_details_screen.dart';
import 'package:flutter_frontend/features/clients/presentation/screens/client_edit_screen.dart';
import 'package:flutter_frontend/features/clients/presentation/screens/clients_list_screen.dart';
import 'package:flutter_frontend/features/quotations/presentation/screens/quotation_details_screen.dart';

// Vehicle screens
import 'package:flutter_frontend/features/vehicles/presentation/screens/add_vehicle_screen.dart';
import 'package:flutter_frontend/features/vehicles/presentation/screens/client_vehicles_screen.dart';
import 'package:flutter_frontend/features/vehicles/presentation/screens/vehicle_details_screen.dart';
import 'package:flutter_frontend/features/vehicles/presentation/screens/vehicle_edit_screen.dart';
import 'package:flutter_frontend/features/vehicles/presentation/screens/vehicle_list_screen.dart';

// Appointment screens
import 'package:flutter_frontend/features/appointments/presentation/screens/appointments_list_screen.dart';
import 'package:flutter_frontend/features/appointments/presentation/screens/appointment_details_screen.dart';
import 'package:flutter_frontend/features/appointments/presentation/screens/add_appointment_screen.dart';

// import '../screens/appointments/completed_appointments_screen.dart';
// import '../screens/appointments/pending_appointments_screen.dart';
// import '../screens/appointments/appointment_details_screen.dart';
// import '../screens/appointments/add_appointment_screen.dart';
// import '../screens/appointments/canceled_appointments_screen.dart';

// Workshop screens
import 'package:flutter_frontend/features/workshop/presentation/screens/add_workshop_screen.dart';
import 'package:flutter_frontend/features/workshop/presentation/screens/get_temporary_code_screen.dart';
import 'package:flutter_frontend/features/workshop/presentation/screens/use_code_screen.dart';

// Other screens
import 'home_screen.dart';
// import '../screens/employee/use_code_screen.dart';

// BLoC-based quotation screens
import 'features/quotations/presentation/screens/add_quotation_screen.dart';
import 'features/quotations/presentation/screens/quotations_list_screen.dart';

/// A widget that schedules navigation after the first build is complete
class _NavigateAfterBuild extends StatefulWidget {
  final String navigateTo;
  final Widget child;
  final Map<String, dynamic>? arguments;

  const _NavigateAfterBuild({
    required this.navigateTo,
    required this.child,
    // ignore: unused_element_parameter
    this.arguments,
  });

  @override
  _NavigateAfterBuildState createState() => _NavigateAfterBuildState();
}

class _NavigateAfterBuildState extends State<_NavigateAfterBuild> {
  @override
  void initState() {
    super.initState();
    // Schedule navigation for after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          widget.navigateTo,
          arguments: widget.arguments,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    // Auth routes
    LoginScreen.routeName: (context) => const LoginScreen(),
    RegisterScreen.routeName: (context) => const RegisterScreen(),

    // Main routes
    HomeScreen.routeName: (context) => const HomeScreen(),

    // Appointment routes
    AppointmentsListScreen.routeName: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args == null || args['workshopId'] == null) {
        return _buildErrorScreen('Brak wymaganych parametrów dla AppointmentsListScreen');
      }
      return AppointmentsListScreen(workshopId: args['workshopId']! as String);
    },    AppointmentDetailsScreen.routeName: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>?;

      // Simple error checking - instead of navigating inside the build phase,
      // we return a widget that will handle navigation once the build is complete
      if (args == null) {
        return const _NavigateAfterBuild(
          navigateTo: LoginScreen.routeName,
          child: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      }

      final workshopId = args['workshopId'];
      final appointmentId = args['appointmentId'];

      if (workshopId == null || appointmentId == null) {
        return const _NavigateAfterBuild(
          navigateTo: HomeScreen.routeName, 
          child: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      }return BlocProvider(
        create: (context) => di.getIt<AppointmentBloc>()
          ..add(LoadAppointmentDetailsEvent(
            workshopId: workshopId,
            appointmentId: appointmentId,
          )),
        child: AppointmentDetailsScreen(
          workshopId: workshopId,
          appointmentId: appointmentId,
        ),
      );    },
    AddAppointmentScreen.routeName: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args == null || args['workshopId'] == null) {
        return _buildErrorScreen('Brak wymaganych parametrów dla AddAppointmentScreen');
      }
      return AddAppointmentScreen(workshopId: args['workshopId']! as String);
    },

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
    },    ClientDetailsScreen.routeName: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args == null || args['workshopId'] == null || args['clientId'] == null) {
        return _buildErrorScreen('Brak wymaganych parametrów dla ClientDetailsScreen');
      }
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
    },    AddVehicleScreen.routeName: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args == null) return const AddVehicleScreen(workshopId: '');
      
      // Jeśli mamy już obiekt Client, użyj go bezpośrednio
      if (args['selectedClient'] != null) {
        return AddVehicleScreen(
          workshopId: args['workshopId'] as String,
          selectedClient: args['selectedClient'],
        );
      }
      
      // Jeśli mamy tylko clientId, zwróć ekran z informacją o ładowaniu
      // a następnie pobierz klienta w build metodzie AddVehicleScreen
      if (args['clientId'] != null) {
        return AddVehicleScreen(
          workshopId: args['workshopId'] as String,
          clientId: args['clientId'] as String,
        );
      }

      // Domyślnie zwróć pusty ekran
      return AddVehicleScreen(
        workshopId: args['workshopId'] as String,
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
    
    // Quotation routes
    AddQuotationScreen.routeName: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args == null || args['workshopId'] == null) {
        return _buildErrorScreen('Brak wymaganych parametrów dla AddQuotationScreen');
      }
      return AddQuotationScreen(workshopId: args['workshopId']! as String);
    },
    
    QuotationDetailsScreen.routeName: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final workshopId = args['workshopId']!;
      final quotationId = args['quotationId']!;
      return BlocProvider(
        create: (context) => di.getIt<QuotationBloc>()
          ..add(LoadQuotationDetailsEvent(
            workshopId: workshopId,
            quotationId: quotationId,
          )),
        child: QuotationDetailsScreen(workshopId: workshopId, quotationId: quotationId),
      );
    },
    
    // Single route for /quotations that's used by both the old and new implementations
    QuotationsListScreen.routeName: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args == null || args['workshopId'] == null) {
        return _buildErrorScreen('Brak wymaganych parametrów dla QuotationsListScreen');
      }      return BlocProvider(
        create: (context) => di.getIt<QuotationBloc>()
          ..add(LoadQuotationsEvent(workshopId: args['workshopId']! as String)),
        child: QuotationsListScreen(workshopId: args['workshopId']! as String),
      );
    },
  };
  static Widget _buildErrorScreen(String message) {
    // Use the safer navigation method that happens after the build phase is complete
    return _NavigateAfterBuild(
      navigateTo: HomeScreen.routeName,
      child: Scaffold(
        appBar: CustomAppBar(title: 'Błąd', feature: 'home'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Przekierowuję do strony głównej...')
            ],
          ),
        ),
      ),
    );
  }
}