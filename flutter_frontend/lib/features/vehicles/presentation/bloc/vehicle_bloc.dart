import 'package:flutter_bloc/flutter_bloc.dart';
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
  final GetVehicles _getVehicles;
  final GetVehicleDetails _getVehicleDetails;
  final AddVehicle _addVehicle;
  final UpdateVehicle _updateVehicle;
  final DeleteVehicle _deleteVehicle;
  final SearchVehicles _searchVehicles;
  final GetVehiclesForClient _getVehiclesForClient;

  VehicleBloc({
    required GetVehicles getVehicles,
    required GetVehicleDetails getVehicleDetails,
    required AddVehicle addVehicle,
    required UpdateVehicle updateVehicle,
    required DeleteVehicle deleteVehicle,
    required SearchVehicles searchVehicles,
    required GetVehiclesForClient getVehiclesForClient,
  })  : _getVehicles = getVehicles,
        _getVehicleDetails = getVehicleDetails,
        _addVehicle = addVehicle,
        _updateVehicle = updateVehicle,
        _deleteVehicle = deleteVehicle,
        _searchVehicles = searchVehicles,
        _getVehiclesForClient = getVehiclesForClient,
        super(VehicleInitial()) {
    on<LoadVehiclesEvent>(_onLoadVehicles);
    on<LoadVehicleDetailsEvent>(_onLoadVehicleDetails);
    on<AddVehicleEvent>(_onAddVehicle);
    on<UpdateVehicleEvent>(_onUpdateVehicle);
    on<DeleteVehicleEvent>(_onDeleteVehicle);
    on<SearchVehiclesEvent>(_onSearchVehicles);
    on<LoadVehiclesForClientEvent>(_onLoadVehiclesForClient);
    on<ResetVehicleStateEvent>(_onResetState); // Dodaj nową linię
  }

  void _onLoadVehicles(
    LoadVehiclesEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleListLoading()); // Zmiana tutaj
    try {
      final vehicles = await _getVehicles.execute(
        event.accessToken,
        event.workshopId,
      );
      emit(VehiclesLoaded(vehicles: vehicles));
    } catch (e) {
      emit(VehicleError(message: 'Failed to load vehicles: $e'));
    }
  }

  // Dodaj nową metodę
  Future<void> _onResetState(
    ResetVehicleStateEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleInitial());
  }


  Future<void> _onLoadVehicleDetails(
    LoadVehicleDetailsEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      final vehicle = await _getVehicleDetails.execute(
        event.accessToken,
        event.workshopId,
        event.vehicleId,
      );
      emit(VehicleDetailsLoaded(vehicle: vehicle));
    } catch (e) {
      emit(VehicleError(message: 'Failed to load vehicle details: $e'));
    }
  }

  Future<void> _onAddVehicle(
    AddVehicleEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      await _addVehicle.execute(
        accessToken: event.accessToken,
        workshopId: event.workshopId,
        clientId: event.clientId,
        make: event.make,
        model: event.model,
        year: event.year,
        vin: event.vin,
        licensePlate: event.licensePlate,
        mileage: event.mileage,
      );
      emit(const VehicleOperationSuccess(
        message: 'Vehicle added successfully',
      ));
      // Refresh vehicles list after adding
      add(LoadVehiclesEvent(
        accessToken: event.accessToken,
        workshopId: event.workshopId,
      ));
    } catch (e) {
      emit(VehicleError(message: 'Failed to add vehicle: $e'));
    }
  }

  Future<void> _onUpdateVehicle(
    UpdateVehicleEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      await _updateVehicle.execute(
        accessToken: event.accessToken,
        workshopId: event.workshopId,
        vehicleId: event.vehicleId,
        make: event.make,
        model: event.model,
        year: event.year,
        vin: event.vin,
        licensePlate: event.licensePlate,
        mileage: event.mileage,
      );
      emit(const VehicleOperationSuccess(
        message: 'Vehicle updated successfully',
      ));
      // Refresh vehicle details after update
      add(LoadVehicleDetailsEvent(
        accessToken: event.accessToken,
        workshopId: event.workshopId,
        vehicleId: event.vehicleId,
      ));
    } catch (e) {
      emit(VehicleError(message: 'Failed to update vehicle: $e'));
    }
  }

  Future<void> _onDeleteVehicle(
    DeleteVehicleEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      await _deleteVehicle.execute(
        event.accessToken,
        event.workshopId,
        event.vehicleId,
      );
      emit(const VehicleOperationSuccess(
        message: 'Vehicle deleted successfully',
      ));
      // Refresh vehicles list after deletion
      add(LoadVehiclesEvent(
        accessToken: event.accessToken,
        workshopId: event.workshopId,
      ));
    } catch (e) {
      emit(VehicleError(message: 'Failed to delete vehicle: $e'));
    }
  }

  Future<void> _onSearchVehicles(
    SearchVehiclesEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      final vehicles = await _searchVehicles.execute(
        event.accessToken,
        event.workshopId,
        event.query,
      );
      emit(VehiclesLoaded(vehicles: vehicles));
    } catch (e) {
      emit(VehicleError(message: 'Failed to search vehicles: $e'));
    }
  }

  Future<void> _onLoadVehiclesForClient(
    LoadVehiclesForClientEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      final vehicles = await _getVehiclesForClient.execute(
        event.accessToken,
        event.workshopId,
        event.clientId,
      );
      emit(VehiclesLoaded(vehicles: vehicles));
    } catch (e) {
      emit(VehicleError(message: 'Failed to load vehicles for client: $e'));
    }
  }
}