import '../../core/network/network_service.dart';
import '../models/dashboard.dart';

class DashboardApiService {
  final NetworkService _networkService;

  DashboardApiService(this._networkService);

  Future<DashboardData> getDashboard() async {
    final response = await _networkService.get('/dashboard');

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return DashboardData.fromJson(response.data['data']);
    }

    throw Exception('Failed to fetch dashboard data');
  }

  Future<Map<String, dynamic>> getAnalytics({
    String period = 'month', // day, week, month, year
  }) async {
    final queryParams = {
      'period': period,
    };

    final response = await _networkService.get(
      '/analytics',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return response.data['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to fetch analytics data');
  }

  Future<DashboardSummary> getSummaryData() async {
    final dashboardData = await getDashboard();
    return dashboardData.summary;
  }

  Future<DashboardCharts> getChartsData() async {
    final dashboardData = await getDashboard();
    return dashboardData.charts;
  }

  Future<DashboardRecentData> getRecentData() async {
    final dashboardData = await getDashboard();
    return dashboardData.recentData;
  }

  Future<List<SalesChartData>> getSalesChartData({
    int days = 7,
  }) async {
    final dashboardData = await getDashboard();
    return dashboardData.charts.salesChart;
  }

  Future<List<VehicleStatusData>> getVehicleStatusData() async {
    final dashboardData = await getDashboard();
    return dashboardData.charts.vehicleStatus;
  }

  Future<List<LeadConversionData>> getLeadConversionData() async {
    final dashboardData = await getDashboard();
    return dashboardData.charts.leadConversion;
  }

  Future<List<MonthlyRevenueData>> getMonthlyRevenueData({
    int months = 6,
  }) async {
    final dashboardData = await getDashboard();
    return dashboardData.charts.monthlyRevenue;
  }

  Future<Map<String, dynamic>> getPerformanceMetrics() async {
    final analytics = await getAnalytics(period: 'month');
    return analytics;
  }

  Future<Map<String, dynamic>> getDailyAnalytics() async {
    return getAnalytics(period: 'day');
  }

  Future<Map<String, dynamic>> getWeeklyAnalytics() async {
    return getAnalytics(period: 'week');
  }

  Future<Map<String, dynamic>> getMonthlyAnalytics() async {
    return getAnalytics(period: 'month');
  }

  Future<Map<String, dynamic>> getYearlyAnalytics() async {
    return getAnalytics(period: 'year');
  }
}