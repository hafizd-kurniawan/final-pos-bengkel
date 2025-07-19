import '../models/vehicle.dart';
import '../datasources/vehicle_remote_datasource.dart';

abstract class VehicleRepository {
  Future<VehiclesResponse> getVehicles({
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
  });
  
  Future<Vehicle> getVehicle(int id);
  Future<Vehicle> createVehicle(Map<String, dynamic> vehicleData);
  Future<Vehicle> updateVehicle(int id, Map<String, dynamic> vehicleData);
  Future<void> deleteVehicle(int id);
}

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource _remoteDataSource;

  VehicleRepositoryImpl({
    required VehicleRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<VehiclesResponse> getVehicles({
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
  }) async {
    try {
      return await _remoteDataSource.getVehicles(
        page: page,
        limit: limit,
        status: status,
        search: search,
      );
    } catch (e) {
      throw Exception('Failed to fetch vehicles: $e');
    }
  }

  @override
  Future<Vehicle> getVehicle(int id) async {
    try {
      return await _remoteDataSource.getVehicle(id);
    } catch (e) {
      throw Exception('Failed to fetch vehicle: $e');
    }
  }

  @override
  Future<Vehicle> createVehicle(Map<String, dynamic> vehicleData) async {
    try {
      return await _remoteDataSource.createVehicle(vehicleData);
    } catch (e) {
      throw Exception('Failed to create vehicle: $e');
    }
  }

  @override
  Future<Vehicle> updateVehicle(int id, Map<String, dynamic> vehicleData) async {
    try {
      return await _remoteDataSource.updateVehicle(id, vehicleData);
    } catch (e) {
      throw Exception('Failed to update vehicle: $e');
    }
  }

  @override
  Future<void> deleteVehicle(int id) async {
    try {
      await _remoteDataSource.deleteVehicle(id);
    } catch (e) {
      throw Exception('Failed to delete vehicle: $e');
    }
  }
}