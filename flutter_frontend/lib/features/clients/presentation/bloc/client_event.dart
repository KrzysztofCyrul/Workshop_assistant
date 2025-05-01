part of 'client_bloc.dart';

sealed class ClientEvent {
  const ClientEvent();
}

class LoadClientsEvent extends ClientEvent {
  final String workshopId;

  const LoadClientsEvent({required this.workshopId});
}

class LoadClientDetailsEvent extends ClientEvent {
  final String workshopId;
  final String clientId;

  const LoadClientDetailsEvent({
    required this.workshopId,
    required this.clientId,
  });
}

class AddClientEvent extends ClientEvent {
  final String workshopId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String segment;

  const AddClientEvent({
    required this.workshopId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.segment,
  });
}

class UpdateClientEvent extends ClientEvent {
  final String workshopId;
  final String clientId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String segment;

  const UpdateClientEvent({
    required this.workshopId,
    required this.clientId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.segment,
  });
}

class DeleteClientEvent extends ClientEvent {
  final String workshopId;
  final String clientId;

  const DeleteClientEvent({
    required this.workshopId,
    required this.clientId,
  });
}

class ResetClientEvent extends ClientEvent {}

class ClientLogoutEvent extends ClientEvent {}
