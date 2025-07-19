import 'package:flutter/material.dart';

class PaymentMethodChart extends StatelessWidget {
  final List<dynamic> data;

  const PaymentMethodChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Methods Distribution',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        if (data.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No payment method data available'),
            ),
          )
        else ...[
          _buildMethodsList(context),
          const SizedBox(height: 16),
          _buildTotalsSummary(context),
        ],
      ],
    );
  }

  Widget _buildMethodsList(BuildContext context) {
    final totalTransactions = data.fold(0, (sum, item) => sum + (item['count'] ?? 0));
    
    return Column(
      children: data.map<Widget>((item) {
        final method = item['method'] ?? '';
        final count = item['count'] ?? 0;
        final total = (item['total'] ?? 0.0).toDouble();
        final percentage = totalTransactions > 0 ? (count / totalTransactions) * 100 : 0.0;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getMethodColor(method).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getMethodColor(method).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getMethodColor(method).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getMethodIcon(method),
                  color: _getMethodColor(method),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getMethodDisplayName(method),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count transactions',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${total.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getMethodColor(method),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getMethodColor(method),
                        ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTotalsSummary(BuildContext context) {
    final totalTransactions = data.fold(0, (sum, item) => sum + (item['count'] ?? 0));
    final totalAmount = data.fold(0.0, (sum, item) => sum + ((item['total'] ?? 0.0).toDouble()));
    final averageTransaction = totalTransactions > 0 ? totalAmount / totalTransactions : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            context,
            'Total Transactions',
            totalTransactions.toString(),
            Icons.receipt_long,
            Colors.blue,
          ),
          _buildSummaryItem(
            context,
            'Total Amount',
            '\$${totalAmount.toStringAsFixed(0)}',
            Icons.attach_money,
            Colors.green,
          ),
          _buildSummaryItem(
            context,
            'Average',
            '\$${averageTransaction.toStringAsFixed(0)}',
            Icons.trending_up,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Colors.green;
      case 'card':
        return Colors.blue;
      case 'bank_transfer':
        return Colors.purple;
      case 'financing':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'card':
        return Icons.credit_card;
      case 'bank_transfer':
        return Icons.account_balance;
      case 'financing':
        return Icons.payment;
      default:
        return Icons.payment;
    }
  }

  String _getMethodDisplayName(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Cash';
      case 'card':
        return 'Credit/Debit Card';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'financing':
        return 'Financing';
      default:
        return method.toUpperCase();
    }
  }
}