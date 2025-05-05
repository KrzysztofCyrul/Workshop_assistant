import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

// Core
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/network_info.dart';
import 'package:flutter_frontend/core/utils/constants.dart' as api_constants;

// Features - Auth
import 'package:flutter_frontend/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:flutter_frontend/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_frontend/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:flutter_frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_frontend/features/auth/domain/usecases/login.dart';
import 'package:flutter_frontend/features/auth/domain/usecases/register.dart';
import 'package:flutter_frontend/features/auth/domain/usecases/logout.dart';
import 'package:flutter_frontend/features/auth/presentation/bloc/auth_bloc.dart';

// Features - Vehicles
import 'package:flutter_frontend/features/vehicles/data/datasources/vehicle_remote_data_source.dart';
import 'package:flutter_frontend/features/vehicles/data/repositories/vehicle_repository_impl.dart';
import 'package:flutter_frontend/features/vehicles/domain/repositories/vehicle_repository.dart';
import 'package:flutter_frontend/features/vehicles/domain/usecases/get_vehicles.dart';
import 'package:flutter_frontend/features/vehicles/domain/usecases/get_vehicle_details.dart';
import 'package:flutter_frontend/features/vehicles/domain/usecases/add_vehicle.dart';
import 'package:flutter_frontend/features/vehicles/domain/usecases/update_vehicle.dart';
import 'package:flutter_frontend/features/vehicles/domain/usecases/delete_vehicle.dart';
import 'package:flutter_frontend/features/vehicles/domain/usecases/search_vehicles.dart';
import 'package:flutter_frontend/features/vehicles/domain/usecases/get_vehicles_for_client.dart';
import 'package:flutter_frontend/features/vehicles/domain/usecases/get_service_records.dart';
import 'package:flutter_frontend/features/vehicles/presentation/bloc/vehicle_bloc.dart';

// Features - Clients
import 'package:flutter_frontend/features/clients/data/datasources/client_remote_data_source.dart';
import 'package:flutter_frontend/features/clients/data/repositories/client_repository_impl.dart';
import 'package:flutter_frontend/features/clients/domain/repositories/client_repository.dart';
import 'package:flutter_frontend/features/clients/domain/usecases/get_clients.dart';
import 'package:flutter_frontend/features/clients/domain/usecases/get_client_details.dart';
import 'package:flutter_frontend/features/clients/domain/usecases/add_client.dart';
import 'package:flutter_frontend/features/clients/domain/usecases/update_client.dart';
import 'package:flutter_frontend/features/clients/domain/usecases/delete_client.dart';
import 'package:flutter_frontend/features/clients/presentation/bloc/client_bloc.dart';

// Features - Appointments
import 'package:flutter_frontend/features/appointments/data/datasources/appointment_remote_data_source.dart';
import 'package:flutter_frontend/features/appointments/data/repositories/appointment_repository_impl.dart';
import 'package:flutter_frontend/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/get_appointments.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/get_appointment_details.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/add_appointment.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/update_appointment.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/delete_appointment.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/edit_notes_value.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/partss/get_parts.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/partss/add_part.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/partss/update_part.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/partss/delete_part.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/repair_items/get_repair_items.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/repair_items/add_repair_item.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/repair_items/update_repair_item.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/repair_items/delete_repair_item.dart';
import 'package:flutter_frontend/features/appointments/presentation/bloc/appointment_bloc.dart';




final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Initialize core dependencies
  await _initCoreDependencies();
  
  // Initialize auth dependencies
  await _initAuthDependencies();
  
  // Initialize vehicle dependencies
  await _initVehicleDependencies();

  // Initialize client dependencies
  await _initClientDependencies();

  // Initialize appointment dependencies
  await _initAppointmentDependencies();
}

Future<void> _initCoreDependencies() async {
  // HTTP Client
  getIt.registerLazySingleton(() => http.Client());
  
  // Dio (for API Client)
  getIt.registerLazySingleton(() => Dio(BaseOptions(
    baseUrl: api_constants.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  )));

  getIt.registerLazySingleton(() => const FlutterSecureStorage());
  getIt.registerLazySingleton(() => Connectivity());
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()));
  
  // ApiClient
  getIt.registerLazySingleton(() => ApiClient(
    dio: getIt<Dio>(),
    localDataSource: getIt(),
  ));
}

Future<void> _initAuthDependencies() async {
  // Data sources
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: getIt()),
  );
  
  // Używamy http.Client zamiast Dio w AuthRemoteDataSourceImpl
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: getIt<http.Client>()),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));

  // BLoC
  getIt.registerFactory(() => AuthBloc(
    loginUseCase: getIt(),
    registerUseCase: getIt(),
    logoutUseCase: getIt(),
  ));
}

