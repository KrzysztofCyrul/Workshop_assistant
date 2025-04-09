import 'package:flutter_frontend/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:flutter_frontend/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:flutter_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
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
import 'package:http/http.dart' as http;
import 'package:flutter_frontend/features/vehicles/data/datasources/vehicle_remote_data_source.dart';
import 'package:flutter_frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_frontend/features/auth/domain/usecases/login.dart';
import 'package:flutter_frontend/features/auth/domain/usecases/register.dart';
import 'package:flutter_frontend/features/auth/domain/usecases/logout.dart';
import 'package:flutter_frontend/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_frontend/core/network/network_info.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // External dependencies
  getIt.registerLazySingleton(() => http.Client());
  getIt.registerLazySingleton(() => const FlutterSecureStorage());
  getIt.registerLazySingleton(() => Connectivity());  // Changed from InternetConnectionChecker
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()));
  
  // Features
  _initVehicleDependencies();
  _initAuthDependencies();
}

void _initVehicleDependencies() {
  // Remote Data Source
  getIt.registerLazySingleton<VehicleRemoteDataSource>(
    () => VehicleRemoteDataSource(client: getIt()),
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
   ));
}

void _initAuthDependencies() {
  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: getIt()),
  );

  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: getIt()),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Use Cases
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