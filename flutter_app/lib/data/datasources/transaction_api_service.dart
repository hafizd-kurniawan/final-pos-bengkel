import '../../core/network/network_service.dart';
import '../models/transaction.dart';

class TransactionApiService {
  final NetworkService _networkService;

  TransactionApiService(this._networkService);

  Future<List<Transaction>> getTransactions({
    int page = 1,
    int limit = 10,
    String? status,
    int? saleId,
    String? paymentMethod,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (status != null) queryParams['status'] = status;
    if (saleId != null) queryParams['sale_id'] = saleId;
    if (paymentMethod != null) queryParams['payment_method'] = paymentMethod;

    final response = await _networkService.get(
      '/transactions',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      final transactionsList = response.data['data']['transactions'] as List;
      return transactionsList.map((transaction) => Transaction.fromJson(transaction)).toList();
    }

    throw Exception('Failed to fetch transactions');
  }

  Future<Transaction> getTransaction(int id) async {
    final response = await _networkService.get('/transactions/$id');

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return Transaction.fromJson(response.data['data']);
    }

    throw Exception('Failed to fetch transaction');
  }

  Future<Transaction> createTransaction({
    required int saleId,
    required double amount,
    required PaymentMethod paymentMethod,
    String? notes,
  }) async {
    final data = {
      'sale_id': saleId,
      'amount': amount,
      'payment_method': paymentMethod.value,
      if (notes != null) 'notes': notes,
    };

    final response = await _networkService.post('/transactions', data: data);

    if (response.statusCode == 201 && response.data['status'] == 'success') {
      return Transaction.fromJson(response.data['data']);
    }

    throw Exception('Failed to create transaction');
  }

  Future<Transaction> updateTransaction({
    required int id,
    TransactionStatus? status,
    String? transactionRef,
    String? notes,
  }) async {
    final data = <String, dynamic>{};
    
    if (status != null) data['status'] = status.value;
    if (transactionRef != null) data['transaction_ref'] = transactionRef;
    if (notes != null) data['notes'] = notes;

    final response = await _networkService.put('/transactions/$id', data: data);

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return Transaction.fromJson(response.data['data']);
    }

    throw Exception('Failed to update transaction');
  }

  Future<Transaction> processPayment(int id) async {
    final response = await _networkService.post('/transactions/$id/process');

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return Transaction.fromJson(response.data['data']);
    }

    throw Exception('Failed to process payment');
  }

  Future<void> refundTransaction(int id) async {
    final response = await _networkService.post('/transactions/$id/refund');

    if (response.statusCode != 200 || response.data['status'] != 'success') {
      throw Exception('Failed to refund transaction');
    }
  }

  Future<Map<String, dynamic>> getTransactionAnalytics() async {
    final response = await _networkService.get('/transactions/analytics');

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return response.data['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to fetch transaction analytics');
  }

  Future<List<Transaction>> getTransactionsBySale(int saleId) async {
    return getTransactions(saleId: saleId);
  }

  Future<double> getTotalRevenueForPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final queryParams = {
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };

    final response = await _networkService.get(
      '/transactions/analytics',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return (response.data['data']['total_revenue'] ?? 0.0).toDouble();
    }

    throw Exception('Failed to fetch revenue data');
  }
}