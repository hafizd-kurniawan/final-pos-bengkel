import 'package:flutter/material.dart';
import '../../data/models/dashboard.dart';

class RecentActivitiesWidget extends StatelessWidget {
  final DashboardRecentData recentData;

  const RecentActivitiesWidget({
    super.key,
    required this.recentData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSectionCard(
          context,
          title: 'Recent Sales',
          icon: Icons.shopping_cart,
          color: Colors.green,
          children: recentData.recentSales.isEmpty
              ? [const ListTile(title: Text('No recent sales'))]
              : recentData.recentSales.take(3).map((sale) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.withOpacity(0.1),
                      child: const Icon(Icons.attach_money, color: Colors.green),
                    ),
                    title: Text(sale.vehicle?.displayName ?? 'Unknown Vehicle'),
                    subtitle: Text(
                      '${sale.customer?.name ?? 'Unknown Customer'} • ${sale.formattedPrice}',
                    ),
                    trailing: Chip(
                      label: Text(sale.statusDisplayName),
                      backgroundColor: _getStatusColor(sale.status.value).withOpacity(0.1),
                      side: BorderSide.none,
                    ),
                  );
                }).toList(),
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          context,
          title: 'Recent Test Drives',
          icon: Icons.drive_eta,
          color: Colors.blue,
          children: recentData.recentTestDrives.isEmpty
              ? [const ListTile(title: Text('No recent test drives'))]
              : recentData.recentTestDrives.take(3).map((testDrive) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: const Icon(Icons.drive_eta, color: Colors.blue),
                    ),
                    title: Text(testDrive.vehicle?.displayName ?? 'Unknown Vehicle'),
                    subtitle: Text(
                      '${testDrive.customer?.name ?? 'Unknown Customer'} • ${testDrive.formattedScheduledTime}',
                    ),
                    trailing: Chip(
                      label: Text(testDrive.statusDisplayName),
                      backgroundColor: _getStatusColor(testDrive.status.value).withOpacity(0.1),
                      side: BorderSide.none,
                    ),
                  );
                }).toList(),
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          context,
          title: 'Recent Leads',
          icon: Icons.psychology,
          color: Colors.orange,
          children: recentData.recentLeads.isEmpty
              ? [const ListTile(title: Text('No recent leads'))]
              : recentData.recentLeads.take(3).map((lead) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.withOpacity(0.1),
                      child: Text(
                        lead.initials,
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(lead.name),
                    subtitle: Text(
                      '${lead.interestedIn ?? 'General Inquiry'} • ${lead.formattedBudget}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Chip(
                          label: Text(lead.statusDisplayName),
                          backgroundColor: _getStatusColor(lead.status).withOpacity(0.1),
                          side: BorderSide.none,
                        ),
                        if (lead.isAssigned && lead.assignedTo != null)
                          Text(
                            lead.assignedTo!.name,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  );
                }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigate to full list
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'approved':
      case 'converted':
        return Colors.green;
      case 'pending':
      case 'new':
        return Colors.orange;
      case 'canceled':
      case 'lost':
        return Colors.red;
      case 'contacted':
      case 'qualified':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}