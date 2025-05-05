part of 'appointment_bloc.dart';

sealed class AppointmentEvent {
  const AppointmentEvent();
}

class LoadAppointmentsEvent extends AppointmentEvent {
  final String workshopId;

  const LoadAppointmentsEvent({required this.workshopId});
}

class LoadAppointmentDetailsEvent extends AppointmentEvent {
  final String workshopId;
  final String appointmentId;

  LoadAppointmentDetailsEvent({
    required this.workshopId, 
    required this.appointmentId
  });
}

class AddAppointmentEvent extends AppointmentEvent {
  final String workshopId;
  final String clientId;
  final String vehicleId;
  final DateTime scheduledTime;
  final String? notes;
  final int mileage;
  final String? recommendations;
  final Duration? estimatedDuration;
  final double? totalCost;
  final String status;

  AddAppointmentEvent({
    required this.workshopId,
    required this.clientId,
    required this.vehicleId,
    required this.scheduledTime,
    required this.mileage,
    required this.status,
    this.notes,
    this.recommendations,
    this.estimatedDuration,
    this.totalCost,
  });
}

class UpdateAppointmentEvent extends AppointmentEvent {
  final String workshopId;
  final String appointmentId;
  final String status;
  final String? notes;
  final int? mileage;
  final String? recommendations;
  final Duration? estimatedDuration;
  final double? totalCost;

  UpdateAppointmentEvent({
    required this.workshopId,
    required this.appointmentId,
    required this.status,
    this.notes,
    this.mileage,
    this.recommendations,
    this.estimatedDuration,
    this.totalCost,
  });
}

class DeleteAppointmentEvent extends AppointmentEvent {
  final String workshopId;
  final String appointmentId;

  DeleteAppointmentEvent({
    required this.workshopId, 
    required this.appointmentId
  });
}

class UpdateAppointmentStatusEvent extends AppointmentEvent {
  final String workshopId;
  final String appointmentId;
  final String status;

  UpdateAppointmentStatusEvent({
    required this.workshopId,
    required this.appointmentId,
    required this.status,
  });
}

class EditNotesValueEvent extends AppointmentEvent {
  final String workshopId;
  final String appointmentId;
  final String newNotes;

  EditNotesValueEvent({
    required this.workshopId,
    required this.appointmentId,
    required this.newNotes,
  });
}

class LoadPartsEvent extends AppointmentEvent {
  final String workshopId;
  final String appointmentId;

  LoadPartsEvent({
    required this.workshopId, 
    required this.appointmentId
  });
}

class AddPartEvent extends AppointmentEvent {
  final String workshopId;
  final String appointmentId;
  final String name;
  final String description;
  final int quantity;
  final double costPart;
  final double costService;
  final double buyCostPart;

  AddPartEvent({
    required this.workshopId,
    required this.appointmentId,
    required this.name,
    required this.description,
    required this.quantity,
    required this.costPart,
    required this.costService,
    required this.buyCostPart,
  });
}

class UpdatePartEvent extends AppointmentEvent {
  final String workshopId;
  final String appointmentId;
  final String partId;
  final String name;
  final String description;
  final int quantity;
  final double costPart;
  final double costService;
  final double buyCostPart;

  UpdatePartEvent({
    required this.workshopId,
    required this.appointmentId,
    required this.partId,
    required this.name,
    required this.description,
    required this.quantity,
    required this.costPart,
    required this.costService,
    required this.buyCostPart,
  });
}

class DeletePartEvent extends AppointmentEvent {
  final String workshopId;
  final String appointmentId;
  final String partId;

  DeletePartEvent({
    required this.workshopId,
    required this.appointmentId,
    required this.partId,
  });
}

class LoadRepairItemsEvent extends AppointmentEvent {
  final String workshopId;
  final String appointmentId;

  LoadRepairItemsEvent({
    required this.workshopId, 
    required this.appointmentId
  });
}

class AddRepairItemEvent extends AppointmentEvent {
  final String workshopId;
  final String appointmentId;
  final String description;
  final String status;
  final int order;

  AddRepairItemEvent({
    required this.workshopId,
    required this.appointmentId,
    required this.description,
    required this.status,
    required this.order,
  });
}

class UpdateRepairItemEvent extends AppointmentEvent {
  final String workshopId;
  final String appointmentId;
  final String repairItemId;
  final String description;
  final String status;
  final int order;
  final bool? isCompleted;

  UpdateRepairItemEvent({
    required this.workshopId,
    required this.appointmentId,
    required this.repairItemId,
    required this.description,
    required this.status,
    required this.order,
    this.isCompleted,
  });
}

class DeleteRepairItemEvent extends AppointmentEvent {
  final String workshopId;
  final String appointmentId;
  final String repairItemId;

  DeleteRepairItemEvent({
    required this.workshopId,
    required this.appointmentId,
    required this.repairItemId,
  });
}

class ResetAppointmentStateEvent extends AppointmentEvent {}

class AppointmentLogoutEvent extends AppointmentEvent {}