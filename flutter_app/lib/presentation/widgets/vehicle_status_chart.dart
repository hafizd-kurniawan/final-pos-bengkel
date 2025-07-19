import 'package:flutter/material.dart';
import '../../data/models/dashboard.dart';

class VehicleStatusChart extends StatelessWidget {
  final List<VehicleStatusData> data;

  const VehicleStatusChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehicle Status Distribution',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: data.isEmpty
              ? const Center(
                  child: Text('No vehicle data available'),
                )
              : Row(
                  children: [
                    Expanded(
                      child: CustomPaint(
                        painter: PieChartPainter(data),
                        size: const Size(150, 150),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildLegend(context),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    final colors = _getStatusColors();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: data.map((item) {
        final color = colors[item.status] ?? Colors.grey;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${item.status.toUpperCase()} (${item.count})',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Map<String, Color> _getStatusColors() {
    return {
      'available': Colors.green,
      'sold': Colors.blue,
      'reserved': Colors.orange,
      'service': Colors.red,
    };
  }
}

class PieChartPainter extends CustomPainter {
  final List<VehicleStatusData> data;

  PieChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8;
    final total = data.map((e) => e.count).reduce((a, b) => a + b);
    
    final colors = {
      'available': Colors.green,
      'sold': Colors.blue,
      'reserved': Colors.orange,
      'service': Colors.red,
    };

    double startAngle = -90 * (3.14159 / 180); // Start from top

    for (final item in data) {
      final sweepAngle = (item.count / total) * 2 * 3.14159;
      final color = colors[item.status] ?? Colors.grey;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      startAngle += sweepAngle;
    }

    // Draw center circle for donut effect
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.4, centerPaint);

    // Draw total count in center
    final textPainter = TextPainter(
      text: TextSpan(
        text: total.toString(),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    // Draw "Total" label
    final labelPainter = TextPainter(
      text: const TextSpan(
        text: 'Total',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    labelPainter.layout();
    labelPainter.paint(
      canvas,
      Offset(
        center.dx - labelPainter.width / 2,
        center.dy + textPainter.height / 2 + 4,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}