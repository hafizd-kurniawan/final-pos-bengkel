import 'sale.dart';
import 'test_drive.dart';
import 'lead.dart';

class DashboardSummary {
  final int totalVehicles;
  final int availableVehicles;
  final int totalSales;
  final double totalRevenue;
  final int totalCustomers;
  final int pendingTestDrives;
  final int newLeads;
  final double monthlyRevenue;

  const DashboardSummary({
    required this.totalVehicles,
    required this.availableVehicles,
    required this.totalSales,
    required this.totalRevenue,
    required this.totalCustomers,
    required this.pendingTestDrives,
    required this.newLeads,
    required this.monthlyRevenue,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalVehicles: json['total_vehicles'] ?? 0,
      availableVehicles: json['available_vehicles'] ?? 0,
      totalSales: json['total_sales'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0.0).toDouble(),
      totalCustomers: json['total_customers'] ?? 0,
      pendingTestDrives: json['pending_test_drives'] ?? 0,
      newLeads: json['new_leads'] ?? 0,
      monthlyRevenue: (json['monthly_revenue'] ?? 0.0).toDouble(),
    );
  }

  String get formattedTotalRevenue => '\$${totalRevenue.toStringAsFixed(2)}';
  String get formattedMonthlyRevenue => '\$${monthlyRevenue.toStringAsFixed(2)}';
}

class SalesChartData {
  final String date;
  final int sales;
  final double revenue;

  const SalesChartData({
    required this.date,
    required this.sales,
    required this.revenue,
  });

  factory SalesChartData.fromJson(Map<String, dynamic> json) {
    return SalesChartData(
      date: json['date'] ?? '',
      sales: json['sales'] ?? 0,
      revenue: (json['revenue'] ?? 0.0).toDouble(),
    );
  }
}

class VehicleStatusData {
  final String status;
  final int count;

  const VehicleStatusData({
    required this.status,
    required this.count,
  });

  factory VehicleStatusData.fromJson(Map<String, dynamic> json) {
    return VehicleStatusData(
      status: json['status'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class LeadConversionData {
  final String status;
  final int count;

  const LeadConversionData({
    required this.status,
    required this.count,
  });

  factory LeadConversionData.fromJson(Map<String, dynamic> json) {
    return LeadConversionData(
      status: json['status'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class MonthlyRevenueData {
  final String month;
  final double revenue;

  const MonthlyRevenueData({
    required this.month,
    required this.revenue,
  });

  factory MonthlyRevenueData.fromJson(Map<String, dynamic> json) {
    return MonthlyRevenueData(
      month: json['month'] ?? '',
      revenue: (json['revenue'] ?? 0.0).toDouble(),
    );
  }
}

class DashboardCharts {
  final List<SalesChartData> salesChart;
  final List<VehicleStatusData> vehicleStatus;
  final List<LeadConversionData> leadConversion;
  final List<MonthlyRevenueData> monthlyRevenue;

  const DashboardCharts({
    required this.salesChart,
    required this.vehicleStatus,
    required this.leadConversion,
    required this.monthlyRevenue,
  });

  factory DashboardCharts.fromJson(Map<String, dynamic> json) {
    return DashboardCharts(
      salesChart: (json['sales_chart'] as List<dynamic>? ?? [])
          .map((item) => SalesChartData.fromJson(item as Map<String, dynamic>))
          .toList(),
      vehicleStatus: (json['vehicle_status'] as List<dynamic>? ?? [])
          .map((item) => VehicleStatusData.fromJson(item as Map<String, dynamic>))
          .toList(),
      leadConversion: (json['lead_conversion'] as List<dynamic>? ?? [])
          .map((item) => LeadConversionData.fromJson(item as Map<String, dynamic>))
          .toList(),
      monthlyRevenue: (json['monthly_revenue'] as List<dynamic>? ?? [])
          .map((item) => MonthlyRevenueData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DashboardRecentData {
  final List<Sale> recentSales;
  final List<TestDrive> recentTestDrives;
  final List<Lead> recentLeads;

  const DashboardRecentData({
    required this.recentSales,
    required this.recentTestDrives,
    required this.recentLeads,
  });

  factory DashboardRecentData.fromJson(Map<String, dynamic> json) {
    return DashboardRecentData(
      recentSales: (json['recent_sales'] as List<dynamic>? ?? [])
          .map((item) => Sale.fromJson(item as Map<String, dynamic>))
          .toList(),
      recentTestDrives: (json['recent_test_drives'] as List<dynamic>? ?? [])
          .map((item) => TestDrive.fromJson(item as Map<String, dynamic>))
          .toList(),
      recentLeads: (json['recent_leads'] as List<dynamic>? ?? [])
          .map((item) => Lead.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DashboardData {
  final DashboardSummary summary;
  final DashboardCharts charts;
  final DashboardRecentData recentData;

  const DashboardData({
    required this.summary,
    required this.charts,
    required this.recentData,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      summary: DashboardSummary.fromJson(json['summary'] as Map<String, dynamic>? ?? {}),
      charts: DashboardCharts.fromJson(json['charts'] as Map<String, dynamic>? ?? {}),
      recentData: DashboardRecentData.fromJson(json['recent_data'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': {
        'total_vehicles': summary.totalVehicles,
        'available_vehicles': summary.availableVehicles,
        'total_sales': summary.totalSales,
        'total_revenue': summary.totalRevenue,
        'total_customers': summary.totalCustomers,
        'pending_test_drives': summary.pendingTestDrives,
        'new_leads': summary.newLeads,
        'monthly_revenue': summary.monthlyRevenue,
      },
      'charts': {
        'sales_chart': charts.salesChart.map((item) => {
          'date': item.date,
          'sales': item.sales,
          'revenue': item.revenue,
        }).toList(),
        'vehicle_status': charts.vehicleStatus.map((item) => {
          'status': item.status,
          'count': item.count,
        }).toList(),
        'lead_conversion': charts.leadConversion.map((item) => {
          'status': item.status,
          'count': item.count,
        }).toList(),
        'monthly_revenue': charts.monthlyRevenue.map((item) => {
          'month': item.month,
          'revenue': item.revenue,
        }).toList(),
      },
      'recent_data': {
        'recent_sales': recentData.recentSales.map((sale) => sale.toJson()).toList(),
        'recent_test_drives': recentData.recentTestDrives.map((testDrive) => testDrive.toJson()).toList(),
        'recent_leads': recentData.recentLeads.map((lead) => lead.toJson()).toList(),
      },
    };
  }
}