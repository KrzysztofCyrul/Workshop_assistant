part of 'workshop_bloc.dart';

sealed class WorkshopState {
  const WorkshopState();
}

class WorkshopInitial extends WorkshopState {}

class WorkshopLoading extends WorkshopState {}

class WorkshopsLoaded extends WorkshopState {
  final List<Workshop> workshops;

  const WorkshopsLoaded({required this.workshops});
}

class WorkshopDetailsLoaded extends WorkshopState {
  final Workshop workshop;

  const WorkshopDetailsLoaded({required this.workshop});
}

class EmployeesLoaded extends WorkshopState {
  final List<Employee> employees;

  const EmployeesLoaded({required this.employees});
}

class EmployeeDetailsLoaded extends WorkshopState {
  final Employee employee;

  const EmployeeDetailsLoaded({required this.employee});
}

class TemporaryCodeLoaded extends WorkshopState {
  final TemporaryCode temporaryCode;

  const TemporaryCodeLoaded({required this.temporaryCode});
}

class WorkshopOperationSuccess extends WorkshopState {
  final String message;

  const WorkshopOperationSuccess({required this.message});
}

class WorkshopError extends WorkshopState {
  final String message;

  const WorkshopError({required this.message});
}

class WorkshopUnauthenticated extends WorkshopState {}