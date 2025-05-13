// import 'dart:convert';
// import 'package:flutter_frontend/services/auth_service.dart';
// import 'package:http/http.dart' as http;
// import '../models/appointment.dart';
// import '../models/part.dart';
// import '../models/repair_item.dart';
// import '../core/utils/constants.dart';

// class AppointmentService {
//   Future<List<Appointment>> getAppointments(
//       String accessToken, String workshopId) async {
//     final url = Uri.parse('$baseUrl/workshops/$workshopId/appointments/');
//     final response = await http.get(
//       url,
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//         'Content-Type': 'application/json',
//       },
//     );

// if (response.statusCode == 200) {
//       final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
//       return data.map((json) => Appointment.fromJson(json)).toList();
//     } else if (response.statusCode == 401) {
//       // Token wygasł, odśwież token
//       await AuthService.refreshToken();
//       final newAccessToken = await AuthService.getAccessToken();
//       if (newAccessToken != null) {
//         return getAppointments(newAccessToken, workshopId);
//       } else {
//         throw Exception('Błąd odświeżania tokena');
//       }
//     } else {
//       throw Exception('Błąd podczas pobierania listy zleceń: ${response.statusCode}');
//     }
//   }

//   static Future<void> editNotesValue({
//     required String accessToken,
//     required String workshopId,
//     required String appointmentId,
//     required String newNotes,
//   }) async {
//     final url = Uri.parse('$baseUrl/workshops/$workshopId/appointments/$appointmentId/');
    
//     final response = await http.patch(
//       url,
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//         'Content-Type': 'application/json',
//       },
//       body: json.encode({
//         'notes': newNotes,
//       }),
//     );

//     if (response.statusCode != 200) {
//       if(response.statusCode ==401){
//         await AuthService.refreshToken();
//         final newAccessToken = await AuthService.getAccessToken();
//         if (newAccessToken != null) {
//           return editNotesValue(
//             accessToken: newAccessToken,
//             workshopId: workshopId,
//             appointmentId: appointmentId,
//             newNotes: newNotes,
//           );
//         } else {
//           throw Exception('Błąd odświeżania tokena');
//         }
//       }
//       throw Exception('Błąd podczas aktualizacji notatek: ${response.body}');
//     }
//   }

//   static Future<String> createAppointment({
//     required String accessToken,
//     required String workshopId,
//     required String clientId,
//     required String vehicleId,
//     required DateTime scheduledTime,
//     String? notes,
//     required int mileage,
//     String? recommendations,
//     Duration? estimatedDuration,
//     double? totalCost,
//     required String status,
//   }) async {
//     final url = Uri.parse('$baseUrl/workshops/$workshopId/appointments/');
//     final response = await http.post(
//       url,
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//         'Content-Type': 'application/json',
//       },
//       body: json.encode({
//         'client_id': clientId,
//         'vehicle_id': vehicleId,
//         'scheduled_time': scheduledTime.toIso8601String(),
//         'notes': notes,
//         'mileage': mileage,
//         'recommendations': recommendations,
//         'estimated_duration': estimatedDuration?.inMinutes,
//         'total_cost': totalCost,
//         'status': status,
//       }),
//     );

// if (response.statusCode == 201) {
//     final data = json.decode(utf8.decode(response.bodyBytes));
//     return data['id'];
//   } else if (response.statusCode == 401) {
//     await AuthService.refreshToken();
//     final newAccessToken = await AuthService.getAccessToken();
//     if (newAccessToken != null) {
//       return createAppointment(
//         accessToken: newAccessToken,
//         workshopId: workshopId,
//         clientId: clientId,
//         vehicleId: vehicleId,
//         scheduledTime: scheduledTime,
//         notes: notes,
//         mileage: mileage,
//         recommendations: recommendations,
//         estimatedDuration: estimatedDuration,
//         totalCost: totalCost,
//         status: status,
//       );
//     } else {
//       throw Exception('Błąd odświeżania tokena');
//     }
//   } else {
//     throw Exception('Błąd podczas tworzenia zlecenia: ${response.statusCode}');
//   }
// }

// static Future<void> updateAppointmentStatus({
//     required String accessToken,
//     required String workshopId,
//     required String appointmentId,
//     required String status,
//   }) async {
//     final url = Uri.parse('$baseUrl/workshops/$workshopId/appointments/$appointmentId/');
//     final response = await http.patch(
//       url,
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//         'Content-Type': 'application/json',
//       },
//       body: json.encode({'status': status}),
//     );

