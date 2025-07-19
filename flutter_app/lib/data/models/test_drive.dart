import 'user.dart';
import 'vehicle.dart';

enum TestDriveStatus {
  pending('pending'),
  approved('approved'),
  completed('completed'),
  canceled('canceled');

  const TestDriveStatus(this.value);
  final String value;

  static TestDriveStatus fromString(String value) {
    return TestDriveStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TestDriveStatus.pending,
    );
  }
}

class TestDrive {
  final int id;
  final int vehicleId;
  final int customerId;
  final DateTime scheduledTime;
  final TestDriveStatus status;
  final String? notes;
  final String? customerFeedback;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Vehicle? vehicle;
  final User? customer;

  const TestDrive({
    required this.id,
    required this.vehicleId,
    required this.customerId,
    required this.scheduledTime,
    required this.status,
    this.notes,
    this.customerFeedback,
    required this.createdAt,
    required this.updatedAt,
    this.vehicle,
    this.customer,
  });

  factory TestDrive.fromJson(Map<String, dynamic> json) {
    return TestDrive(
      id: json['id'] ?? 0,
      vehicleId: json['vehicle_id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      scheduledTime: DateTime.parse(
          json['scheduled_time'] ?? DateTime.now().toIso8601String()),
      status: TestDriveStatus.fromString(json['status'] ?? 'pending'),
      notes: json['notes'],
      customerFeedback: json['customer_feedback'],
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'customer_id': customerId,
      'scheduled_time': scheduledTime.toIso8601String(),
      'status': status.value,
      'notes': notes,
      'customer_feedback': customerFeedback,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (vehicle != null) 'vehicle': vehicle!.toJson(),
      if (customer != null) 'customer': customer!.toJson(),
    };
  }

  String get statusDisplayName => status.value.toUpperCase();
  
  String get formattedScheduledTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduledDate = DateTime(scheduledTime.year, scheduledTime.month, scheduledTime.day);
    
    if (scheduledDate == today) {
      return 'Today at ${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}';
    } else if (scheduledDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow at ${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${scheduledTime.day}/${scheduledTime.month}/${scheduledTime.year} at ${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}';
    }
  }

  bool get isPast => scheduledTime.isBefore(DateTime.now());
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduledDate = DateTime(scheduledTime.year, scheduledTime.month, scheduledTime.day);
    return scheduledDate == today;
  }

  TestDrive copyWith({
    int? id,
    int? vehicleId,
    int? customerId,
    DateTime? scheduledTime,
    TestDriveStatus? status,
    String? notes,
    String? customerFeedback,
    DateTime? createdAt,
    DateTime? updatedAt,
    Vehicle? vehicle,
    User? customer,
  }) {
    return TestDrive(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      customerId: customerId ?? this.customerId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      customerFeedback: customerFeedback ?? this.customerFeedback,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      vehicle: vehicle ?? this.vehicle,
      customer: customer ?? this.customer,
    );
  }

  @override
  String toString() {
    return 'TestDrive(id: $id, vehicleId: $vehicleId, scheduledTime: $scheduledTime, status: $status)';
  }
}