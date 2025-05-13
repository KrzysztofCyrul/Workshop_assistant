part of 'appointment_bloc.dart';

sealed class AppointmentState {
  const AppointmentState();
}

class AppointmentInitial extends AppointmentState {}

class AppointmentLoading extends AppointmentState {}

class AppointmentsLoaded extends AppointmentState {
  final List<Appointment> appointments;

  AppointmentsLoaded({required this.appointments});
}

class AppointmentDetailsLoaded extends AppointmentState {
  final Appointment appointment;

  AppointmentDetailsLoaded({required this.appointment});
}

class AppointmentOperationSuccessWithDetails extends AppointmentState {
  final String message;
  final Appointment appointment;

  const AppointmentOperationSuccessWithDetails({
    required this.message,
    required this.appointment,
  });
}

class AppointmentAdded extends AppointmentState {
  final Appointment appointment;

  AppointmentAdded({required this.appointment});
}

class PartsLoaded extends AppointmentState {
  final List<Part> parts;

  PartsLoaded({required this.parts});
}

class RepairItemsLoaded extends AppointmentState {
  final List<RepairItem> repairItems;

  RepairItemsLoaded({required this.repairItems});
}

class AppointmentOperationSuccess extends AppointmentState {
  final String message;

  const AppointmentOperationSuccess({required this.message});
}

class AppointmentError extends AppointmentState {
  final String message;

  const AppointmentError({required this.message});
}

class AppointmentUnauthenticated extends AppointmentState {
  final String message;

  const AppointmentUnauthenticated({
    this.message = 'Session expired. Please log in again.',
  });
}