Future<void> _initVehicleDependencies() async {
  // Data sources - używa Dio z ApiClient
  getIt.registerLazySingleton<VehicleRemoteDataSource>(
    () => VehicleRemoteDataSource(dio: getIt<ApiClient>().dio),
  );

  // Repository
  getIt.registerLazySingleton<VehicleRepository>(
    () => VehicleRepositoryImpl(remoteDataSource: getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetVehicles(getIt()));
  getIt.registerLazySingleton(() => GetVehicleDetails(getIt()));
  getIt.registerLazySingleton(() => AddVehicle(getIt()));
  getIt.registerLazySingleton(() => UpdateVehicle(getIt()));
  getIt.registerLazySingleton(() => DeleteVehicle(getIt()));
  getIt.registerLazySingleton(() => SearchVehicles(getIt()));
  getIt.registerLazySingleton(() => GetVehiclesForClient(getIt()));
  getIt.registerLazySingleton(() => GetServiceRecords(getIt()));

  // BLoC
  getIt.registerFactory(() => VehicleBloc(
    getVehicles: getIt(),
    getVehicleDetails: getIt(),
    addVehicle: getIt(),
    updateVehicle: getIt(),
    deleteVehicle: getIt(),
    searchVehicles: getIt(),
    getVehiclesForClient: getIt(),
    authBloc: getIt(),
    getServiceRecords: getIt(),
  ));
}

Future<void> _initClientDependencies() async {
  // Data sources - używa Dio z ApiClient
  getIt.registerLazySingleton<ClientRemoteDataSource>(
    () => ClientRemoteDataSource(dio: getIt<ApiClient>().dio),
  );

  // Repository
  getIt.registerLazySingleton<ClientRepository>(
    () => ClientRepositoryImpl(remoteDataSource: getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetClients(getIt()));
  getIt.registerLazySingleton(() => GetClientDetails(getIt()));
  getIt.registerLazySingleton(() => AddClient(getIt()));
  getIt.registerLazySingleton(() => UpdateClient(getIt()));
  getIt.registerLazySingleton(() => DeleteClient(getIt()));

  // BLoC
  getIt.registerFactory(() => ClientBloc(
    getClients: getIt(),
    getClientDetails: getIt(),
    addClient: getIt(),
    updateClient: getIt(),
    deleteClient: getIt(),
    authBloc: getIt(),
  ));
}

Future<void> _initAppointmentDependencies() async {
  // Data sources - używa Dio z ApiClient
  getIt.registerLazySingleton<AppointmentRemoteDataSource>(
    () => AppointmentRemoteDataSource(dio: getIt<ApiClient>().dio),
  );

  // Repository
  getIt.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(remoteDataSource: getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetAppointments(getIt()));
  getIt.registerLazySingleton(() => GetAppointmentDetails(getIt()));
  getIt.registerLazySingleton(() => AddAppointment(getIt()));
  getIt.registerLazySingleton(() => UpdateAppointment(getIt()));
  getIt.registerLazySingleton(() => DeleteAppointment(getIt()));
  getIt.registerLazySingleton(() => EditNotesValue(getIt()));
  
  // Parts use cases
  getIt.registerLazySingleton(() => GetParts(getIt()));
  getIt.registerLazySingleton(() => AddPart(getIt()));
  getIt.registerLazySingleton(() => UpdatePart(getIt()));
  getIt.registerLazySingleton(() => DeletePart(getIt()));

  // Repair items use cases
  getIt.registerLazySingleton(() => GetRepairItems(getIt()));
  getIt.registerLazySingleton(() => AddRepairItem(getIt()));
  getIt.registerLazySingleton(() => UpdateRepairItem(getIt()));
  getIt.registerLazySingleton(() => DeleteRepairItem(getIt()));

  // BLoC
  getIt.registerFactory(() => AppointmentBloc(
    getAppointments: getIt(),
    getAppointmentDetails: getIt(),
    addAppointment: getIt(),
    updateAppointment: getIt(),
    deleteAppointment: getIt(),
    editNotesValue: getIt(),
    getParts: getIt(),
    addPart: getIt(),
    updatePart: getIt(),
    deletePart: getIt(),
    getRepairItems: getIt(),
    addRepairItem: getIt(),
    updateRepairItem: getIt(),
    deleteRepairItem: getIt(),
    authBloc: getIt(),
  ));
}