//  if (response.statusCode != 200) {
//     if (response.statusCode == 401) {
//       await AuthService.refreshToken();
//       final newAccessToken = await AuthService.getAccessToken();
//       if (newAccessToken != null) {
//         return updateAppointmentStatus(
//           accessToken: newAccessToken,
//           workshopId: workshopId,
//           appointmentId: appointmentId,
//           status: status,
//         );
//       } else {
//         throw Exception('Błąd odświeżania tokena');
//       }
//     } else {
//       throw Exception('Błąd podczas aktualizacji statusu: ${response.body}');
//     }
//   }
// }

//   static Future<void> createRepairItem(
//     String accessToken,
//     String workshopId,
//     String appointmentId,
//     String description,
//     String status,
//     int order,
//   ) async {
//     final url = Uri.parse(
//         '$baseUrl/workshops/$workshopId/appointments/$appointmentId/repair-items/');
//     final body = {
//       'description': description,
//       'status': status,
//       'order': order,
//     };
//     final response = await http.post(
//       url,
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//         'Content-Type': 'application/json',
//       },
//       body: json.encode(body),
//     );

// if (response.statusCode != 201) {
//     if (response.statusCode == 401) {
//       await AuthService.refreshToken();
//       final newAccessToken = await AuthService.getAccessToken();
//       if (newAccessToken != null) {
//         return createRepairItem(
//           newAccessToken,
//           workshopId,
//           appointmentId,
//           description,
//           status,
//           order,
//         );
//       } else {
//         throw Exception('Błąd odświeżania tokena');
//       }
//     } else {
//       throw Exception('Błąd podczas tworzenia elementu naprawy: ${response.body}');
//     }
//   }
// }

// static Future<void> updateRepairItem(
//   String accessToken,
//   String workshopId,
//   String appointmentId,
//   String repairItemId, {
//   required String description,
//   required String status,
//   required int order,
//   bool? isCompleted,
// }) async {
//   final url = Uri.parse(
//       '$baseUrl/workshops/$workshopId/appointments/$appointmentId/repair-items/$repairItemId/');
//   final body = {
//     'description': description,
//     'status': status,
//     'order': order,
//     if (isCompleted != null) 'is_completed': isCompleted,
//   };
//   final response = await http.patch(
//     url,
//     headers: {
//       'Authorization': 'Bearer $accessToken',
//       'Content-Type': 'application/json',
//     },
//     body: json.encode(body),
//   );

//   if (response.statusCode != 200) {
//     if (response.statusCode == 401) {
//       await AuthService.refreshToken();
//       final newAccessToken = await AuthService.getAccessToken();
//       if (newAccessToken != null) {
//         return updateRepairItem(
//           newAccessToken,
//           workshopId,
//           appointmentId,
//           repairItemId,
//           description: description,
//           status: status,
//           order: order,
//           isCompleted: isCompleted,
//         );
//       } else {
//         throw Exception('Błąd odświeżania tokena');
//       }
//     }
//     throw Exception('Błąd podczas aktualizacji elementu naprawy: ${response.body}');
//   }
// }

// Future<Appointment> getAppointmentDetails(
//     String accessToken, String workshopId, String appointmentId) async {
//   final url =
//       Uri.parse('$baseUrl/workshops/$workshopId/appointments/$appointmentId/');
//   final response = await http.get(
//     url,
//     headers: {
//       'Authorization': 'Bearer $accessToken',
//       'Content-Type': 'application/json',
//     },
//   );

//   if (response.statusCode == 200) {
//     final data = json.decode(utf8.decode(response.bodyBytes));
//     return Appointment.fromJson(data);
//   } else if (response.statusCode == 401) {
//     await AuthService.refreshToken();
//     final newAccessToken = await AuthService.getAccessToken();
//     if (newAccessToken != null) {
//       return getAppointmentDetails(newAccessToken, workshopId, appointmentId);
//     } else {
//       throw Exception('Błąd odświeżania tokena');
//     }
//   } else {
//     throw Exception(
//         'Błąd podczas pobierania szczegółów zlecenia: ${response.statusCode}');
//   }
// }

