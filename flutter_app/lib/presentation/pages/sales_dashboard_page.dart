import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/dashboard.dart';
import '../../data/models/lead.dart';
import '../../data/models/sale.dart';
import '../../data/models/test_drive.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/dashboard/dashboard_event.dart';
import '../bloc/dashboard/dashboard_state.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../widgets/dashboard_summary_card.dart';
import '../widgets/lead_conversion_chart.dart';
import '../widgets/sales_performance_widget.dart';

class SalesDashboardPage extends StatefulWidget {
  const SalesDashboardPage({super.key});

  @override
  State<SalesDashboardPage> createState() => _SalesDashboardPageState();
}

class _SalesDashboardPageState extends State<SalesDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DashboardData? _dashboardData;
  List<Lead> _myLeads = [];
  List<Sale> _mySales = [];
  List<TestDrive> _testDrives = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final dashboardFuture = apiServices.dashboardService.getDashboard();
      final leadsFuture = apiServices.leadService.getMyLeads(limit: 20);
      final salesFuture = apiServices.saleService.getSales(limit: 20);
      final testDrivesFuture = apiServices.testDriveService.getTestDrives(limit: 20);

      final results = await Future.wait([
        dashboardFuture,
        leadsFuture,
        salesFuture,
        testDrivesFuture,
      ]);

      setState(() {
        _dashboardData = results[0] as DashboardData;
        _myLeads = results[1] as List<Lead>;
        _mySales = results[2] as List<Sale>;
        _testDrives = results[3] as List<TestDrive>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.psychology), text: 'Leads'),
            Tab(icon: Icon(Icons.event), text: 'Activities'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: () {
              // Quick actions menu
              _showQuickActionsMenu(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildLeadsTab(),
                    _buildActivitiesTab(),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showQuickActionsMenu(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorWidget() {
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
            _error!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_dashboardData == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Performance Summary
            _buildPerformanceSummary(),
            const SizedBox(height: 24),

            // Sales Performance Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SalesPerformanceWidget(
                  salesData: _dashboardData!.charts.salesChart,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Stats
            _buildQuickStats(),
            const SizedBox(height: 24),

            // Today's Schedule
            _buildTodaysSchedule(),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSummary() {
    final summary = _dashboardData!.summary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Performance',
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
              title: 'My Sales',
              value: _mySales.length.toString(),
              subtitle: 'This month',
              icon: Icons.shopping_cart,
              color: Colors.green,
            ),
            DashboardSummaryCard(
              title: 'Revenue',
              value: _calculateMyRevenue(),
              subtitle: 'Total earned',
              icon: Icons.attach_money,
              color: Colors.blue,
            ),
            DashboardSummaryCard(
              title: 'Active Leads',
              value: _getActiveLeadsCount().toString(),
              subtitle: 'Assigned to me',
              icon: Icons.psychology,
              color: Colors.orange,
            ),
            DashboardSummaryCard(
              title: 'Test Drives',
              value: _getTodaysTestDrives().toString(),
              subtitle: 'Scheduled today',
              icon: Icons.drive_eta,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stats',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Conversion Rate',
                    '${_calculateConversionRate().toStringAsFixed(1)}%',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Avg. Deal Size',
                    _calculateAverageDealSize(),
                    Icons.monetization_on,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Pipeline',
                    '${_getActiveLeadsCount()} leads',
                    Icons.psychology,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTodaysSchedule() {
    final todaysTestDrives = _testDrives.where((td) => td.isToday).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Schedule',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full schedule
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (todaysTestDrives.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No test drives scheduled for today'),
                ),
              )
            else
              ...todaysTestDrives.map((testDrive) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: const Icon(Icons.drive_eta, color: Colors.blue),
                    ),
                    title: Text(testDrive.vehicle?.displayName ?? 'Unknown Vehicle'),
                    subtitle: Text(
                      '${testDrive.customer?.name ?? 'Unknown Customer'} • ${testDrive.formattedScheduledTime}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.call),
                      onPressed: () {
                        // Call customer
                      },
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myLeads.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildLeadsHeader();
          }

          final lead = _myLeads[index - 1];
          return _buildLeadCard(lead);
        },
      ),
    );
  }

  Widget _buildLeadsHeader() {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LeadConversionChart(data: _dashboardData!.charts.leadConversion),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Leads (${_myLeads.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Add new lead
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Lead'),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLeadCard(Lead lead) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getLeadPriorityColor(lead).withOpacity(0.1),
          child: Text(
            lead.initials,
            style: TextStyle(
              color: _getLeadPriorityColor(lead),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(lead.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${lead.interestedIn ?? 'General Inquiry'} • ${lead.formattedBudget}'),
            if (lead.lastContactFormatted != null)
              Text(
                'Last contact: ${lead.lastContactFormatted}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(
              label: Text(lead.statusDisplayName),
              backgroundColor: _getStatusColor(lead.status).withOpacity(0.1),
              side: BorderSide.none,
            ),
          ],
        ),
        onTap: () {
          // Navigate to lead details
        },
      ),
    );
  }

  Widget _buildActivitiesTab() {
    return const Center(
      child: Text('Activities tab coming soon'),
    );
  }

  void _showQuickActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.add_circle, color: Colors.green),
              title: const Text('Add New Lead'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to add lead
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.blue),
              title: const Text('Schedule Test Drive'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to schedule test drive
              },
            ),
            ListTile(
              leading: const Icon(Icons.handshake, color: Colors.orange),
              title: const Text('Create Sale'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to create sale
              },
            ),
            ListTile(
              leading: const Icon(Icons.call, color: Colors.purple),
              title: const Text('Follow Up'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to follow up
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _calculateMyRevenue() {
    final completedSales = _mySales.where((sale) => sale.status == SaleStatus.completed);
    final total = completedSales.fold(0.0, (sum, sale) => sum + sale.salePrice);
    return '\$${total.toStringAsFixed(0)}';
  }

  int _getActiveLeadsCount() {
    return _myLeads.where((lead) => !lead.isConverted && !lead.isLost).length;
  }

  int _getTodaysTestDrives() {
    return _testDrives.where((td) => td.isToday).length;
  }

  double _calculateConversionRate() {
    if (_myLeads.isEmpty) return 0.0;
    final converted = _myLeads.where((lead) => lead.isConverted).length;
    return (converted / _myLeads.length) * 100;
  }

  String _calculateAverageDealSize() {
    final completedSales = _mySales.where((sale) => sale.status == SaleStatus.completed);
    if (completedSales.isEmpty) return '\$0';
    
    final total = completedSales.fold(0.0, (sum, sale) => sum + sale.salePrice);
    final average = total / completedSales.length;
    return '\$${average.toStringAsFixed(0)}';
  }

  Color _getLeadPriorityColor(Lead lead) {
    switch (lead.priorityLevel) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'converted':
        return Colors.green;
      case 'qualified':
        return Colors.blue;
      case 'contacted':
        return Colors.orange;
      case 'lost':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}