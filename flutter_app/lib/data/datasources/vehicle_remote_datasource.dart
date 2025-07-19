import '../../core/network/network_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/vehicle.dart';

class VehiclesResponse {
  final List<Vehicle> vehicles;
  final VehiclesMeta meta;

  const VehiclesResponse({
    required this.vehicles,
    required this.meta,
  });

  factory VehiclesResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    final vehicles = dataList
        .map((item) => Vehicle.fromJson(item as Map<String, dynamic>))
        .toList();

    return VehiclesResponse(
      vehicles: vehicles,
      meta: VehiclesMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class VehiclesMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const VehiclesMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory VehiclesMeta.fromJson(Map<String, dynamic> json) {
    return VehiclesMeta(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}

abstract class VehicleRemoteDataSource {
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

class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final NetworkService _networkService;

  VehicleRemoteDataSourceImpl({
    required NetworkService networkService,
  }) : _networkService = networkService;

  @override
  Future<VehiclesResponse> getVehicles({
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null && status.isNotEmpty) {
        queryParameters['status'] = status;
      }

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      final response = await _networkService.get(
        AppConstants.vehiclesEndpoint,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return VehiclesResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch vehicles: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to fetch vehicles: $e');
    }
  }

  @override
  Future<Vehicle> getVehicle(int id) async {
    try {
      final response = await _networkService.get(
        '${AppConstants.vehiclesEndpoint}/$id',
      );

      if (response.statusCode == 200) {
        return Vehicle.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch vehicle: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to fetch vehicle: $e');
    }
  }

  @override
  Future<Vehicle> createVehicle(Map<String, dynamic> vehicleData) async {
    try {
      final response = await _networkService.post(
        AppConstants.vehiclesEndpoint,
        data: vehicleData,
      );

      if (response.statusCode == 201) {
        return Vehicle.fromJson(response.data);
      } else {
        throw Exception('Failed to create vehicle: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to create vehicle: $e');
    }
  }

  @override
  Future<Vehicle> updateVehicle(int id, Map<String, dynamic> vehicleData) async {
    try {
      final response = await _networkService.put(
        '${AppConstants.vehiclesEndpoint}/$id',
        data: vehicleData,
      );

      if (response.statusCode == 200) {
        return Vehicle.fromJson(response.data);
      } else {
        throw Exception('Failed to update vehicle: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to update vehicle: $e');
    }
  }

  @override
  Future<void> deleteVehicle(int id) async {
    try {
      final response = await _networkService.delete(
        '${AppConstants.vehiclesEndpoint}/$id',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete vehicle: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to delete vehicle: $e');
    }
  }
}