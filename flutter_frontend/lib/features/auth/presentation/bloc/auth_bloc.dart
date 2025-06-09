// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/core/errors/exceptions.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/register.dart';
import '../../domain/usecases/logout.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

 // W AuthBloc
Future<void> _onLoginRequested(
  LoginRequested event,
  Emitter<AuthState> emit,
) async {
  emit(AuthLoading());
  try {
    final authResult = await loginUseCase.execute(event.email, event.password);
    if (authResult.accessToken.isEmpty) {
      throw AuthException(message: 'Empty access token received');
    }
    emit(Authenticated(
      user: authResult.user,
      accessToken: authResult.accessToken,
    ));
    debugPrint('Login successful, token: ${authResult.accessToken}');
  } catch (e) {
    debugPrint('Login error: $e');
    emit(AuthError(message: e.toString()));
    emit(Unauthenticated());
  }
}
  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await registerUseCase.execute(event.userData);
      emit(RegistrationSuccess());
      // After a brief delay, set to unauthenticated so user can login
      await Future.delayed(const Duration(milliseconds: 500));
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await logoutUseCase.execute();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}