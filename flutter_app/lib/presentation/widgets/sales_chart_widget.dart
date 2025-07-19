import 'package:flutter/material.dart';
import '../../data/models/dashboard.dart';

class SalesChartWidget extends StatelessWidget {
  final List<SalesChartData> data;

  const SalesChartWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sales Trend (Last 7 Days)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: data.isEmpty
              ? const Center(
                  child: Text('No sales data available'),
                )
              : CustomPaint(
                  painter: SalesChartPainter(data),
                  size: const Size(double.infinity, 200),
                ),
        ),
        const SizedBox(height: 16),
        _buildLegend(context),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(
          context,
          'Sales Count',
          Theme.of(context).colorScheme.primary,
        ),
        _buildLegendItem(
          context,
          'Revenue',
          Theme.of(context).colorScheme.secondary,
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class SalesChartPainter extends CustomPainter {
  final List<SalesChartData> data;

  SalesChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final maxSales = data.map((e) => e.sales).reduce((a, b) => a > b ? a : b);
    final maxRevenue = data.map((e) => e.revenue).reduce((a, b) => a > b ? a : b);

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

    // Draw revenue line (normalized)
    paint.color = Colors.green;
    final revenuePath = Path();
    final revenueScale = maxSales / maxRevenue; // Scale revenue to sales range
    
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedRevenue = data[i].revenue * revenueScale;
      final y = size.height - (normalizedRevenue / maxSales) * size.height * 0.8;
      
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
      canvas.drawCircle(Offset(x, salesY), 4, paint);
      
      // Revenue point
      final normalizedRevenue = data[i].revenue * revenueScale;
      final revenueY = size.height - (normalizedRevenue / maxSales) * size.height * 0.8;
      paint.color = Colors.green;
      canvas.drawCircle(Offset(x, revenueY), 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}