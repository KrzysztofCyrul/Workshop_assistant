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