// static Future<void> updateRepairItemStatus(
//   String accessToken,
//   String workshopId,
//   String appointmentId,
//   String repairItemId,
//   bool isCompleted,
// ) async {
//   final url = Uri.parse(
//       '$baseUrl/workshops/$workshopId/appointments/$appointmentId/repair-items/$repairItemId/');

//   final existingRepairItem = await getRepairItemDetails(
//     accessToken,
//     workshopId,
//     appointmentId,
//     repairItemId,
//   );

//   final updatedRepairItemData = {
//     'description': existingRepairItem.description,
//     'is_completed': isCompleted,
//     'status': existingRepairItem.status,
//     'order': existingRepairItem.order,
//   };

//   final response = await http.put(
//     url,
//     headers: {
//       'Authorization': 'Bearer $accessToken',
//       'Content-Type': 'application/json',
//     },
//     body: json.encode(updatedRepairItemData),
//   );

//   if (response.statusCode != 200 && response.statusCode != 204) {
//     if (response.statusCode == 401) {
//       await AuthService.refreshToken();
//       final newAccessToken = await AuthService.getAccessToken();
//       if (newAccessToken != null) {
//         return updateRepairItemStatus(
//           newAccessToken,
//           workshopId,
//           appointmentId,
//           repairItemId,
//           isCompleted,
//         );
//       } else {
//         throw Exception('Błąd odświeżania tokena');
//       }
//     } else {
//       throw Exception(
//           'Błąd podczas aktualizacji statusu elementu naprawy: ${response.body}');
//     }
//   }
// }
// static Future<RepairItem> getRepairItemDetails(
//   String accessToken,
//   String workshopId,
//   String appointmentId,
//   String repairItemId,
// ) async {
//   final url = Uri.parse(
//       '$baseUrl/workshops/$workshopId/appointments/$appointmentId/repair-items/$repairItemId/');
//   final response = await http.get(
//     url,
//     headers: {
//       'Authorization': 'Bearer $accessToken',
//       'Content-Type': 'application/json',
//     },
//   );

//   if (response.statusCode == 200) {
//     final data = json.decode(utf8.decode(response.bodyBytes));
//     return RepairItem.fromJson(data);
//   } else if (response.statusCode == 401) {
//     await AuthService.refreshToken();
//     final newAccessToken = await AuthService.getAccessToken();
//     if (newAccessToken != null) {
//       return getRepairItemDetails(
//         newAccessToken,
//         workshopId,
//         appointmentId,
//         repairItemId,
//       );
//     } else {
//       throw Exception('Błąd odświeżania tokena');
//     }
//   } else {
//     throw Exception(
//         'Błąd podczas pobierania szczegółów elementu naprawy: ${response.statusCode}');
//   }
// }

// static Future<void> deleteRepairItem(
//   String accessToken,
//   String workshopId,
//   String appointmentId,
//   String repairItemId,
// ) async {
//   final url = Uri.parse(
//       '$baseUrl/workshops/$workshopId/appointments/$appointmentId/repair-items/$repairItemId/');
//   final response = await http.delete(
//     url,
//     headers: {
//       'Authorization': 'Bearer $accessToken',
//       'Content-Type': 'application/json',
//     },
//   );

//   if (response.statusCode != 204) {
//     if (response.statusCode == 401) {
//       await AuthService.refreshToken();
//       final newAccessToken = await AuthService.getAccessToken();
//       if (newAccessToken != null) {
//         return deleteRepairItem(
//           newAccessToken,
//           workshopId,
//           appointmentId,
//           repairItemId,
//         );
//       } else {
//         throw Exception('Błąd odświeżania tokena');
//       }
//     } else {
//       throw Exception('Błąd podczas usuwania elementu naprawy: ${response.body}');
//     }
//   }
// }
// static Future<void> createPart(
//   String accessToken,
//   String workshopId,
//   String appointmentId,
//   String name,
//   String description,
//   int quantity,
//   double costPart,
//   double costService,
//   double buyCostPart,
// ) async {
//   final url = Uri.parse(
//       '$baseUrl/workshops/$workshopId/appointments/$appointmentId/parts/');
//   final body = {
//     'name': name,
//     'description': description,
//     'quantity': quantity,
//     'cost_part': costPart.toString(),
//     'cost_service': costService.toString(),
//     'buy_cost_part': buyCostPart.toString(),
//     'appointment': appointmentId,
//   };

