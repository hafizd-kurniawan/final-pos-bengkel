import 'package:flutter/material.dart';
import '../../data/models/test_drive.dart';

class TestDriveCard extends StatelessWidget {
  final TestDrive testDrive;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const TestDriveCard({
    super.key,
    required this.testDrive,
    this.onTap,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle Image
                  Container(
                    width: 80,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: testDrive.vehicle?.primaryImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              testDrive.vehicle!.primaryImage!.url,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.directions_car);
                              },
                            ),
                          )
                        : const Icon(Icons.directions_car),
                  ),
                  const SizedBox(width: 12),
                  
                  // Vehicle Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          testDrive.vehicle?.displayName ?? 'Unknown Vehicle',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          testDrive.vehicle?.priceFormatted ?? '',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status Badge
                  _buildStatusBadge(context, testDrive.status),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Test Drive Details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: _getStatusColor(testDrive.status),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Scheduled Time',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const Spacer(),
                        Text(
                          testDrive.formattedScheduledTime,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    
                    if (testDrive.notes != null && testDrive.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.note,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Notes',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              testDrive.notes!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    if (testDrive.customerFeedback != null && testDrive.customerFeedback!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.feedback,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Feedback',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              testDrive.customerFeedback!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Actions
              Row(
                children: [
                  // Time indicator
                  if (testDrive.isPast)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.history, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Past',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ],
                      ),
                    )
                  else if (testDrive.isToday)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.today, size: 14, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            'Today',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // Action buttons
                  if (_canCancel(testDrive) && onCancel != null) ...[
                    TextButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.cancel, size: 16),
                      label: const Text('Cancel'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  
                  if (_canReschedule(testDrive)) ...[
                    TextButton.icon(
                      onPressed: () {
                        _showRescheduleDialog(context);
                      },
                      icon: const Icon(Icons.schedule, size: 16),
                      label: const Text('Reschedule'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  
                  OutlinedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, TestDriveStatus status) {
    Color backgroundColor = _getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: backgroundColor.withOpacity(0.3)),
      ),
      child: Text(
        status.value.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: backgroundColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Color _getStatusColor(TestDriveStatus status) {
    switch (status) {
      case TestDriveStatus.pending:
        return Colors.orange;
      case TestDriveStatus.approved:
        return Colors.blue;
      case TestDriveStatus.completed:
        return Colors.green;
      case TestDriveStatus.canceled:
        return Colors.red;
    }
  }

  bool _canCancel(TestDrive testDrive) {
    return !testDrive.isPast && 
           (testDrive.status == TestDriveStatus.pending || 
            testDrive.status == TestDriveStatus.approved);
  }

  bool _canReschedule(TestDrive testDrive) {
    return !testDrive.isPast && 
           testDrive.status == TestDriveStatus.pending;
  }

  void _showRescheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reschedule Test Drive'),
        content: const Text('Reschedule functionality would be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Reschedule'),
          ),
        ],
      ),
    );
  }
}