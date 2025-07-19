import 'package:flutter/material.dart';
import '../../data/models/vehicle.dart';

class VehicleGridWidget extends StatelessWidget {
  final List<Vehicle> vehicles;
  final Function(Vehicle) onVehicleTap;
  final int crossAxisCount;
  final double childAspectRatio;

  const VehicleGridWidget({
    super.key,
    required this.vehicles,
    required this.onVehicleTap,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    if (vehicles.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.directions_car, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No vehicles available'),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return _buildVehicleCard(context, vehicle);
      },
    );
  }

  Widget _buildVehicleCard(BuildContext context, Vehicle vehicle) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => onVehicleTap(vehicle),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Stack(
                  children: [
                    // Vehicle Image
                    if (vehicle.primaryImage != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.network(
                          vehicle.primaryImage!.url,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        ),
                      )
                    else
                      _buildPlaceholderImage(),

                    // Status Badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildStatusBadge(context, vehicle.status),
                    ),

                    // Price Badge
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          vehicle.priceFormatted,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Vehicle Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.displayName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vehicle.year} • ${vehicle.mileage.toStringAsFixed(0)} mi',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.local_gas_station,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            vehicle.color ?? 'Color N/A',
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: const Icon(
        Icons.directions_car,
        size: 48,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, VehicleStatus status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case VehicleStatus.available:
        backgroundColor = Colors.green;
        textColor = Colors.white;
        label = 'Available';
        break;
      case VehicleStatus.sold:
        backgroundColor = Colors.red;
        textColor = Colors.white;
        label = 'Sold';
        break;
      case VehicleStatus.reserved:
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        label = 'Reserved';
        break;
      case VehicleStatus.service:
        backgroundColor = Colors.blue;
        textColor = Colors.white;
        label = 'Service';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}