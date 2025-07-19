import 'sale.dart';
import 'user.dart';

enum PaymentMethod {
  cash('cash'),
  card('card'),
  bankTransfer('bank_transfer'),
  financing('financing');

  const PaymentMethod(this.value);
  final String value;

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.value == value,
      orElse: () => PaymentMethod.cash,
    );
  }

  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Credit/Debit Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.financing:
        return 'Financing';
    }
  }
}

enum TransactionStatus {
  pending('pending'),
  completed('completed'),
  failed('failed'),
  refunded('refunded');

  const TransactionStatus(this.value);
  final String value;

  static TransactionStatus fromString(String value) {
    return TransactionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TransactionStatus.pending,
    );
  }
}

class Transaction {
  final int id;
  final int saleId;
  final double amount;
  final PaymentMethod paymentMethod;
  final TransactionStatus status;
  final int processedById;
  final DateTime? processedAt;
  final String transactionRef;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Sale? sale;
  final User? processedBy;

  const Transaction({
    required this.id,
    required this.saleId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.processedById,
    this.processedAt,
    required this.transactionRef,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.sale,
    this.processedBy,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      saleId: json['sale_id'] ?? 0,
      amount: (json['amount'] ?? 0.0).toDouble(),
      paymentMethod: PaymentMethod.fromString(json['payment_method'] ?? 'cash'),
      status: TransactionStatus.fromString(json['status'] ?? 'pending'),
      processedById: json['processed_by_id'] ?? 0,
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'])
          : null,
      transactionRef: json['transaction_ref'] ?? '',
      notes: json['notes'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      sale: json['sale'] != null
          ? Sale.fromJson(json['sale'] as Map<String, dynamic>)
          : null,
      processedBy: json['processed_by'] != null
          ? User.fromJson(json['processed_by'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sale_id': saleId,
      'amount': amount,
      'payment_method': paymentMethod.value,
      'status': status.value,
      'processed_by_id': processedById,
      'processed_at': processedAt?.toIso8601String(),
      'transaction_ref': transactionRef,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (sale != null) 'sale': sale!.toJson(),
      if (processedBy != null) 'processed_by': processedBy!.toJson(),
    };
  }

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
  String get statusDisplayName => status.value.toUpperCase();
  String get paymentMethodDisplayName => paymentMethod.displayName;

  String get formattedProcessedAt {
    if (processedAt == null) return 'Not processed';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final processedDate = DateTime(processedAt!.year, processedAt!.month, processedAt!.day);
    
    if (processedDate == today) {
      return 'Today at ${processedAt!.hour.toString().padLeft(2, '0')}:${processedAt!.minute.toString().padLeft(2, '0')}';
    } else {
      return '${processedAt!.day}/${processedAt!.month}/${processedAt!.year}';
    }
  }

  bool get isPending => status == TransactionStatus.pending;
  bool get isCompleted => status == TransactionStatus.completed;
  bool get isFailed => status == TransactionStatus.failed;
  bool get isRefunded => status == TransactionStatus.refunded;

  Transaction copyWith({
    int? id,
    int? saleId,
    double? amount,
    PaymentMethod? paymentMethod,
    TransactionStatus? status,
    int? processedById,
    DateTime? processedAt,
    String? transactionRef,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Sale? sale,
    User? processedBy,
  }) {
    return Transaction(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      processedById: processedById ?? this.processedById,
      processedAt: processedAt ?? this.processedAt,
      transactionRef: transactionRef ?? this.transactionRef,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sale: sale ?? this.sale,
      processedBy: processedBy ?? this.processedBy,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, amount: $amount, method: $paymentMethod, status: $status)';
  }
}