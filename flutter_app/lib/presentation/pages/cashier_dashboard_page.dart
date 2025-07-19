import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/transaction.dart';
import '../../data/models/sale.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/dashboard/dashboard_event.dart';
import '../bloc/dashboard/dashboard_state.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../widgets/dashboard_summary_card.dart';
import '../widgets/transaction_list_widget.dart';
import '../widgets/payment_method_chart.dart';

class CashierDashboardPage extends StatefulWidget {
  const CashierDashboardPage({super.key});

  @override
  State<CashierDashboardPage> createState() => _CashierDashboardPageState();
}

class _CashierDashboardPageState extends State<CashierDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('Cashier Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.payment), text: 'Transactions'),
            Tab(icon: Icon(Icons.analytics), text: 'Reports'),
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
                _buildOverviewTab(),
                _buildTransactionsTab(),
                _buildReportsTab(),
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

  Widget _buildOverviewTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard, size: 64),
          SizedBox(height: 16),
          Text('Cashier Dashboard'),
          Text('Payment processing system ready!'),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payment, size: 64),
          SizedBox(height: 16),
          Text('Pending Transactions'),
          Text('Transaction management coming soon...'),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64),
          SizedBox(height: 16),
          Text('Daily Reports'),
          Text('Financial reports coming soon...'),
        ],
      ),
    );
  }
          .getSales(status: 'approved', limit: 20);
      final analyticsFuture = apiServices.transactionService
          .getTransactionAnalytics();

      final results = await Future.wait([
        pendingTransactionsFuture,
        recentTransactionsFuture,
        salesFuture,
        analyticsFuture,
      ]);

      setState(() {
        _pendingTransactions = results[0] as List<Transaction>;
        _recentTransactions = results[1] as List<Transaction>;
        _approvedSales = results[2] as List<Sale>;
        _analytics = results[3] as Map<String, dynamic>;
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
        title: const Text('Cashier Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.pending_actions), text: 'Pending'),
            Tab(icon: Icon(Icons.history), text: 'Transactions'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.point_of_sale),
            onPressed: () {
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
                    _buildPendingTab(),
                    _buildTransactionsTab(),
                    _buildAnalyticsTab(),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showProcessPaymentDialog(context);
        },
        child: const Icon(Icons.payment),
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

  Widget _buildPendingTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            _buildSummarySection(),
            const SizedBox(height: 24),

            // Pending Transactions
            _buildPendingSection(),
            const SizedBox(height: 24),

            // Approved Sales Ready for Payment
            _buildApprovedSalesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    if (_analytics == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Overview',
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
              title: 'Pending Payments',
              value: _analytics!['pending_transactions']?.toString() ?? '0',
              subtitle: 'Awaiting processing',
              icon: Icons.pending_actions,
              color: Colors.orange,
            ),
            DashboardSummaryCard(
              title: 'Completed Today',
              value: _analytics!['completed_transactions']?.toString() ?? '0',
              subtitle: 'Processed transactions',
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            DashboardSummaryCard(
              title: 'Revenue Today',
              value: '\$${(_analytics!['total_revenue'] ?? 0.0).toStringAsFixed(0)}',
              subtitle: 'Total processed',
              icon: Icons.attach_money,
              color: Colors.blue,
            ),
            DashboardSummaryCard(
              title: 'Avg Transaction',
              value: '\$${(_analytics!['avg_transaction_amount'] ?? 0.0).toStringAsFixed(0)}',
              subtitle: 'Average amount',
              icon: Icons.trending_up,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPendingSection() {
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
                  'Pending Transactions (${_pendingTransactions.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (_pendingTransactions.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () {
                      _processBatchPayments();
                    },
                    icon: const Icon(Icons.batch_prediction),
                    label: const Text('Process All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_pendingTransactions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No pending transactions'),
                    ],
                  ),
                ),
              )
            else
              ...(_pendingTransactions.take(5).map((transaction) => 
                  _buildTransactionCard(transaction, showActions: true))),
            if (_pendingTransactions.length > 5)
              TextButton(
                onPressed: () {
                  // Navigate to full list
                },
                child: Text('View all ${_pendingTransactions.length} pending'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovedSalesSection() {
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
                  'Approved Sales (${_approvedSales.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showProcessPaymentDialog(context);
                  },
                  icon: const Icon(Icons.add_card),
                  label: const Text('New Payment'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_approvedSales.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No approved sales waiting for payment'),
                ),
              )
            else
              ..._approvedSales.take(3).map((sale) => _buildSaleCard(sale)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: TransactionListWidget(
        transactions: _recentTransactions,
        onTransactionTap: (transaction) {
          _showTransactionDetails(context, transaction);
        },
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    if (_analytics == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: PaymentMethodChart(
                  data: _analytics!['payment_methods'] ?? [],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildAnalyticsCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildAnalyticsCard(
          'Total Transactions',
          _analytics!['total_transactions']?.toString() ?? '0',
          'All time',
          Icons.receipt_long,
          Colors.blue,
        ),
        _buildAnalyticsCard(
          'Failed Transactions',
          _analytics!['failed_transactions']?.toString() ?? '0',
          'Requires attention',
          Icons.error_outline,
          Colors.red,
        ),
        _buildAnalyticsCard(
          'Refunded',
          _analytics!['refunded_transactions']?.toString() ?? '0',
          'This month',
          Icons.undo,
          Colors.orange,
        ),
        _buildAnalyticsCard(
          'Success Rate',
          '${_calculateSuccessRate().toStringAsFixed(1)}%',
          'Processing rate',
          Icons.check_circle,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction, {bool showActions = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getPaymentMethodColor(transaction.paymentMethod).withOpacity(0.1),
          child: Icon(
            _getPaymentMethodIcon(transaction.paymentMethod),
            color: _getPaymentMethodColor(transaction.paymentMethod),
          ),
        ),
        title: Text('${transaction.transactionRef} - ${transaction.formattedAmount}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${transaction.paymentMethodDisplayName} • ${transaction.sale?.customer?.name ?? 'Unknown'}'),
            Text(transaction.sale?.vehicle?.displayName ?? 'Unknown Vehicle'),
          ],
        ),
        trailing: showActions ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () => _processPayment(transaction),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showTransactionDetails(context, transaction),
            ),
          ],
        ) : null,
        onTap: () => _showTransactionDetails(context, transaction),
      ),
    );
  }

  Widget _buildSaleCard(Sale sale) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.1),
          child: const Icon(Icons.handshake, color: Colors.green),
        ),
        title: Text(sale.vehicle?.displayName ?? 'Unknown Vehicle'),
        subtitle: Text('${sale.customer?.name ?? 'Unknown Customer'} • ${sale.formattedPrice}'),
        trailing: ElevatedButton(
          onPressed: () => _createTransactionForSale(sale),
          child: const Text('Process'),
        ),
      ),
    );
  }

  // Helper methods and dialogs
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
              leading: const Icon(Icons.payment, color: Colors.green),
              title: const Text('Process Payment'),
              onTap: () {
                Navigator.pop(context);
                _showProcessPaymentDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt, color: Colors.blue),
              title: const Text('Generate Receipt'),
              onTap: () {
                Navigator.pop(context);
                // Generate receipt functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.undo, color: Colors.orange),
              title: const Text('Process Refund'),
              onTap: () {
                Navigator.pop(context);
                // Process refund functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showProcessPaymentDialog(BuildContext context) {
    // Implementation for payment processing dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Payment'),
        content: const Text('Payment processing dialog would be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Process'),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, Transaction transaction) {
    // Implementation for transaction details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transaction ${transaction.transactionRef}'),
        content: Text('Transaction details would be shown here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment(Transaction transaction) async {
    try {
      await apiServices.transactionService.processPayment(transaction.id);
      _loadData(); // Refresh data
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment processed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process payment: $e')),
        );
      }
    }
  }

  void _processBatchPayments() {
    // Implementation for batch payment processing
  }

  void _createTransactionForSale(Sale sale) {
    // Implementation for creating transaction from sale
  }

  double _calculateSuccessRate() {
    if (_analytics == null) return 0.0;
    final total = _analytics!['total_transactions'] ?? 0;
    final completed = _analytics!['completed_transactions'] ?? 0;
    if (total == 0) return 0.0;
    return (completed / total) * 100;
  }

  Color _getPaymentMethodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Colors.green;
      case PaymentMethod.card:
        return Colors.blue;
      case PaymentMethod.bankTransfer:
        return Colors.purple;
      case PaymentMethod.financing:
        return Colors.orange;
    }
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.financing:
        return Icons.payment;
    }
  }
}