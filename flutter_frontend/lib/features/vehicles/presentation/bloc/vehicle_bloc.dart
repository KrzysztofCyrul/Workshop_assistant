import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/core/errors/exceptions.dart';
import 'package:flutter_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_frontend/features/vehicles/domain/entities/vehicle.dart';
import 'package:flutter_frontend/features/vehicles/domain/usecases/get_vehicles.dart';
import 'package:flutter_frontend/features/vehicles/domain/usecases/get_vehicle_details.dart';
import 'package:flutter_frontend/features/vehicles/domain/usecases/add_vehicle.dart';
import 'package:flutter_frontend/features/vehicles/domain/usecases/update_vehicle.dart';
import 'package:flutter_frontend/features/vehicles/domain/usecases/delete_vehicle.dart';
import 'package:flutter_frontend/features/vehicles/domain/usecases/search_vehicles.dart';
import 'package:flutter_frontend/features/vehicles/domain/usecases/get_vehicles_for_client.dart';

part 'vehicle_event.dart';
part 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final GetVehicles getVehicles;
  final GetVehicleDetails getVehicleDetails;
  final AddVehicle addVehicle;
  final UpdateVehicle updateVehicle;
  final DeleteVehicle deleteVehicle;
  final SearchVehicles searchVehicles;
  final GetVehiclesForClient getVehiclesForClient;
  final AuthBloc authBloc;
  late final StreamSubscription<AuthState> _authSubscription;

  VehicleBloc({
    required this.getVehicles,
    required this.getVehicleDetails,
    required this.addVehicle,
    required this.updateVehicle,
    required this.deleteVehicle,
    required this.searchVehicles,
    required this.getVehiclesForClient,
    required this.authBloc,
  }) : super(VehicleInitial()) {
    // Event handlers
    on<LoadVehiclesEvent>(_onLoadVehicles);
    on<LoadVehicleDetailsEvent>(_onLoadVehicleDetails);
    on<AddVehicleEvent>(_onAddVehicle);
    on<UpdateVehicleEvent>(_onUpdateVehicle);
    on<DeleteVehicleEvent>(_onDeleteVehicle);
    on<SearchVehiclesEvent>(_onSearchVehicles);
    on<LoadVehiclesForClientEvent>(_onLoadVehiclesForClient);
    on<ResetVehicleStateEvent>(_onResetState);
    on<VehicleLogoutEvent>(_onLogout);

    // Auth state listener
    _authSubscription = authBloc.stream.listen((authState) {
      if (authState is Unauthenticated) {
        add(VehicleLogoutEvent());
      }
    });
  }

  Future<void> _onLoadVehicles(
    LoadVehiclesEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      final vehicles = await getVehicles.execute(event.workshopId);
      emit(VehiclesLoaded(vehicles: vehicles));
    } on AuthException {
      emit(VehicleUnauthenticated());
    } catch (e) {
      emit(VehicleError(message: e.toString()));
    }
  }

  Future<void> _onLoadVehicleDetails(
    LoadVehicleDetailsEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      final vehicle = await getVehicleDetails.execute(
        event.workshopId,
        event.vehicleId,
      );
      emit(VehicleDetailsLoaded(vehicle: vehicle));
    } on AuthException {
      emit(VehicleUnauthenticated());
    } catch (e) {
      emit(VehicleError(message: e.toString()));
    }
  }

  Future<void> _onAddVehicle(
    AddVehicleEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      await addVehicle.execute(
        workshopId: event.workshopId,
        clientId: event.clientId,
        make: event.make,
        model: event.model,
        year: event.year,
        vin: event.vin,
        licensePlate: event.licensePlate,
        mileage: event.mileage,
      );
      emit(VehicleOperationSuccess(message: 'Vehicle added successfully'));
      add(LoadVehiclesEvent(workshopId: event.workshopId));
    } on AuthException {
      emit(VehicleUnauthenticated());
    } catch (e) {
      emit(VehicleError(message: 'Failed to add vehicle: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateVehicle(
    UpdateVehicleEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      await updateVehicle.execute(
        workshopId: event.workshopId,
        vehicleId: event.vehicleId,
        make: event.make,
        model: event.model,
        year: event.year,
        vin: event.vin,
        licensePlate: event.licensePlate,
        mileage: event.mileage,
      );
      emit(VehicleOperationSuccess(message: 'Vehicle updated successfully'));
      add(LoadVehicleDetailsEvent(
        workshopId: event.workshopId,
        vehicleId: event.vehicleId,
      ));
    } on AuthException {
      emit(VehicleUnauthenticated());
    } catch (e) {
      emit(VehicleError(message: 'Failed to update vehicle: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteVehicle(
    DeleteVehicleEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      await deleteVehicle.execute(
        event.workshopId,
        event.vehicleId,
      );
      emit(VehicleOperationSuccess(message: 'Vehicle deleted successfully'));
      add(LoadVehiclesEvent(workshopId: event.workshopId));
    } on AuthException {
      emit(VehicleUnauthenticated());
    } catch (e) {
      emit(VehicleError(message: 'Failed to delete vehicle: ${e.toString()}'));
    }
  }

  Future<void> _onSearchVehicles(
    SearchVehiclesEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      final vehicles = await searchVehicles.execute(
        event.workshopId,
        event.query,
      );
      emit(VehiclesLoaded(vehicles: vehicles));
    } on AuthException {
      emit(VehicleUnauthenticated());
    } catch (e) {
      emit(VehicleError(message: 'Failed to search vehicles: ${e.toString()}'));
    }
  }

  Future<void> _onLoadVehiclesForClient(
    LoadVehiclesForClientEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      final vehicles = await getVehiclesForClient.execute(
        event.workshopId,
        event.clientId,
      );
      emit(VehiclesLoaded(vehicles: vehicles));
    } on AuthException {
      emit(VehicleUnauthenticated());
    } catch (e) {
      emit(VehicleError(message: 'Failed to load client vehicles: ${e.toString()}'));
    }
  }

  void _onResetState(
    ResetVehicleStateEvent event,
    Emitter<VehicleState> emit,
  ) {
    emit(VehicleInitial());
  }

  void _onLogout(
    VehicleLogoutEvent event,
    Emitter<VehicleState> emit,
  ) {
    emit(VehicleUnauthenticated(message: 'Session expired. Please log in again.'));
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}