import 'package:flutter_frontend/features/appointments/domain/entities/appointment.dart';
import 'package:flutter_frontend/features/appointments/domain/entities/part.dart';
import 'package:flutter_frontend/features/appointments/domain/entities/repair_item.dart';
import 'package:flutter_frontend/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:flutter_frontend/features/appointments/data/datasources/appointment_remote_data_source.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  AppointmentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Appointment>> getAppointments(String workshopId) async {
    try {
      final models = await remoteDataSource.getAppointments(workshopId);
      return models.map((model) => model.toEntity()).toList();
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<Appointment> getAppointmentDetails(String workshopId, String appointmentId) async {
    try {
      final model = await remoteDataSource.getAppointmentDetails(workshopId, appointmentId);
      return model.toEntity();
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<String> addAppointment({
    required String workshopId,
    required String clientId,
    required String vehicleId,
    required DateTime scheduledTime,
    String? notes,
    required int mileage,
    String? recommendations,
    Duration? estimatedDuration,
    double? totalCost,
    required String status,
  }) async {
    try {
      return await remoteDataSource.addAppointment(
        workshopId: workshopId,
        clientId: clientId,
        vehicleId: vehicleId,
        scheduledTime: scheduledTime,
        notes: notes,
        mileage: mileage,
        recommendations: recommendations,
        estimatedDuration: estimatedDuration,
        totalCost: totalCost,
        status: status,
      );
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> updateAppointment({
    required String workshopId,
    required String appointmentId,
    required String status,
    String? notes,
    int? mileage,
    String? recommendations,
    Duration? estimatedDuration,
    double? totalCost,
  }) async {
    try {
      await remoteDataSource.updateAppointment(
        workshopId: workshopId,
        appointmentId: appointmentId,
        status: status,
        notes: notes,
        totalCost: totalCost,
      );
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> deleteAppointment(String workshopId, String appointmentId) async {
    try {
      await remoteDataSource.deleteAppointment(workshopId, appointmentId);
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> editNotesValue({
    required String workshopId,
    required String appointmentId,
    required String newNotes,
  }) async {
    try {
      await remoteDataSource.editNotesValue(
        workshopId: workshopId,
        appointmentId: appointmentId,
        newNotes: newNotes,
      );
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<List<RepairItem>> getRepairItems({
    required String workshopId,
    required String appointmentId,
  }) async {
    try {
      final models = await remoteDataSource.getRepairItems(
        workshopId: workshopId,
        appointmentId: appointmentId,
      );
      return models.map((model) => model.toEntity()).toList();
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<RepairItem> addRepairItem({
    required String workshopId,
    required String appointmentId,
    required String description,
    required String status,
    required int order,
  }) async {
    try {
      final model = await remoteDataSource.addRepairItem(
        workshopId: workshopId,
        appointmentId: appointmentId,
        description: description,
        status: status,
        order: order,
      );
      return model.toEntity();
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<RepairItem> updateRepairItem({
    required String workshopId,
    required String appointmentId,
    required String repairItemId,
    required String description,
    required String status,
    required int order,
    bool? isCompleted,
  }) async {
    try {
      final model = await remoteDataSource.updateRepairItem(
        workshopId: workshopId,
        appointmentId: appointmentId,
        repairItemId: repairItemId,
        description: description,
        status: status,
        order: order,
        isCompleted: isCompleted,
      );
      return model.toEntity();
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> deleteRepairItem({
    required String workshopId,
    required String appointmentId,
    required String repairItemId,
  }) async {
    try {
      await remoteDataSource.deleteRepairItem(
        workshopId: workshopId,
        appointmentId: appointmentId,
        repairItemId: repairItemId,
      );
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<List<Part>> getParts({
    required String workshopId,
    required String appointmentId,
  }) async {
    try {
      final models = await remoteDataSource.getParts(
        workshopId: workshopId,
        appointmentId: appointmentId,
      );
      return models.map((model) => model.toEntity()).toList();
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<Part> addPart({
    required String workshopId,
    required String appointmentId,
    required String name,
    required String description,
    required int quantity,
    required double costPart,
    required double costService,
    required double buyCostPart,
  }) async {
    try {
      final model = await remoteDataSource.addPart(
        workshopId: workshopId,
        appointmentId: appointmentId,
        name: name,
        description: description,
        quantity: quantity,
        costPart: costPart,
        costService: costService,
        buyCostPart: buyCostPart,
      );
      return model.toEntity();
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<Part> updatePart({
    required String workshopId,
    required String appointmentId,
    required String partId,
    required String name,
    required String description,
    required int quantity,
    required double costPart,
    required double costService,
    required double buyCostPart,
  }) async {
    try {
      final model = await remoteDataSource.updatePart(
        workshopId: workshopId,
        appointmentId: appointmentId,
        partId: partId,
        name: name,
        description: description,
        quantity: quantity,
        costPart: costPart,
        costService: costService,
        buyCostPart: buyCostPart,
      );
      return model.toEntity();
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> deletePart({
    required String workshopId,
    required String appointmentId,
    required String partId,
  }) async {
    try {
      await remoteDataSource.deletePart(
        workshopId: workshopId,
        appointmentId: appointmentId,
        partId: partId,
      );
    } on Exception {
      rethrow;
    }
  }
}