//   final response = await http.post(
//     url,
//     headers: {
//       'Authorization': 'Bearer $accessToken',
//       'Content-Type': 'application/json',
//     },
//     body: json.encode(body),
//   );

//   if (response.statusCode != 201) {
//     if (response.statusCode == 401) {
//       await AuthService.refreshToken();
//       final newAccessToken = await AuthService.getAccessToken();
//       if (newAccessToken != null) {
//         return createPart(
//           newAccessToken,
//           workshopId,
//           appointmentId,
//           name,
//           description,
//           quantity,
//           costPart,
//           costService,
//           buyCostPart,
//         );
//       } else {
//         throw Exception('Błąd odświeżania tokena');
//       }
//     } else {
//       throw Exception('Błąd podczas dodawania części: ${response.body}');
//     }
//   }
// }
// static Future<List<Part>> getParts(
//   String accessToken,
//   String workshopId,
//   String appointmentId,
// ) async {
//   final url = Uri.parse(
//       '$baseUrl/workshops/$workshopId/appointments/$appointmentId/parts/');
//   final response = await http.get(
//     url,
//     headers: {
//       'Authorization': 'Bearer $accessToken',
//       'Content-Type': 'application/json',
//     },
//   );

//   if (response.statusCode == 200) {
//     final data = json.decode(utf8.decode(response.bodyBytes)) as List;
//     return data.map((json) => Part.fromJson(json)).toList();
//   } else if (response.statusCode == 401) {
//     await AuthService.refreshToken();
//     final newAccessToken = await AuthService.getAccessToken();
//     if (newAccessToken != null) {
//       return getParts(newAccessToken, workshopId, appointmentId);
//     } else {
//       throw Exception('Błąd odświeżania tokena');
//     }
//   } else {
//     throw Exception('Błąd podczas pobierania części: ${response.body}');
//   }
// }

//  static Future<void> updatePart(
//   String accessToken,
//   String workshopId,
//   String appointmentId,
//   String partId, {
//   required String name,
//   required String description,
//   required int quantity,
//   required double costPart,
//   required double costService,
//   required double buyCostPart,
// }) async {
//   final url = Uri.parse(
//       '$baseUrl/workshops/$workshopId/appointments/$appointmentId/parts/$partId/');
//   final body = {
//     'name': name,
//     'description': description,
//     'quantity': quantity,
//     'cost_part': costPart.toString(),
//     'cost_service': costService.toString(),
//     'buy_cost_part': buyCostPart.toString(),
//   };
//   final response = await http.patch(
//     url,
//     headers: {
//       'Authorization': 'Bearer $accessToken',
//       'Content-Type': 'application/json',
//     },
//     body: json.encode(body),
//   );

//   if (response.statusCode != 200) {
//     if (response.statusCode == 401) {
//       await AuthService.refreshToken();
//       final newAccessToken = await AuthService.getAccessToken();
//       if (newAccessToken != null) {
//         return updatePart(
//           newAccessToken,
//           workshopId,
//           appointmentId,
//           partId,
//           name: name,
//           description: description,
//           quantity: quantity,
//           costPart: costPart,
//           costService: costService,
//           buyCostPart: buyCostPart,
//         );
//       } else {
//         throw Exception('Błąd odświeżania tokena');
//       }
//     } else {
//       throw Exception('Błąd podczas aktualizacji części: ${response.body}');
//     }
//   }
// }

//   static Future<void> deletePart(
//     String accessToken,
//     String workshopId,
//     String appointmentId,
//     String partId,
//   ) async {
//     final url = Uri.parse(
//         '$baseUrl/workshops/$workshopId/appointments/$appointmentId/parts/$partId/');
//     final response = await http.delete(
//       url,
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//         'Content-Type': 'application/json',
//       },
//     );

//     if(response.statusCode != 204){
//       if(response.statusCode == 401){
//         await AuthService.refreshToken();
//         final newAccessToken = await AuthService.getAccessToken();
//         if (newAccessToken != null) {
//           return deletePart(
//             newAccessToken,
//             workshopId,
//             appointmentId,
//             partId,
//           );
//         } else {
//           throw Exception('Błąd odświeżania tokena');
//         }
//       } else {
//         throw Exception('Błąd podczas usuwania części: ${response.body}');
//       }
//     }
//   }
// }
