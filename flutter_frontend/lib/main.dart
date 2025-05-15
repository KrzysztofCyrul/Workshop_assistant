import 'package:flutter/material.dart';
import 'package:flutter_frontend/screens/home/home_screen.dart';
import 'core/di/injector_container.dart';
import 'features/appointments/domain/usecases/update_appointment_status.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'routes/app_routes.dart';
import 'core/utils/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/vehicles/presentation/bloc/vehicle_bloc.dart';
import 'features/vehicles/domain/usecases/get_vehicles.dart';
import 'features/vehicles/domain/usecases/get_vehicle_details.dart';
import 'features/vehicles/domain/usecases/add_vehicle.dart';
import 'features/vehicles/domain/usecases/update_vehicle.dart';
import 'features/vehicles/domain/usecases/delete_vehicle.dart';
import 'features/vehicles/domain/usecases/search_vehicles.dart';
import 'features/vehicles/domain/usecases/get_vehicles_for_client.dart';
import 'features/vehicles/domain/usecases/get_service_records.dart';

import 'features/clients/presentation/bloc/client_bloc.dart';
import 'features/clients/domain/usecases/get_clients.dart';
import 'features/clients/domain/usecases/get_client_details.dart';
import 'features/clients/domain/usecases/add_client.dart';
import 'features/clients/domain/usecases/update_client.dart';
import 'features/clients/domain/usecases/delete_client.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/domain/usecases/login.dart';
import 'features/auth/domain/usecases/register.dart';
import 'features/auth/domain/usecases/logout.dart';

import 'features/appointments/presentation/bloc/appointment_bloc.dart';
import 'features/appointments/domain/usecases/get_appointments.dart';
import 'features/appointments/domain/usecases/get_appointment_details.dart';
import 'features/appointments/domain/usecases/add_appointment.dart';
import 'features/appointments/domain/usecases/update_appointment.dart';
import 'features/appointments/domain/usecases/delete_appointment.dart';
import 'features/appointments/domain/usecases/edit_notes_value.dart';
import 'features/appointments/domain/usecases/partss/get_parts.dart';
import 'features/appointments/domain/usecases/partss/add_part.dart';
import 'features/appointments/domain/usecases/partss/update_part.dart';
import 'features/appointments/domain/usecases/partss/delete_part.dart';
import 'features/appointments/domain/usecases/repair_items/get_repair_items.dart';
import 'features/appointments/domain/usecases/repair_items/add_repair_item.dart';
import 'features/appointments/domain/usecases/repair_items/update_repair_item.dart';
import 'features/appointments/domain/usecases/repair_items/delete_repair_item.dart';

import 'features/quotations/presentation/bloc/quotation_bloc.dart';

import 'features/workshop/presentation/bloc/workshop_bloc.dart';
import 'features/workshop/domain/usecases/get_workshops.dart';
import 'features/workshop/domain/usecases/get_workshop_details.dart';
import 'features/workshop/domain/usecases/add_workshop.dart';
import 'features/workshop/domain/usecases/update_workshop.dart';
import 'features/workshop/domain/usecases/delete_workshop.dart';
import 'features/workshop/domain/usecases/get_temporary_code.dart';
import 'features/workshop/domain/usecases/use_temporary_code.dart';
import 'features/workshop/domain/usecases/assign_creator_to_workshop.dart';
import 'features/workshop/domain/usecases/remove_employee_from_workshop.dart';
import 'features/workshop/domain/usecases/get_employees.dart';
import 'features/workshop/domain/usecases/get_employee_details.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicjalizacja zależności i kolorów
  initDependencies(); // Inicjalizacja DI
  await SegmentColors.loadColors();

  // Inicjalizacja formatowania daty dla polskiej lokalizacji
  await initializeDateFormatting('pl_PL', null);

  runApp(
    MultiProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            loginUseCase: getIt<LoginUseCase>(),
            registerUseCase: getIt<RegisterUseCase>(),
            logoutUseCase: getIt<LogoutUseCase>(),
          ),
        ),
        BlocProvider(
          create: (_) => VehicleBloc(
            authBloc: getIt<AuthBloc>(),
            getVehicles: getIt<GetVehicles>(),
            getVehicleDetails: getIt<GetVehicleDetails>(),
            addVehicle: getIt<AddVehicle>(),
            updateVehicle: getIt<UpdateVehicle>(),
            deleteVehicle: getIt<DeleteVehicle>(),
            searchVehicles: getIt<SearchVehicles>(),
            getVehiclesForClient: getIt<GetVehiclesForClient>(),
            getServiceRecords: getIt<GetServiceRecords>(),
          ),
        ),
        BlocProvider(
          create: (_) => ClientBloc(
            authBloc: getIt<AuthBloc>(),
            getClients: getIt<GetClients>(),
            getClientDetails: getIt<GetClientDetails>(),
            addClient: getIt<AddClient>(),
            updateClient: getIt<UpdateClient>(),
            deleteClient: getIt<DeleteClient>(),
          ),
        ),
        BlocProvider(
          create: (_) => AppointmentBloc(
            authBloc: getIt<AuthBloc>(),
            getAppointments: getIt<GetAppointments>(),
            getAppointmentDetails: getIt<GetAppointmentDetails>(),
            addAppointment: getIt<AddAppointment>(),
            updateAppointment: getIt<UpdateAppointment>(),
            deleteAppointment: getIt<DeleteAppointment>(),
            updateAppointmentStatus: getIt<UpdateAppointmentStatus>(),
            editNotesValue: getIt<EditNotesValue>(),
            getParts: getIt<GetParts>(),
            addPart: getIt<AddPart>(),
            updatePart: getIt<UpdatePart>(),
            deletePart: getIt<DeletePart>(),
            getRepairItems: getIt<GetRepairItems>(),
            addRepairItem: getIt<AddRepairItem>(),
            updateRepairItem: getIt<UpdateRepairItem>(),
            deleteRepairItem: getIt<DeleteRepairItem>(),
          ),
        ),        BlocProvider(
          create: (_) => WorkshopBloc(
            authBloc: getIt<AuthBloc>(),
            getWorkshops: getIt<GetWorkshops>(),
            getWorkshopDetails: getIt<GetWorkshopDetails>(),
            addWorkshop: getIt<AddWorkshop>(),
            updateWorkshop: getIt<UpdateWorkshop>(),
            deleteWorkshop: getIt<DeleteWorkshop>(),
            getTemporaryCode: getIt<GetTemporaryCode>(),
            useTemporaryCode: getIt<UseTemporaryCode>(),
            assignCreatorToWorkshop: getIt<AssignCreatorToWorkshop>(),
            removeEmployeeFromWorkshop: getIt<RemoveEmployeeFromWorkshop>(),
            getEmployees: getIt<GetEmployees>(),
            getEmployeeDetails: getIt<GetEmployeeDetails>(),
          ),
        ),
        BlocProvider(
          create: (_) => getIt<QuotationBloc>(),
        ),            
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warsztat Samochodowy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: AppRoutes.routes,
      // Add error builder for safer navigation
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Błąd')),
            body: Center(
              child: Text('Nie znaleziono strony: ${settings.name}'),
            ),
          ),
        );
      },
      builder: (context, child) {
        // Global error handler for navigation
        return Navigator(
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => child ?? const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          },
        );
      },
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
