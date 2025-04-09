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

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // External dependencies
  getIt.registerLazySingleton(() => http.Client());
  
  // Features - Vehicles
  _initVehicleDependencies();
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
    getVehiclesForClient: getIt()
   ));
}