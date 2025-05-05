import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/core/errors/exceptions.dart';
import 'package:flutter_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_frontend/features/workshop/domain/entities/workshop.dart';
import 'package:flutter_frontend/features/workshop/domain/entities/temporary_code.dart';
import 'package:flutter_frontend/features/workshop/domain/entities/employee.dart';

import 'package:flutter_frontend/features/workshop/domain/usecases/add_workshop.dart';
import 'package:flutter_frontend/features/workshop/domain/usecases/assign_creator_to_workshop.dart';
import 'package:flutter_frontend/features/workshop/domain/usecases/delete_workshop.dart';
import 'package:flutter_frontend/features/workshop/domain/usecases/get_employee_details.dart';
import 'package:flutter_frontend/features/workshop/domain/usecases/get_employees.dart';
import 'package:flutter_frontend/features/workshop/domain/usecases/get_temporary_code.dart';
import 'package:flutter_frontend/features/workshop/domain/usecases/get_workshop_details.dart';
import 'package:flutter_frontend/features/workshop/domain/usecases/get_workshops.dart';
import 'package:flutter_frontend/features/workshop/domain/usecases/remove_employee_from_workshop.dart';
import 'package:flutter_frontend/features/workshop/domain/usecases/update_workshop.dart';
import 'package:flutter_frontend/features/workshop/domain/usecases/use_temporary_code.dart';

part 'workshop_event.dart';
part 'workshop_state.dart';

class WorkshopBloc extends Bloc<WorkshopEvent, WorkshopState> {
  final GetWorkshops getWorkshops;
  final GetWorkshopDetails getWorkshopDetails;
  final AddWorkshop addWorkshop;
  final UpdateWorkshop updateWorkshop;
  final DeleteWorkshop deleteWorkshop;
  final GetTemporaryCode getTemporaryCode;
  final UseTemporaryCode useTemporaryCode;
  final AssignCreatorToWorkshop assignCreatorToWorkshop;
  final RemoveEmployeeFromWorkshop removeEmployeeFromWorkshop;
  final GetEmployees getEmployees;
  final GetEmployeeDetails getEmployeeDetails;
  final AuthBloc authBloc;
  late final StreamSubscription<AuthState> _authSubscription;

  WorkshopBloc({
    required this.getWorkshops,
    required this.getWorkshopDetails,
    required this.addWorkshop,
    required this.updateWorkshop,
    required this.deleteWorkshop,
    required this.getTemporaryCode,
    required this.useTemporaryCode,
    required this.assignCreatorToWorkshop,
    required this.removeEmployeeFromWorkshop,
    required this.getEmployees,
    required this.getEmployeeDetails,
    required this.authBloc,
  }) : super(WorkshopInitial()) {
    // Event handlers
    on<LoadWorkshopsEvent>(_onLoadWorkshops);
    on<LoadWorkshopDetailsEvent>(_onLoadWorkshopDetails);
    on<AddWorkshopEvent>(_onAddWorkshop);
    on<UpdateWorkshopEvent>(_onUpdateWorkshop);
    on<DeleteWorkshopEvent>(_onDeleteWorkshop);
    on<LoadTemporaryCodeEvent>(_onLoadTemporaryCode);
    on<UseTemporaryCodeEvent>(_onUseTemporaryCode);
    on<AssignCreatorToWorkshopEvent>(_onAssignCreatorToWorkshop);
    on<RemoveEmployeeFromWorkshopEvent>(_onRemoveEmployeeFromWorkshop);
    on<LoadEmployeesEvent>(_onLoadEmployees);
    on<LoadEmployeeDetailsEvent>(_onLoadEmployeeDetails);
    on<ResetWorkshopStateEvent>(_onResetState);
    on<WorkshopLogoutEvent>(_onLogout);

    // Auth state listener
    _authSubscription = authBloc.stream.listen((authState) {
      if (authState is Unauthenticated) {
        add(WorkshopLogoutEvent());
      }
    });
  }

Future<void> _onLoadWorkshops(
    LoadWorkshopsEvent event,
    Emitter<WorkshopState> emit,
  ) async {
    emit(WorkshopLoading());
    try {
      final workshops = await getWorkshops();
      emit(WorkshopsLoaded(workshops: workshops));
    } on AuthException {
      emit(WorkshopUnauthenticated());
    } catch (e) {
      emit(WorkshopError(message: e.toString()));
    }
  }

  Future<void> _onLoadWorkshopDetails(
    LoadWorkshopDetailsEvent event,
    Emitter<WorkshopState> emit,
  ) async {
    emit(WorkshopLoading());
    try {
      final workshop = await getWorkshopDetails(event.workshopId);
      emit(WorkshopDetailsLoaded(workshop: workshop));
    } on AuthException {
      emit(WorkshopUnauthenticated());
    } catch (e) {
      emit(WorkshopError(message: e.toString()));
    }
  }

