import 'package:get_it/get_it.dart';
import 'package:flutter_frontend/features/vehicles/data/repositories/vehicle_repository_impl.dart';
import 'package:flutter_frontend/features/vehicles/domain/repositories/vehicle_repository.dart';
import 'package:flutter_frontend/features/vehicles/domain/usecases/get_vehicles.dart';
import 'package:flutter_frontend/features/vehicles/domain/usecases/get_vehicle_details.dart';
import 'package:flutter_frontend/features/vehicles/domain/usecases/add_vehicle.dart';
import 'package:flutter_frontend/features/vehicles/domain/usecases/update_vehicle.dart';
import 'package:flutter_frontend/features/vehicles/domain/usecases/delete_vehicle.dart';
import 'package:flutter_frontend/features/vehicles/domain/usecases/search_vehicles.dart';
import 'package:flutter_frontend/features/vehicles/presentation/bloc/vehicle_bloc.dart';
import 'package:http/http.dart' as http;

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // External dependencies
  getIt.registerLazySingleton(() => http.Client());
  
  // Features - Vehicles
  _initVehicleDependencies();
}

void _initVehicleDependencies() {

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

  // BLoC
  getIt.registerFactory(() => VehicleBloc(
    getVehicles: getIt(),
    getVehicleDetails: getIt(),
    addVehicle: getIt(),
    updateVehicle: getIt(),
    deleteVehicle: getIt(),
    searchVehicles: getIt(),
  ));
}