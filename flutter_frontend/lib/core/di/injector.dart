import 'package:flutter_frontend/domain/repositories/vehicle_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../../data/data_sources/remote/vehicle_remote_data_source.dart';
import '../../data/repositories/vehicle_repository_impl.dart';
import '../../presentation/providers/vehicle_provider1.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // HTTP Client
  getIt.registerLazySingleton(() => http.Client());

  // Data Sources
  getIt.registerLazySingleton(() => VehicleRemoteDataSource(client: getIt()));

  // Repositories
  getIt.registerLazySingleton<VehicleRepository>(
    () => VehicleRepositoryImpl(remoteDataSource: getIt()),
  );

  // Providers
  getIt.registerFactory(() => VehicleProvider1(repository: getIt<VehicleRepository>()));
}