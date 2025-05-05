import 'package:flutter_frontend/features/workshop/domain/entities/workshop.dart';
import 'package:flutter_frontend/features/workshop/domain/repositories/workshop_repository.dart';

class GetWorkshops {
  final WorkshopRepository repository;

  GetWorkshops(this.repository);

  Future<List<Workshop>> call() async {
    return await repository.getWorkshops();
  }
}