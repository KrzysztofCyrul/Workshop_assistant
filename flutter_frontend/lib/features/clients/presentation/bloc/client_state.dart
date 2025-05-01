part of 'client_bloc.dart';

sealed class ClientState {
  const ClientState();
}

class ClientInitial extends ClientState {}

class ClientLoading extends ClientState {}

class ClientsLoaded extends ClientState {
  final List<Client> clients;

  const ClientsLoaded({required this.clients});
}

class ClientDetailsLoaded extends ClientState {
  final Client client;

  const ClientDetailsLoaded({required this.client});
}

class ClientOperationSuccess extends ClientState {
  final String message;

  const ClientOperationSuccess({required this.message});
}

class ClientError extends ClientState {
  final String message;

  const ClientError({required this.message});
}

class ClientUnauthenticated extends ClientState {
  final String message;

  const ClientUnauthenticated({
    this.message = 'Session expired. Please log in again.',
  });
}