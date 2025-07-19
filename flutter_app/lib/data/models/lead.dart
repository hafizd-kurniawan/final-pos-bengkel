import 'user.dart';

class Lead {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? interestedIn;
  final double budget;
  final int? assignedToId;
  final String status;
  final String? notes;
  final DateTime? lastContactAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? assignedTo;

  const Lead({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.interestedIn,
    required this.budget,
    this.assignedToId,
    required this.status,
    this.notes,
    this.lastContactAt,
    required this.createdAt,
    required this.updatedAt,
    this.assignedTo,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      interestedIn: json['interested_in'],
      budget: (json['budget'] ?? 0.0).toDouble(),
      assignedToId: json['assigned_to_id'],
      status: json['status'] ?? 'new',
      notes: json['notes'],
      lastContactAt: json['last_contact_at'] != null
          ? DateTime.parse(json['last_contact_at'])
          : null,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      assignedTo: json['assigned_to'] != null
          ? User.fromJson(json['assigned_to'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'interested_in': interestedIn,
      'budget': budget,
      'assigned_to_id': assignedToId,
      'status': status,
      'notes': notes,
      'last_contact_at': lastContactAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (assignedTo != null) 'assigned_to': assignedTo!.toJson(),
    };
  }

  String get formattedBudget => '\$${budget.toStringAsFixed(2)}';
  String get statusDisplayName => status.toUpperCase();
  
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  bool get isAssigned => assignedToId != null;
  bool get isNew => status == 'new';
  bool get isContacted => status == 'contacted';
  bool get isQualified => status == 'qualified';
  bool get isConverted => status == 'converted';
  bool get isLost => status == 'lost';

  String get priorityLevel {
    if (budget > 50000) return 'High';
    if (budget > 25000) return 'Medium';
    return 'Low';
  }

  String? get lastContactFormatted {
    if (lastContactAt == null) return null;
    
    final now = DateTime.now();
    final difference = now.difference(lastContactAt!);
    
    if (difference.inDays > 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inMinutes} minutes ago';
    }
  }

  Lead copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? interestedIn,
    double? budget,
    int? assignedToId,
    String? status,
    String? notes,
    DateTime? lastContactAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? assignedTo,
  }) {
    return Lead(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      interestedIn: interestedIn ?? this.interestedIn,
      budget: budget ?? this.budget,
      assignedToId: assignedToId ?? this.assignedToId,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      lastContactAt: lastContactAt ?? this.lastContactAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }

  @override
  String toString() {
    return 'Lead(id: $id, name: $name, status: $status, budget: $budget)';
  }
}