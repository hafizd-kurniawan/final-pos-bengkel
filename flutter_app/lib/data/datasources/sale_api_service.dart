import '../../core/network/network_service.dart';
import '../models/sale.dart';

class SaleApiService {
  final NetworkService _networkService;

  SaleApiService(this._networkService);

  Future<List<Sale>> getSales({
    int page = 1,
    int limit = 10,
    String? status,
    int? salesPersonId,
    int? customerId,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (status != null) queryParams['status'] = status;
    if (salesPersonId != null) queryParams['sales_person_id'] = salesPersonId;
    if (customerId != null) queryParams['customer_id'] = customerId;

    final response = await _networkService.get(
      '/sales',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      final salesList = response.data['data']['sales'] as List;
      return salesList.map((sale) => Sale.fromJson(sale)).toList();
    }

    throw Exception('Failed to fetch sales');
  }

  Future<Sale> getSale(int id) async {
    final response = await _networkService.get('/sales/$id');

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return Sale.fromJson(response.data['data']);
    }

    throw Exception('Failed to fetch sale');
  }

  Future<Sale> createSale({
    required int vehicleId,
    required int customerId,
    required int salesPersonId,
    required double salePrice,
    String? notes,
  }) async {
    final data = {
      'vehicle_id': vehicleId,
      'customer_id': customerId,
      'sales_person_id': salesPersonId,
      'sale_price': salePrice,
      if (notes != null) 'notes': notes,
    };

    final response = await _networkService.post('/sales', data: data);

    if (response.statusCode == 201 && response.data['status'] == 'success') {
      return Sale.fromJson(response.data['data']);
    }

    throw Exception('Failed to create sale');
  }

  Future<Sale> updateSale({
    required int id,
    double? salePrice,
    SaleStatus? status,
    String? notes,
  }) async {
    final data = <String, dynamic>{};
    
    if (salePrice != null) data['sale_price'] = salePrice;
    if (status != null) data['status'] = status.value;
    if (notes != null) data['notes'] = notes;

    final response = await _networkService.put('/sales/$id', data: data);

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return Sale.fromJson(response.data['data']);
    }

    throw Exception('Failed to update sale');
  }

  Future<void> deleteSale(int id) async {
    final response = await _networkService.delete('/sales/$id');

    if (response.statusCode != 200 || response.data['status'] != 'success') {
      throw Exception('Failed to delete sale');
    }
  }

  Future<Map<String, dynamic>> getSalesAnalytics() async {
    final response = await _networkService.get('/sales/analytics');

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return response.data['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to fetch sales analytics');
  }
}