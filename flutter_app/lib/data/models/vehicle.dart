enum VehicleStatus {
  available('available'),
  sold('sold'),
  reserved('reserved'),
  service('service');

  const VehicleStatus(this.value);
  final String value;

  static VehicleStatus fromString(String value) {
    return VehicleStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => VehicleStatus.available,
    );
  }
}

class VehicleImage {
  final int id;
  final int vehicleId;
  final String url;
  final bool isPrimary;

  const VehicleImage({
    required this.id,
    required this.vehicleId,
    required this.url,
    required this.isPrimary,
  });

  factory VehicleImage.fromJson(Map<String, dynamic> json) {
    return VehicleImage(
      id: json['id'] ?? 0,
      vehicleId: json['vehicle_id'] ?? 0,
      url: json['url'] ?? '',
      isPrimary: json['is_primary'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'url': url,
      'is_primary': isPrimary,
    };
  }
}

class Vehicle {
  final int id;
  final String make;
  final String model;
  final int year;
  final String? color;
  final String? vin;
  final String? licensePlate;
  final double price;
  final int mileage;
  final VehicleStatus status;
  final String? description;
  final List<VehicleImage> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    this.color,
    this.vin,
    this.licensePlate,
    required this.price,
    required this.mileage,
    required this.status,
    this.description,
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    final imagesList = json['images'] as List<dynamic>? ?? [];
    final images = imagesList
        .map((img) => VehicleImage.fromJson(img as Map<String, dynamic>))
        .toList();

    return Vehicle(
      id: json['id'] ?? 0,
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      color: json['color'],
      vin: json['vin'],
      licensePlate: json['license_plate'],
      price: (json['price'] ?? 0.0).toDouble(),
      mileage: json['mileage'] ?? 0,
      status: VehicleStatus.fromString(json['status'] ?? 'available'),
      description: json['description'],
      images: images,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'vin': vin,
      'license_plate': licensePlate,
      'price': price,
      'mileage': mileage,
      'status': status.value,
      'description': description,
      'images': images.map((img) => img.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayName => '$make $model';
  String get yearString => year.toString();
  String get priceFormatted => '\$${price.toStringAsFixed(2)}';
  
  VehicleImage? get primaryImage {
    final primary = images.where((img) => img.isPrimary).firstOrNull;
    return primary ?? images.firstOrNull;
  }

  Vehicle copyWith({
    int? id,
    String? make,
    String? model,
    int? year,
    String? color,
    String? vin,
    String? licensePlate,
    double? price,
    int? mileage,
    VehicleStatus? status,
    String? description,
    List<VehicleImage>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      vin: vin ?? this.vin,
      licensePlate: licensePlate ?? this.licensePlate,
      price: price ?? this.price,
      mileage: mileage ?? this.mileage,
      status: status ?? this.status,
      description: description ?? this.description,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Vehicle(id: $id, make: $make, model: $model, year: $year, status: $status)';
  }
}