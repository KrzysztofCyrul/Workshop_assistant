// lib/features/auth/presentation/bloc/auth_event.dart
part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

   LoginRequested({
    required this.email, 
    required this.password, 
    this.rememberMe = false,
  });
}

final class RegisterRequested extends AuthEvent {
  final Map<String, dynamic> userData;

  RegisterRequested({required this.userData});
}

final class LogoutRequested extends AuthEvent {}