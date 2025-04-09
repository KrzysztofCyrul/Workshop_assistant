// lib/features/auth/presentation/bloc/auth_state.dart
part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class Authenticated extends AuthState {
  final User user;

  Authenticated({required this.user});
}

final class Unauthenticated extends AuthState {}

final class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});
}

final class RegistrationSuccess extends AuthState {}
