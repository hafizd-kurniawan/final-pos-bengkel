import 'package:flutter/material.dart';
import '../../data/models/dashboard.dart';

class SalesPerformanceWidget extends StatelessWidget {
  final List<SalesChartData> salesData;

  const SalesPerformanceWidget({
    super.key,
    required this.salesData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sales Performance (Last 7 Days)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        if (salesData.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No sales data available'),
            ),
          )
        else ...[
          _buildPerformanceMetrics(context),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: PerformanceChartPainter(salesData),
              size: const Size(double.infinity, 200),
            ),
          ),
          const SizedBox(height: 16),
          _buildDailyBreakdown(context),
        ],
      ],
    );
  }

  Widget _buildPerformanceMetrics(BuildContext context) {
    final totalSales = salesData.fold(0, (sum, data) => sum + data.sales);
    final totalRevenue = salesData.fold(0.0, (sum, data) => sum + data.revenue);
    final avgDailyRevenue = totalRevenue / salesData.length;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            'Total Sales',
            totalSales.toString(),
            Icons.shopping_cart,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            context,
            'Total Revenue',
            '\$${totalRevenue.toStringAsFixed(0)}',
            Icons.attach_money,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            context,
            'Avg Daily',
            '\$${avgDailyRevenue.toStringAsFixed(0)}',
            Icons.trending_up,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
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
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyBreakdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Breakdown',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...salesData.map((data) => Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(data.date),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${data.sales} sales',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${data.revenue.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final targetDate = DateTime(date.year, date.month, date.day);

      if (targetDate == today) {
        return 'Today';
      } else if (targetDate == today.subtract(const Duration(days: 1))) {
        return 'Yesterday';
      } else {
        final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return weekdays[date.weekday - 1];
      }
    } catch (e) {
      return dateStr;
    }
  }
}

class PerformanceChartPainter extends CustomPainter {
  final List<SalesChartData> data;

  PerformanceChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final maxSales = data.map((e) => e.sales).reduce((a, b) => a > b ? a : b);
    final maxRevenue = data.map((e) => e.revenue).reduce((a, b) => a > b ? a : b);

    // Draw background grid
    _drawGrid(canvas, size);

    // Draw sales line
    paint.color = Colors.blue;
    final salesPath = Path();
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - (data[i].sales / maxSales) * size.height * 0.8;
      
      if (i == 0) {
        salesPath.moveTo(x, y);
      } else {
        salesPath.lineTo(x, y);
      }
    }
    canvas.drawPath(salesPath, paint);

    // Draw revenue line (scaled)
    paint.color = Colors.green;
    final revenuePath = Path();
    final revenueScale = maxSales / maxRevenue;
    
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final scaledRevenue = data[i].revenue * revenueScale;
      final y = size.height - (scaledRevenue / maxSales) * size.height * 0.8;
      
      if (i == 0) {
        revenuePath.moveTo(x, y);
      } else {
        revenuePath.lineTo(x, y);
      }
    }
    canvas.drawPath(revenuePath, paint);

    // Draw data points
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      
      // Sales point
      final salesY = size.height - (data[i].sales / maxSales) * size.height * 0.8;
      paint.color = Colors.blue;
      canvas.drawCircle(Offset(x, salesY), 5, paint);
      
      // Revenue point
      final scaledRevenue = data[i].revenue * revenueScale;
      final revenueY = size.height - (scaledRevenue / maxSales) * size.height * 0.8;
      paint.color = Colors.green;
      canvas.drawCircle(Offset(x, revenueY), 5, paint);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    // Horizontal lines
    for (int i = 1; i < 5; i++) {
      final y = (i / 5) * size.height;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Vertical lines
    for (int i = 1; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}