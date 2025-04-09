import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/di/injector_container.dart';
import 'package:flutter_frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/vehicle_provider.dart';
import 'package:provider/provider.dart';
import 'providers/service_record_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/workshop_provider.dart';
import 'providers/client_provider.dart';
import 'providers/email_provider.dart';
import 'routes/app_routes.dart';
import 'providers/employee_provider.dart';
import 'screens/appointments/appointments_screen.dart';
import 'core/utils/colors.dart';
import 'providers/temporary_code_provider.dart';
import 'providers/generate_code_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/vehicles/presentation/bloc/vehicle_bloc.dart';
import 'features/vehicles/domain/usecases/get_vehicles.dart';
import 'features/vehicles/domain/usecases/get_vehicle_details.dart';
import 'features/vehicles/domain/usecases/add_vehicle.dart';
import 'features/vehicles/domain/usecases/update_vehicle.dart';
import 'features/vehicles/domain/usecases/delete_vehicle.dart';
import 'features/vehicles/domain/usecases/search_vehicles.dart';
import 'features/vehicles/domain/usecases/get_vehicles_for_client.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/domain/usecases/login.dart';
import 'features/auth/domain/usecases/register.dart';
import 'features/auth/domain/usecases/logout.dart';

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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        BlocProvider(
          create: (_) => AuthBloc(
            loginUseCase: getIt<LoginUseCase>(),
            registerUseCase: getIt<RegisterUseCase>(),
            logoutUseCase: getIt<LogoutUseCase>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => WorkshopProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => ServiceRecordProvider()),    
        ChangeNotifierProvider(create: (_) => EmailProvider()),    
        ChangeNotifierProvider(create: (_) => TemporaryCodeProvider()),
        ChangeNotifierProvider(create: (_) => GenerateCodeProvider()),
        BlocProvider(
          create: (_) => VehicleBloc(
            getVehicles: getIt<GetVehicles>(),
            getVehicleDetails: getIt<GetVehicleDetails>(),
            addVehicle: getIt<AddVehicle>(),
            updateVehicle: getIt<UpdateVehicle>(),
            deleteVehicle: getIt<DeleteVehicle>(),
            searchVehicles: getIt<SearchVehicles>(),
            getVehiclesForClient: getIt<GetVehiclesForClient>(),
          ),
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
