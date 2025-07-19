import 'user.dart';
import 'vehicle.dart';

enum SaleStatus {
  pending('pending'),
  approved('approved'),
  completed('completed'),
  canceled('canceled');

  const SaleStatus(this.value);
  final String value;

  static SaleStatus fromString(String value) {
    return SaleStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => SaleStatus.pending,
    );
  }
}

class Sale {
  final int id;
  final int vehicleId;
  final int customerId;
  final int salesPersonId;
  final double salePrice;
  final SaleStatus status;
  final String? notes;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Vehicle? vehicle;
  final User? customer;
  final User? salesPerson;

  const Sale({
    required this.id,
    required this.vehicleId,
    required this.customerId,
    required this.salesPersonId,
    required this.salePrice,
    required this.status,
    this.notes,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.vehicle,
    this.customer,
    this.salesPerson,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] ?? 0,
      vehicleId: json['vehicle_id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      salesPersonId: json['sales_person_id'] ?? 0,
      salePrice: (json['sale_price'] ?? 0.0).toDouble(),
      status: SaleStatus.fromString(json['status'] ?? 'pending'),
      notes: json['notes'],
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      vehicle: json['vehicle'] != null
          ? Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null,
      customer: json['customer'] != null
          ? User.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      salesPerson: json['sales_person'] != null
          ? User.fromJson(json['sales_person'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'customer_id': customerId,
      'sales_person_id': salesPersonId,
      'sale_price': salePrice,
      'status': status.value,
      'notes': notes,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (vehicle != null) 'vehicle': vehicle!.toJson(),
      if (customer != null) 'customer': customer!.toJson(),
      if (salesPerson != null) 'sales_person': salesPerson!.toJson(),
    };
  }

  String get formattedPrice => '\$${salePrice.toStringAsFixed(2)}';
  String get statusDisplayName => status.value.toUpperCase();

  Sale copyWith({
    int? id,
    int? vehicleId,
    int? customerId,
    int? salesPersonId,
    double? salePrice,
    SaleStatus? status,
    String? notes,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Vehicle? vehicle,
    User? customer,
    User? salesPerson,
  }) {
    return Sale(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      customerId: customerId ?? this.customerId,
      salesPersonId: salesPersonId ?? this.salesPersonId,
      salePrice: salePrice ?? this.salePrice,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      vehicle: vehicle ?? this.vehicle,
      customer: customer ?? this.customer,
      salesPerson: salesPerson ?? this.salesPerson,
    );
  }

  @override
  String toString() {
    return 'Sale(id: $id, vehicleId: $vehicleId, salePrice: $salePrice, status: $status)';
  }
}