  Future<void> _onAddWorkshop(
    AddWorkshopEvent event,
    Emitter<WorkshopState> emit,
  ) async {
    emit(WorkshopLoading());
    try {
      await addWorkshop(
        name: event.name,
        address: event.address,
        postCode: event.postCode,
        nipNumber: event.nipNumber,
        email: event.email,
        phoneNumber: event.phoneNumber,
      );
      emit(const WorkshopOperationSuccess(message: 'Workshop added successfully'));
      add(LoadWorkshopsEvent());
    } on AuthException {
      emit(WorkshopUnauthenticated());
    } catch (e) {
      emit(WorkshopError(message: 'Failed to add workshop: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateWorkshop(
    UpdateWorkshopEvent event,
    Emitter<WorkshopState> emit,
  ) async {
    emit(WorkshopLoading());
    try {
      await updateWorkshop(
        workshopId: event.workshopId,
        name: event.name,
        address: event.address,
        postCode: event.postCode,
        nipNumber: event.nipNumber,
        email: event.email,
        phoneNumber: event.phoneNumber,
      );
      emit(const WorkshopOperationSuccess(message: 'Workshop updated successfully'));
      add(LoadWorkshopDetailsEvent(workshopId: event.workshopId));
    } on AuthException {
      emit(WorkshopUnauthenticated());
    } catch (e) {
      emit(WorkshopError(message: 'Failed to update workshop: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteWorkshop(
    DeleteWorkshopEvent event,
    Emitter<WorkshopState> emit,
  ) async {
    emit(WorkshopLoading());
    try {
      await deleteWorkshop(event.workshopId);
      emit(const WorkshopOperationSuccess(message: 'Workshop deleted successfully'));
      add(LoadWorkshopsEvent());
    } on AuthException {
      emit(WorkshopUnauthenticated());
    } catch (e) {
      emit(WorkshopError(message: 'Failed to delete workshop: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTemporaryCode(
    LoadTemporaryCodeEvent event,
    Emitter<WorkshopState> emit,
  ) async {
    emit(WorkshopLoading());
    try {
      final code = await getTemporaryCode(event.workshopId);
      emit(TemporaryCodeLoaded(temporaryCode: code));
    } on AuthException {
      emit(WorkshopUnauthenticated());
    } catch (e) {
      emit(WorkshopError(message: 'Failed to get temporary code: ${e.toString()}'));
    }
  }

  Future<void> _onUseTemporaryCode(
    UseTemporaryCodeEvent event,
    Emitter<WorkshopState> emit,
  ) async {
    emit(WorkshopLoading());
    try {
      await useTemporaryCode(event.code);
      emit(const WorkshopOperationSuccess(message: 'Successfully joined workshop'));
      add(LoadWorkshopsEvent());
    } on AuthException {
      emit(WorkshopUnauthenticated());
    } catch (e) {
      emit(WorkshopError(message: 'Failed to use temporary code: ${e.toString()}'));
    }
  }

  Future<void> _onLoadEmployees(
    LoadEmployeesEvent event,
    Emitter<WorkshopState> emit,
  ) async {
    emit(WorkshopLoading());
    try {
      final employees = await getEmployees(event.workshopId);
      emit(EmployeesLoaded(employees: employees));
    } on AuthException {
      emit(WorkshopUnauthenticated());
    } catch (e) {
      emit(WorkshopError(message: 'Failed to load employees: ${e.toString()}'));
    }
  }

  Future<void> _onLoadEmployeeDetails(
    LoadEmployeeDetailsEvent event,
    Emitter<WorkshopState> emit,
  ) async {
    emit(WorkshopLoading());
    try {
      final employee = await getEmployeeDetails(event.workshopId, event.employeeId);
      emit(EmployeeDetailsLoaded(employee: employee));
    } on AuthException {
      emit(WorkshopUnauthenticated());
    } catch (e) {
      emit(WorkshopError(message: 'Failed to load employee details: ${e.toString()}'));
    }
  }

  Future<void> _onAssignCreatorToWorkshop(
    AssignCreatorToWorkshopEvent event,
    Emitter<WorkshopState> emit,
  ) async {
    emit(WorkshopLoading());
    try {
      await assignCreatorToWorkshop(
        workshopId: event.workshopId,
        userId: event.userId,
      );
      emit(const WorkshopOperationSuccess(message: 'Successfully assigned creator'));
      add(LoadEmployeesEvent(workshopId: event.workshopId));
    } on AuthException {
      emit(WorkshopUnauthenticated());
    } catch (e) {
      emit(WorkshopError(message: 'Failed to assign creator: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveEmployeeFromWorkshop(
    RemoveEmployeeFromWorkshopEvent event,
    Emitter<WorkshopState> emit,
  ) async {
    emit(WorkshopLoading());
    try {
      await removeEmployeeFromWorkshop(
        workshopId: event.workshopId,
        employeeId: event.employeeId,
      );
      emit(const WorkshopOperationSuccess(message: 'Successfully removed employee'));
      add(LoadEmployeesEvent(workshopId: event.workshopId));
    } on AuthException {
      emit(WorkshopUnauthenticated());
    } catch (e) {
      emit(WorkshopError(message: 'Failed to remove employee: ${e.toString()}'));
    }
  }

  void _onResetState(
    ResetWorkshopStateEvent event,
    Emitter<WorkshopState> emit,
  ) {
    emit(WorkshopInitial());
  }

  void _onLogout(
    WorkshopLogoutEvent event,
    Emitter<WorkshopState> emit,
  ) {
    emit(WorkshopUnauthenticated());
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}