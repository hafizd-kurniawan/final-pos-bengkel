import 'package:flutter/material.dart';
import '../../data/models/transaction.dart';

class TransactionListWidget extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(Transaction) onTransactionTap;

  const TransactionListWidget({
    super.key,
    required this.transactions,
    required this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No transactions found'),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeader(context);
        }

        final transaction = transactions[index - 1];
        return _buildTransactionCard(context, transaction);
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Recent Transactions (${transactions.length})',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  // Show filter dialog
                },
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // Show search
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, Transaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onTransactionTap(transaction),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    transaction.transactionRef,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  _buildStatusChip(context, transaction.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _getPaymentMethodIcon(transaction.paymentMethod),
                    size: 16,
                    color: _getPaymentMethodColor(transaction.paymentMethod),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    transaction.paymentMethodDisplayName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Text(
                    transaction.formattedAmount,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getAmountColor(transaction.status),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (transaction.sale != null) ...[
                Text(
                  'Vehicle: ${transaction.sale!.vehicle?.displayName ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Customer: ${transaction.sale!.customer?.name ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    transaction.formattedProcessedAt,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  if (transaction.processedBy != null)
                    Text(
                      'by ${transaction.processedBy!.name}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, TransactionStatus status) {
    Color backgroundColor;
    Color textColor;
    
    switch (status) {
      case TransactionStatus.pending:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case TransactionStatus.completed:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case TransactionStatus.failed:
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
      case TransactionStatus.refunded:
        backgroundColor = Colors.purple.withOpacity(0.1);
        textColor = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.value.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
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

  Color _getAmountColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return Colors.green;
      case TransactionStatus.failed:
        return Colors.red;
      case TransactionStatus.refunded:
        return Colors.purple;
      default:
        return Colors.black;
    }
  }
}