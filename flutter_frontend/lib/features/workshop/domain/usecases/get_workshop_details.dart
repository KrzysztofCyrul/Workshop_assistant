import 'package:flutter_frontend/features/workshop/domain/entities/workshop.dart';
import 'package:flutter_frontend/features/workshop/domain/repositories/workshop_repository.dart';

class GetWorkshopDetails {
  final WorkshopRepository repository;

  GetWorkshopDetails(this.repository);

  Future<Workshop> call(String workshopId) async {
    return await repository.getWorkshopDetails(workshopId);
  }
}