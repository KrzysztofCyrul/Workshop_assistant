import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/core/errors/exceptions.dart';
import 'package:flutter_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_frontend/features/appointments/domain/entities/appointment.dart';
import 'package:flutter_frontend/features/appointments/domain/entities/part.dart';
import 'package:flutter_frontend/features/appointments/domain/entities/repair_item.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/add_appointment.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/delete_appointment.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/edit_notes_value.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/get_appointment_details.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/get_appointments.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/update_appointment.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/update_appointment_status.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/partss/get_parts.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/partss/add_part.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/partss/update_part.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/partss/delete_part.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/repair_items/get_repair_items.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/repair_items/add_repair_item.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/repair_items/update_repair_item.dart';
import 'package:flutter_frontend/features/appointments/domain/usecases/repair_items/delete_repair_item.dart';

part 'appointment_event.dart';
part 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final GetAppointments getAppointments;
  final GetAppointmentDetails getAppointmentDetails;
  final AddAppointment addAppointment;
  final UpdateAppointment updateAppointment;
  final DeleteAppointment deleteAppointment;
  final UpdateAppointmentStatus updateAppointmentStatus;
  final EditNotesValue editNotesValue;
  final GetParts getParts;
  final AddPart addPart;
  final UpdatePart updatePart;
  final DeletePart deletePart;
  final GetRepairItems getRepairItems;
  final AddRepairItem addRepairItem;
  final UpdateRepairItem updateRepairItem;
  final DeleteRepairItem deleteRepairItem;
  final AuthBloc authBloc;

  late final StreamSubscription<AuthState> _authSubscription;

  AppointmentBloc({
    required this.getAppointments,
    required this.getAppointmentDetails,
    required this.addAppointment,
    required this.updateAppointment,
    required this.deleteAppointment,
    required this.updateAppointmentStatus,
    required this.editNotesValue,
    required this.getParts,
    required this.addPart,
    required this.updatePart,
    required this.deletePart,
    required this.getRepairItems,
    required this.addRepairItem,
    required this.updateRepairItem,
    required this.deleteRepairItem,
    required this.authBloc,
  }) : super(AppointmentInitial()) {
    // Event handlers
    on<LoadAppointmentsEvent>(_onLoadAppointments);
    on<LoadAppointmentDetailsEvent>(_onLoadAppointmentDetails);
    on<AddAppointmentEvent>(_onAddAppointment);
    on<UpdateAppointmentEvent>(_onUpdateAppointment);
    on<DeleteAppointmentEvent>(_onDeleteAppointment);
    on<UpdateAppointmentStatusEvent>(_onUpdateAppointmentStatus);
    on<EditNotesValueEvent>(_onEditNotesValue);
    on<LoadPartsEvent>(_onLoadParts);
    on<AddPartEvent>(_onAddPart);
    on<UpdatePartEvent>(_onUpdatePart);
    on<DeletePartEvent>(_onDeletePart);
    on<LoadRepairItemsEvent>(_onLoadRepairItems);
    on<AddRepairItemEvent>(_onAddRepairItem);
    on<UpdateRepairItemEvent>(_onUpdateRepairItem);
    on<DeleteRepairItemEvent>(_onDeleteRepairItem);
    on<ResetAppointmentStateEvent>(_onResetState);
    on<AppointmentLogoutEvent>(_onLogout);

    // Auth state listener
    _authSubscription = authBloc.stream.listen((authState) {
      if (authState is Unauthenticated) {
        add(AppointmentLogoutEvent());
      }
    });
  }

  Future<void> _onLoadAppointments(
    LoadAppointmentsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    try {
      final appointments = await getAppointments.execute(event.workshopId);
      emit(AppointmentsLoaded(appointments: appointments));
    } on AuthException {
      emit(const AppointmentUnauthenticated());
    } catch (e) {
      emit(AppointmentError(message: e.toString()));
    }
  }

  Future<void> _onLoadAppointmentDetails(
    LoadAppointmentDetailsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    try {
      final appointment = await getAppointmentDetails.execute(
        event.workshopId,
        event.appointmentId,
      );
      emit(AppointmentDetailsLoaded(appointment: appointment));
    } on AuthException {
      emit(const AppointmentUnauthenticated());
    } catch (e) {
      emit(AppointmentError(message: e.toString()));
    }
  }

  Future<void> _onAddAppointment(
    AddAppointmentEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    try {
      await addAppointment.execute(
        workshopId: event.workshopId,
        clientId: event.clientId,
        vehicleId: event.vehicleId,
        scheduledTime: event.scheduledTime,
        notes: event.notes,
        mileage: event.mileage,
        recommendations: event.recommendations,
        estimatedDuration: event.estimatedDuration,
        totalCost: event.totalCost,
        status: event.status,
      );
      emit(const AppointmentOperationSuccess(message: 'Appointment added successfully'));
    } on AuthException {
      emit(const AppointmentUnauthenticated());
    } catch (e) {
      emit(AppointmentError(message: 'Failed to add appointment: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateAppointment(
    UpdateAppointmentEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    try {
      await updateAppointment.execute(
        workshopId: event.workshopId,
        appointmentId: event.appointmentId,
        status: event.status,
        notes: event.notes,
        mileage: event.mileage,
        recommendations: event.recommendations,
        estimatedDuration: event.estimatedDuration,
        totalCost: event.totalCost,
      );
      emit(const AppointmentOperationSuccess(message: 'Appointment updated successfully'));
    } on AuthException {
      emit(const AppointmentUnauthenticated());
    } catch (e) {
      emit(AppointmentError(message: 'Failed to update appointment: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteAppointment(
    DeleteAppointmentEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    try {
      await deleteAppointment.execute(
        event.workshopId,
        event.appointmentId,
      );
      emit(const AppointmentOperationSuccess(message: 'Appointment deleted successfully'));
    } on AuthException {
      emit(const AppointmentUnauthenticated());
    } catch (e) {
      emit(AppointmentError(message: 'Failed to delete appointment: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateAppointmentStatus(
    UpdateAppointmentStatusEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    try {
      await updateAppointmentStatus.execute(
        workshopId: event.workshopId,
        appointmentId: event.appointmentId,
        status: event.status,
      );
      emit(const AppointmentOperationSuccess(message: 'Appointment status updated successfully'));
    } on AuthException {
      emit(const AppointmentUnauthenticated());
    } catch (e) {
      emit(AppointmentError(message: 'Failed to update appointment status: ${e.toString()}'));
    }
  }

  Future<void> _onEditNotesValue(
    EditNotesValueEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    final currentState = state;
    if (currentState is AppointmentDetailsLoaded || currentState is AppointmentOperationSuccessWithDetails) {
      final currentAppointment = currentState is AppointmentDetailsLoaded ? currentState.appointment : (currentState as AppointmentOperationSuccessWithDetails).appointment;

      try {
        // Keep current state while processing
        emit(AppointmentDetailsLoaded(appointment: currentAppointment.copyWith(notes: event.newNotes)));

        await editNotesValue.execute(
          workshopId: event.workshopId,
          appointmentId: event.appointmentId,
          newNotes: event.newNotes,
        );

        // Get updated appointment details
        final updatedAppointment = await getAppointmentDetails.execute(
          event.workshopId,
          event.appointmentId,
        );

        emit(AppointmentOperationSuccessWithDetails(
          message: 'Notatki zaktualizowane',
          appointment: updatedAppointment,
        ));
      } on AuthException {
        emit(const AppointmentUnauthenticated());
      } catch (e) {
        // Revert to original state on error
        emit(AppointmentDetailsLoaded(appointment: currentAppointment));
        emit(AppointmentError(message: 'Błąd aktualizacji notatek: ${e.toString()}'));
      }
    }
  }

  Future<void> _onLoadParts(
    LoadPartsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    try {
      final parts = await getParts.execute(
        workshopId: event.workshopId,
        appointmentId: event.appointmentId,
      );
      emit(PartsLoaded(parts: parts));
    } on AuthException {
      emit(const AppointmentUnauthenticated());
    } catch (e) {
      emit(AppointmentError(message: e.toString()));
    }
  }

  Future<void> _onAddPart(
    AddPartEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    final currentState = state;
    if (currentState is AppointmentDetailsLoaded || currentState is AppointmentOperationSuccessWithDetails) {
      try {
        await addPart.execute(
          workshopId: event.workshopId,
          appointmentId: event.appointmentId,
          name: event.name,
          description: event.description,
          quantity: event.quantity,
          costPart: event.costPart,
          costService: event.costService,
          buyCostPart: event.buyCostPart,
        );

        // Get updated appointment details
        final updatedAppointment = await getAppointmentDetails.execute(
          event.workshopId,
          event.appointmentId,
        );

        emit(AppointmentOperationSuccessWithDetails(
          message: 'Część dodana pomyślnie',
          appointment: updatedAppointment,
        ));
      } on AuthException {
        emit(const AppointmentUnauthenticated());
      } catch (e) {
        emit(AppointmentError(message: 'Błąd dodawania części: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdatePart(
    UpdatePartEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    final currentState = state;
    if (currentState is AppointmentDetailsLoaded || currentState is AppointmentOperationSuccessWithDetails) {
      final currentAppointment = currentState is AppointmentDetailsLoaded ? currentState.appointment : (currentState as AppointmentOperationSuccessWithDetails).appointment;

      try {
        // Update the part in the current state immediately
        final updatedParts = currentAppointment.parts.map((part) {
          if (part.id == event.partId) {
            return Part(
              id: part.id,
              appointmentId: currentAppointment.id,
              name: event.name,
              description: event.description,
              quantity: event.quantity,
              costPart: event.costPart,
              costService: event.costService,
              buyCostPart: event.buyCostPart,
            );
          }
          return part;
        }).toList();

        // Emit intermediate state with locally updated data
        emit(AppointmentDetailsLoaded(appointment: currentAppointment.copyWith(parts: updatedParts)));

        await updatePart.execute(
          workshopId: event.workshopId,
          appointmentId: event.appointmentId,
          partId: event.partId,
          name: event.name,
          description: event.description,
          quantity: event.quantity,
          costPart: event.costPart,
          costService: event.costService,
          buyCostPart: event.buyCostPart,
        );

        // Get updated appointment details
        final updatedAppointment = await getAppointmentDetails.execute(
          event.workshopId,
          event.appointmentId,
        );

        emit(AppointmentOperationSuccessWithDetails(
          message: 'Część zaktualizowana pomyślnie',
          appointment: updatedAppointment,
        ));
      } on AuthException {
        emit(const AppointmentUnauthenticated());
      } catch (e) {
        // Revert to original state on error
        emit(AppointmentDetailsLoaded(appointment: currentAppointment));
        emit(AppointmentError(message: 'Błąd aktualizacji części: ${e.toString()}'));
      }
    }
  }

  Future<void> _onDeletePart(
    DeletePartEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    final currentState = state;
    if (currentState is AppointmentDetailsLoaded || currentState is AppointmentOperationSuccessWithDetails) {
      final currentAppointment = currentState is AppointmentDetailsLoaded ? currentState.appointment : (currentState as AppointmentOperationSuccessWithDetails).appointment;

      try {
        // Update state immediately by removing the part
        final updatedParts = currentAppointment.parts.where((part) => part.id != event.partId).toList();
        emit(AppointmentDetailsLoaded(appointment: currentAppointment.copyWith(parts: updatedParts)));

        await deletePart.execute(
          workshopId: event.workshopId,
          appointmentId: event.appointmentId,
          partId: event.partId,
        );

        // Get updated appointment details
        final updatedAppointment = await getAppointmentDetails.execute(
          event.workshopId,
          event.appointmentId,
        );

        emit(AppointmentOperationSuccessWithDetails(
          message: 'Część usunięta pomyślnie',
          appointment: updatedAppointment,
        ));
      } on AuthException {
        emit(const AppointmentUnauthenticated());
      } catch (e) {
        // Revert to original state on error
        emit(AppointmentDetailsLoaded(appointment: currentAppointment));
        emit(AppointmentError(message: 'Błąd usuwania części: ${e.toString()}'));
      }
    }
  }

  Future<void> _onLoadRepairItems(
    LoadRepairItemsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    try {
      final repairItems = await getRepairItems.execute(
        workshopId: event.workshopId,
        appointmentId: event.appointmentId,
      );
      emit(RepairItemsLoaded(repairItems: repairItems));
    } on AuthException {
      emit(const AppointmentUnauthenticated());
    } catch (e) {
      emit(AppointmentError(message: e.toString()));
    }
  }

  Future<void> _onAddRepairItem(
    AddRepairItemEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    final currentState = state;
    if (currentState is AppointmentDetailsLoaded || currentState is AppointmentOperationSuccessWithDetails) {
      final currentAppointment = currentState is AppointmentDetailsLoaded ? currentState.appointment : (currentState as AppointmentOperationSuccessWithDetails).appointment;

      try {
        // Create temporary repair item
        final now = DateTime.now();
        final tempRepairItem = RepairItem(
          id: 'temp_${now.millisecondsSinceEpoch}',
          appointmentId: currentAppointment.id,
          description: event.description,
          status: event.status,
          order: event.order,
          isCompleted: false,
          createdAt: now,
          updatedAt: now,
        );

        // Emit intermediate state with locally updated data
        emit(AppointmentDetailsLoaded(appointment: currentAppointment.copyWith(repairItems: [...currentAppointment.repairItems, tempRepairItem])));

        await addRepairItem.execute(
          workshopId: event.workshopId,
          appointmentId: event.appointmentId,
          description: event.description,
          status: event.status,
          order: event.order,
        );

        // Get updated appointment details
        final updatedAppointment = await getAppointmentDetails.execute(
          event.workshopId,
          event.appointmentId,
        );

        emit(AppointmentOperationSuccessWithDetails(
          message: 'Element naprawy dodany',
          appointment: updatedAppointment,
        ));
      } on AuthException {
        emit(const AppointmentUnauthenticated());
      } catch (e) {
        // Revert to original state on error
        emit(AppointmentDetailsLoaded(appointment: currentAppointment));
        emit(AppointmentError(message: 'Błąd dodawania elementu naprawy: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateRepairItem(
    UpdateRepairItemEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    final currentState = state;
    if (currentState is AppointmentDetailsLoaded || currentState is AppointmentOperationSuccessWithDetails) {
      final currentAppointment = currentState is AppointmentDetailsLoaded ? currentState.appointment : (currentState as AppointmentOperationSuccessWithDetails).appointment;

      try {
        // Update repair item in the current state immediately
        final updatedRepairItems = currentAppointment.repairItems.map((item) {
          if (item.id == event.repairItemId) {
            return RepairItem(
              id: item.id,
              appointmentId: currentAppointment.id,
              description: event.description,
              status: event.status,
              order: event.order,
              isCompleted: event.isCompleted ?? false,
              createdAt: item.createdAt,
              updatedAt: DateTime.now(),
            );
          }
          return item;
        }).toList();

        // Emit intermediate state with locally updated data
        emit(AppointmentDetailsLoaded(appointment: currentAppointment.copyWith(repairItems: updatedRepairItems)));

        await updateRepairItem.execute(
          workshopId: event.workshopId,
          appointmentId: event.appointmentId,
          repairItemId: event.repairItemId,
          description: event.description,
          status: event.status,
          order: event.order,
          isCompleted: event.isCompleted ?? false,
        );

        // Get updated appointment details
        final updatedAppointment = await getAppointmentDetails.execute(
          event.workshopId,
          event.appointmentId,
        );

        emit(AppointmentOperationSuccessWithDetails(
          message: 'Element naprawy zaktualizowany',
          appointment: updatedAppointment,
        ));
      } on AuthException {
        emit(const AppointmentUnauthenticated());
      } catch (e) {
        // Revert to original state on error
        emit(AppointmentDetailsLoaded(appointment: currentAppointment));
        emit(AppointmentError(message: 'Błąd aktualizacji elementu naprawy: ${e.toString()}'));
      }
    }
  }

  Future<void> _onDeleteRepairItem(
    DeleteRepairItemEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    final currentState = state;
    if (currentState is AppointmentDetailsLoaded || currentState is AppointmentOperationSuccessWithDetails) {
      final currentAppointment = currentState is AppointmentDetailsLoaded ? currentState.appointment : (currentState as AppointmentOperationSuccessWithDetails).appointment;

      try {
        // Update state immediately by removing the repair item
        final updatedRepairItems = currentAppointment.repairItems.where((item) => item.id != event.repairItemId).toList();

        // Emit intermediate state with locally updated data
        emit(AppointmentDetailsLoaded(appointment: currentAppointment.copyWith(repairItems: updatedRepairItems)));

        await deleteRepairItem.execute(
          workshopId: event.workshopId,
          appointmentId: event.appointmentId,
          repairItemId: event.repairItemId,
        );

        // Get updated appointment details
        final updatedAppointment = await getAppointmentDetails.execute(
          event.workshopId,
          event.appointmentId,
        );

        emit(AppointmentOperationSuccessWithDetails(
          message: 'Element naprawy usunięty',
          appointment: updatedAppointment,
        ));
      } on AuthException {
        emit(const AppointmentUnauthenticated());
      } catch (e) {
        // Revert to original state on error
        emit(AppointmentDetailsLoaded(appointment: currentAppointment));
        emit(AppointmentError(message: 'Błąd usuwania elementu naprawy: ${e.toString()}'));
      }
    }
  }

  Future<void> _onResetState(
    ResetAppointmentStateEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentInitial());
  }

  Future<void> _onLogout(
    AppointmentLogoutEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const AppointmentUnauthenticated());
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
