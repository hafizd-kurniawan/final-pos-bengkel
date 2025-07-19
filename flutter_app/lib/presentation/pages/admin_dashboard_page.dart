import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/dashboard.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/dashboard/dashboard_event.dart';
import '../bloc/dashboard/dashboard_state.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../widgets/dashboard_summary_card.dart';
import '../widgets/sales_chart_widget.dart';
import '../widgets/vehicle_status_chart.dart';
import '../widgets/recent_activities_widget.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Load dashboard data
    context.read<DashboardBloc>().add(const DashboardDataRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _logout() {
    context.read<AuthBloc>().add(const AuthLogoutRequested());
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.people), text: 'Management'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardBloc>().add(const DashboardRefreshRequested());
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DashboardError) {
            return _buildErrorWidget(state.message);
          } else if (state is DashboardLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(state.dashboardData),
                _buildAnalyticsTab(),
                _buildManagementTab(),
                _buildSettingsTab(),
              ],
            );
          }
          
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load dashboard',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<DashboardBloc>().add(const DashboardDataRequested());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(DashboardData dashboardData) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(const DashboardRefreshRequested());
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            _buildSummarySection(dashboardData),
            const SizedBox(height: 24),

            // Charts Section
            _buildChartsSection(dashboardData),
            const SizedBox(height: 24),

            // Recent Activities
            _buildRecentActivitiesSection(dashboardData),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(DashboardData dashboardData) {
    final summary = dashboardData.summary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Business Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            DashboardSummaryCard(
              title: 'Total Vehicles',
              value: summary.totalVehicles.toString(),
              subtitle: '${summary.availableVehicles} available',
              icon: Icons.directions_car,
              color: Colors.blue,
            ),
            DashboardSummaryCard(
              title: 'Total Sales',
              value: summary.totalSales.toString(),
              subtitle: 'This month',
              icon: Icons.shopping_cart,
              color: Colors.green,
            ),
            DashboardSummaryCard(
              title: 'Revenue',
              value: summary.formattedTotalRevenue,
              subtitle: summary.formattedMonthlyRevenue + ' this month',
              icon: Icons.attach_money,
              color: Colors.orange,
            ),
            DashboardSummaryCard(
              title: 'Customers',
              value: summary.totalCustomers.toString(),
              subtitle: '${summary.newLeads} new leads',
              icon: Icons.people,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartsSection(DashboardData dashboardData) {
    final charts = dashboardData.charts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SalesChartWidget(data: charts.salesChart),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: VehicleStatusChart(data: charts.vehicleStatus),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivitiesSection(DashboardData dashboardData) {
    final recentData = dashboardData.recentData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activities',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        RecentActivitiesWidget(recentData: recentData),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return const Center(
      child: Text('Detailed Analytics Coming Soon'),
    );
  }

  Widget _buildManagementTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildManagementCard(
            title: 'User Management',
            subtitle: 'Manage staff and customers',
            icon: Icons.people_outline,
            onTap: () {
              // Navigate to user management
            },
          ),
          const SizedBox(height: 16),
          _buildManagementCard(
            title: 'Vehicle Inventory',
            subtitle: 'Manage vehicle catalog',
            icon: Icons.directions_car_outlined,
            onTap: () {
              // Navigate to vehicle management
            },
          ),
          const SizedBox(height: 16),
          _buildManagementCard(
            title: 'Sales Management',
            subtitle: 'Track sales and transactions',
            icon: Icons.point_of_sale,
            onTap: () {
              // Navigate to sales management
            },
          ),
          const SizedBox(height: 16),
          _buildManagementCard(
            title: 'Lead Management',
            subtitle: 'Manage customer leads',
            icon: Icons.psychology,
            onTap: () {
              // Navigate to lead management
            },
          ),
        ],
      ),
    );
  }

  Widget _buildManagementCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSettingsTab() {
    return const Center(
      child: Text('Settings Coming Soon'),
    );
  }
}