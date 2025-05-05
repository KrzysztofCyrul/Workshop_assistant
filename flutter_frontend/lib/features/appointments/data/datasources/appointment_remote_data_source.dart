import 'package:dio/dio.dart';
import 'package:flutter_frontend/core/utils/constants.dart' as api_constants;
import 'package:flutter_frontend/features/appointments/data/models/appointment_model.dart';
import 'package:flutter_frontend/features/appointments/data/models/part_model.dart';
import 'package:flutter_frontend/features/appointments/data/models/repair_item_model.dart';
import 'package:flutter_frontend/core/errors/dio_error_handler.dart';

class AppointmentRemoteDataSource {
  final Dio dio;

  AppointmentRemoteDataSource({required this.dio});

  Future<List<AppointmentModel>> getAppointments(String workshopId) async {
    try {
      final response = await dio.get('${api_constants.baseUrl}/workshops/$workshopId/appointments/');
      return (response.data as List).map((json) => AppointmentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<AppointmentModel> getAppointmentDetails(String workshopId, String appointmentId) async {
    try {
      final response = await dio.get('${api_constants.baseUrl}/workshops/$workshopId/appointments/$appointmentId/');
      return AppointmentModel.fromJson(response.data);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

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
      final response = await dio.post(
        '${api_constants.baseUrl}/workshops/$workshopId/appointments/',
        data: {
          'client_id': clientId,
          'vehicle_id': vehicleId,
          'scheduled_time': scheduledTime.toIso8601String(),
          'notes': notes,
          'mileage': mileage,
          'recommendations': recommendations,
          'estimated_duration': estimatedDuration?.inMinutes,
          'total_cost': totalCost,
          'status': status,
        },
      );
      
      return response.data['id'];
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

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
      await dio.put(
        '${api_constants.baseUrl}/workshops/$workshopId/appointments/$appointmentId/',
        data: {
          'status': status,
          'notes': notes,
          'mileage': mileage,
          'recommendations': recommendations,
          'estimated_duration': estimatedDuration?.inMinutes,
          'total_cost': totalCost,
        },
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<void> deleteAppointment(String workshopId, String appointmentId) async {
    try {
      await dio.delete('${api_constants.baseUrl}/workshops/$workshopId/appointments/$appointmentId/');
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<void> updateAppointmentStatus({
    required String workshopId,
    required String appointmentId,
    required String status,
  }) async {
    try {
      await dio.patch(
        '${api_constants.baseUrl}/workshops/$workshopId/appointments/$appointmentId/',
        data: {'status': status},
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<void> editNotesValue({
    required String workshopId,
    required String appointmentId,
    required String newNotes,
  }) async {
    try {
      await dio.patch(
        '${api_constants.baseUrl}/workshops/$workshopId/appointments/$appointmentId/',
        data: {'notes': newNotes},
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<List<RepairItemModel>> getRepairItems({
    required String workshopId,
    required String appointmentId,
  }) async {
    try {
      final response = await dio.get(
        '${api_constants.baseUrl}/workshops/$workshopId/appointments/$appointmentId/repair-items/',
      );
      return (response.data as List).map((json) => RepairItemModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<RepairItemModel> addRepairItem({
    required String workshopId,
    required String appointmentId,
    required String description,
    required String status,
    required int order,
  }) async {
    try {
      final response = await dio.post(
        '${api_constants.baseUrl}/workshops/$workshopId/appointments/$appointmentId/repair-items/',
        data: {
          'description': description,
          'status': status,
          'order': order,
        },
      );
      return RepairItemModel.fromJson(response.data);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<RepairItemModel> updateRepairItem({
    required String workshopId,
    required String appointmentId,
    required String repairItemId,
    required String description,
    required String status,
    required int order,
    bool? isCompleted,
  }) async {
    try {
      final response = await dio.patch(
        '${api_constants.baseUrl}/workshops/$workshopId/appointments/$appointmentId/repair-items/$repairItemId/',
        data: {
          'description': description,
          'status': status,
          'order': order,
          if (isCompleted != null) 'is_completed': isCompleted,
        },
      );
      return RepairItemModel.fromJson(response.data);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<void> deleteRepairItem({
    required String workshopId,
    required String appointmentId,
    required String repairItemId,
  }) async {
    try {
      await dio.delete(
        '${api_constants.baseUrl}/workshops/$workshopId/appointments/$appointmentId/repair-items/$repairItemId/',
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<List<PartModel>> getParts({
    required String workshopId,
    required String appointmentId,
  }) async {
    try {
      final response = await dio.get(
        '${api_constants.baseUrl}/workshops/$workshopId/appointments/$appointmentId/parts/',
      );
      return (response.data as List).map((json) => PartModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<PartModel> addPart({
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
      final response = await dio.post(
        '${api_constants.baseUrl}/workshops/$workshopId/appointments/$appointmentId/parts/',
        data: {
          'name': name,
          'description': description,
          'quantity': quantity,
          'cost_part': costPart.toString(),
          'cost_service': costService.toString(),
          'buy_cost_part': buyCostPart.toString(),
          'appointment': appointmentId,
        },
      );
      return PartModel.fromJson(response.data);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<PartModel> updatePart({
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
      final response = await dio.patch(
        '${api_constants.baseUrl}/workshops/$workshopId/appointments/$appointmentId/parts/$partId/',
        data: {
          'name': name,
          'description': description,
          'quantity': quantity,
          'cost_part': costPart.toString(),
          'cost_service': costService.toString(),
          'buy_cost_part': buyCostPart.toString(),
        },
      );
      return PartModel.fromJson(response.data);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<void> deletePart({
    required String workshopId,
    required String appointmentId,
    required String partId,
  }) async {
    try {
      await dio.delete(
        '${api_constants.baseUrl}/workshops/$workshopId/appointments/$appointmentId/parts/$partId/',
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }
}