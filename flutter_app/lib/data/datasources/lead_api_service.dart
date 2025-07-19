import '../../core/network/network_service.dart';
import '../models/lead.dart';

class LeadApiService {
  final NetworkService _networkService;

  LeadApiService(this._networkService);

  Future<List<Lead>> getLeads({
    int page = 1,
    int limit = 10,
    String? status,
    int? assignedToId,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (status != null) queryParams['status'] = status;
    if (assignedToId != null) queryParams['assigned_to_id'] = assignedToId;
    if (search != null) queryParams['search'] = search;

    final response = await _networkService.get(
      '/leads',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      final leadsList = response.data['data']['leads'] as List;
      return leadsList.map((lead) => Lead.fromJson(lead)).toList();
    }

    throw Exception('Failed to fetch leads');
  }

  Future<Lead> getLead(int id) async {
    final response = await _networkService.get('/leads/$id');

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return Lead.fromJson(response.data['data']);
    }

    throw Exception('Failed to fetch lead');
  }

  Future<Lead> createLead({
    required String name,
    String? email,
    String? phone,
    String? interestedIn,
    double? budget,
    String? notes,
  }) async {
    final data = {
      'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (interestedIn != null) 'interested_in': interestedIn,
      if (budget != null) 'budget': budget,
      if (notes != null) 'notes': notes,
    };

    final response = await _networkService.post('/leads', data: data);

    if (response.statusCode == 201 && response.data['status'] == 'success') {
      return Lead.fromJson(response.data['data']);
    }

    throw Exception('Failed to create lead');
  }

  Future<Lead> updateLead({
    required int id,
    String? name,
    String? email,
    String? phone,
    String? interestedIn,
    double? budget,
    int? assignedToId,
    String? status,
    String? notes,
    DateTime? lastContactAt,
  }) async {
    final data = <String, dynamic>{};
    
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (interestedIn != null) data['interested_in'] = interestedIn;
    if (budget != null) data['budget'] = budget;
    if (assignedToId != null) data['assigned_to_id'] = assignedToId;
    if (status != null) data['status'] = status;
    if (notes != null) data['notes'] = notes;
    if (lastContactAt != null) data['last_contact_at'] = lastContactAt.toIso8601String();

    final response = await _networkService.put('/leads/$id', data: data);

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return Lead.fromJson(response.data['data']);
    }

    throw Exception('Failed to update lead');
  }

  Future<void> deleteLead(int id) async {
    final response = await _networkService.delete('/leads/$id');

    if (response.statusCode != 200 || response.data['status'] != 'success') {
      throw Exception('Failed to delete lead');
    }
  }

  Future<Lead> assignLead({
    required int id,
    required int assignedToId,
  }) async {
    final data = {
      'assigned_to_id': assignedToId,
    };

    final response = await _networkService.post('/leads/$id/assign', data: data);

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return Lead.fromJson(response.data['data']);
    }

    throw Exception('Failed to assign lead');
  }

  Future<Map<String, dynamic>> getLeadAnalytics() async {
    final response = await _networkService.get('/leads/analytics');

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return response.data['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to fetch lead analytics');
  }

  Future<List<Lead>> getMyLeads({
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (status != null) queryParams['status'] = status;
    if (search != null) queryParams['search'] = search;

    final response = await _networkService.get(
      '/leads',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      final leadsList = response.data['data']['leads'] as List;
      return leadsList.map((lead) => Lead.fromJson(lead)).toList();
    }

    throw Exception('Failed to fetch my leads');
  }
}