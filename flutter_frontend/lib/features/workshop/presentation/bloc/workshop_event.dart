part of 'workshop_bloc.dart';

sealed class WorkshopEvent {
  const WorkshopEvent();
}

class LoadWorkshopsEvent extends WorkshopEvent {}

class LoadWorkshopDetailsEvent extends WorkshopEvent {
  final String workshopId;

  const LoadWorkshopDetailsEvent({required this.workshopId});
}

class AddWorkshopEvent extends WorkshopEvent {
  final String name;
  final String address;
  final String postCode;
  final String nipNumber;
  final String email;
  final String phoneNumber;

  const AddWorkshopEvent({
    required this.name,
    required this.address,
    required this.postCode,
    required this.nipNumber,
    required this.email,
    required this.phoneNumber,
  });
}

class UpdateWorkshopEvent extends WorkshopEvent {
  final String workshopId;
  final String name;
  final String address;
  final String postCode;
  final String nipNumber;
  final String email;
  final String phoneNumber;

  const UpdateWorkshopEvent({
    required this.workshopId,
    required this.name,
    required this.address,
    required this.postCode,
    required this.nipNumber,
    required this.email,
    required this.phoneNumber,
  });
}

class DeleteWorkshopEvent extends WorkshopEvent {
  final String workshopId;

  const DeleteWorkshopEvent({required this.workshopId});
}

class LoadEmployeesEvent extends WorkshopEvent {
  final String workshopId;

  const LoadEmployeesEvent({required this.workshopId});
}

class LoadEmployeeDetailsEvent extends WorkshopEvent {
  final String workshopId;
  final String employeeId;

  const LoadEmployeeDetailsEvent({
    required this.workshopId,
    required this.employeeId,
  });
}

class AssignCreatorToWorkshopEvent extends WorkshopEvent {
  final String workshopId;
  final String userId;

  const AssignCreatorToWorkshopEvent({
    required this.workshopId,
    required this.userId,
  });
}

class RemoveEmployeeFromWorkshopEvent extends WorkshopEvent {
  final String workshopId;
  final String employeeId;

  const RemoveEmployeeFromWorkshopEvent({
    required this.workshopId,
    required this.employeeId,
  });
}

class UseTemporaryCodeEvent extends WorkshopEvent {
  final String code;

  const UseTemporaryCodeEvent({required this.code});
}

class LoadTemporaryCodeEvent extends WorkshopEvent {
  final String workshopId;

  const LoadTemporaryCodeEvent({required this.workshopId});
}

class ResetWorkshopStateEvent extends WorkshopEvent {}

class WorkshopLogoutEvent extends WorkshopEvent {}