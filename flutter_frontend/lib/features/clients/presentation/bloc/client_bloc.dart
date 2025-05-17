import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/core/errors/exceptions.dart';
import 'package:flutter_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_frontend/features/clients/domain/entities/client.dart';
import 'package:flutter_frontend/features/clients/domain/usecases/get_clients.dart';
import 'package:flutter_frontend/features/clients/domain/usecases/get_client_details.dart';
import 'package:flutter_frontend/features/clients/domain/usecases/add_client.dart';
import 'package:flutter_frontend/features/clients/domain/usecases/update_client.dart';
import 'package:flutter_frontend/features/clients/domain/usecases/delete_client.dart';

part 'client_event.dart';
part 'client_state.dart';

class ClientBloc extends Bloc<ClientEvent, ClientState> {
  final GetClients getClients;
  final GetClientDetails getClientDetails;
  final AddClient addClient;
  final UpdateClient updateClient;
  final DeleteClient deleteClient;
  final AuthBloc authBloc;
  late final StreamSubscription<AuthState> _authSubscription;

  ClientBloc({
    required this.getClients,
    required this.getClientDetails,
    required this.addClient,
    required this.updateClient,
    required this.deleteClient,
    required this.authBloc,
  }) : super(ClientInitial()) {
    // Event handlers
    on<LoadClientsEvent>(_onLoadClients);
    on<LoadClientDetailsEvent>(_onLoadClientDetails);
    on<AddClientEvent>(_onAddClient);
    on<UpdateClientEvent>(_onUpdateClient);
    on<DeleteClientEvent>(_onDeleteClients);
    on<ResetClientEvent>(_onResetState);
    on<ClientLogoutEvent>(_onLogout);

    // Auth state listener
    _authSubscription = authBloc.stream.listen((authState) {
      if (authState is Unauthenticated) {
        add(ClientLogoutEvent());
      }
    });
  }
  Future<void> _onLoadClients(
    LoadClientsEvent event,
    Emitter<ClientState> emit,
  ) async {
    emit(ClientLoading());
    try {
      final clients = await getClients.execute(event.workshopId);
      emit(ClientsLoaded(clients: clients));
    } on AuthException {
      emit(const ClientUnauthenticated());
    } catch (e) {
      emit(ClientError(message: e.toString()));
    }
  }

  Future<void> _onLoadClientDetails(
    LoadClientDetailsEvent event,
    Emitter<ClientState> emit,
  ) async {
    emit(ClientLoading());
    try {
      final client = await getClientDetails.execute(
        event.workshopId,
        event.clientId,
      );
      emit(ClientDetailsLoaded(client: client));
    } on AuthException {
      emit(const ClientUnauthenticated());
    } catch (e) {
      emit(ClientError(message: e.toString()));
    }
  }  Future<void> _onAddClient(
    AddClientEvent event,
    Emitter<ClientState> emit,
  ) async {
    emit(ClientLoading());
    try {
      await addClient.execute(
        workshopId: event.workshopId,
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        phone: event.phone,
        address: event.address,
        segment: event.segment,
      );
      
      // Emituj sukces po dodaniu klienta
      emit(const ClientOperationSuccess(
        message: 'Klient dodany pomyślnie',
      ));
    } on AuthException {
      emit(const ClientUnauthenticated());
    } catch (e) {
      emit(ClientError(message: 'Błąd podczas dodawania klienta: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateClient(
    UpdateClientEvent event,
    Emitter<ClientState> emit,
  ) async {
    emit(ClientLoading());
    try {
      await updateClient.execute(
        workshopId: event.workshopId,
        clientId: event.clientId,
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        phone: event.phone,
        address: event.address,
        segment: event.segment,
      );
      emit(const ClientOperationSuccess(message: 'Client updated successfully'));
    } on AuthException {
      emit(const ClientUnauthenticated());
    } catch (e) {
      emit(ClientError(message: 'Failed to update client: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteClients(
    DeleteClientEvent event,
    Emitter<ClientState> emit,
  ) async {
    emit(ClientLoading());
    try {
      await deleteClient.execute(
        event.workshopId,
        event.clientId,
      );
      emit(const ClientOperationSuccess(message: 'Clients deleted successfully'));
    } on AuthException {
      emit(const ClientUnauthenticated());
    } catch (e) {
      emit(ClientError(message: 'Failed to delete clients: ${e.toString()}'));
    }
  }

  void _onResetState(
    ResetClientEvent event,
    Emitter<ClientState> emit,
  ) {
    emit(ClientInitial());
  }

  void _onLogout(
    ClientLogoutEvent event,
    Emitter<ClientState> emit,
  ) {
    emit(ClientInitial());
  }
  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
