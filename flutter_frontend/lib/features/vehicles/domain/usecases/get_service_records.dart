import '../repositories/vehicle_repository.dart';
import '../../domain/entities/service_record.dart';

class GetServiceRecords {
  final VehicleRepository repository;

  GetServiceRecords(this.repository);

  Future<List<ServiceRecord>> execute(String workshopId, String vehicleId) async {
    return await repository.getServiceRecords(workshopId, vehicleId);
  }
}
