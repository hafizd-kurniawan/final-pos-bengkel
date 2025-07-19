import '../../core/network/network_service.dart';
import '../models/test_drive.dart';

class TestDriveApiService {
  final NetworkService _networkService;

  TestDriveApiService(this._networkService);

  Future<List<TestDrive>> getTestDrives({
    int page = 1,
    int limit = 10,
    String? status,
    int? vehicleId,
    int? customerId,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (status != null) queryParams['status'] = status;
    if (vehicleId != null) queryParams['vehicle_id'] = vehicleId;
    if (customerId != null) queryParams['customer_id'] = customerId;

    final response = await _networkService.get(
      '/test-drives',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      final testDrivesList = response.data['data']['test_drives'] as List;
      return testDrivesList.map((testDrive) => TestDrive.fromJson(testDrive)).toList();
    }

    throw Exception('Failed to fetch test drives');
  }

  Future<TestDrive> getTestDrive(int id) async {
    final response = await _networkService.get('/test-drives/$id');

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return TestDrive.fromJson(response.data['data']);
    }

    throw Exception('Failed to fetch test drive');
  }

  Future<TestDrive> createTestDrive({
    required int vehicleId,
    required int customerId,
    required DateTime scheduledTime,
    String? notes,
  }) async {
    final data = {
      'vehicle_id': vehicleId,
      'customer_id': customerId,
      'scheduled_time': scheduledTime.toIso8601String(),
      if (notes != null) 'notes': notes,
    };

    final response = await _networkService.post('/test-drives', data: data);

    if (response.statusCode == 201 && response.data['status'] == 'success') {
      return TestDrive.fromJson(response.data['data']);
    }

    throw Exception('Failed to create test drive');
  }

  Future<TestDrive> updateTestDrive({
    required int id,
    DateTime? scheduledTime,
    TestDriveStatus? status,
    String? notes,
    String? customerFeedback,
  }) async {
    final data = <String, dynamic>{};
    
    if (scheduledTime != null) data['scheduled_time'] = scheduledTime.toIso8601String();
    if (status != null) data['status'] = status.value;
    if (notes != null) data['notes'] = notes;
    if (customerFeedback != null) data['customer_feedback'] = customerFeedback;

    final response = await _networkService.put('/test-drives/$id', data: data);

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return TestDrive.fromJson(response.data['data']);
    }

    throw Exception('Failed to update test drive');
  }

  Future<void> cancelTestDrive(int id) async {
    final response = await _networkService.delete('/test-drives/$id');

    if (response.statusCode != 200 || response.data['status'] != 'success') {
      throw Exception('Failed to cancel test drive');
    }
  }

  Future<Map<String, dynamic>> getTestDriveAnalytics() async {
    final response = await _networkService.get('/test-drives/analytics');

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return response.data['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to fetch test drive analytics');
  }

  Future<List<TestDrive>> getMyTestDrives({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (status != null) queryParams['status'] = status;

    final response = await _networkService.get(
      '/test-drives',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      final testDrivesList = response.data['data']['test_drives'] as List;
      return testDrivesList.map((testDrive) => TestDrive.fromJson(testDrive)).toList();
    }

    throw Exception('Failed to fetch my test drives');
  }
}