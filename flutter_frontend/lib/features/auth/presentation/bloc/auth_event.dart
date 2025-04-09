// lib/features/auth/presentation/bloc/auth_event.dart
part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});
}

final class RegisterRequested extends AuthEvent {
  final Map<String, dynamic> userData;

  RegisterRequested({required this.userData});
}

final class LogoutRequested extends AuthEvent {}