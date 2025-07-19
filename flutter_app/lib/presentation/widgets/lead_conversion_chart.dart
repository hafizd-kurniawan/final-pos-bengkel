import 'package:flutter/material.dart';
import '../../data/models/dashboard.dart';

class LeadConversionChart extends StatelessWidget {
  final List<LeadConversionData> data;

  const LeadConversionChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lead Conversion Funnel',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: data.isEmpty
              ? const Center(
                  child: Text('No lead data available'),
                )
              : _buildFunnelChart(context),
        ),
        const SizedBox(height: 16),
        _buildLegend(context),
      ],
    );
  }

  Widget _buildFunnelChart(BuildContext context) {
    final maxCount = data.map((e) => e.count).reduce((a, b) => a > b ? a : b);
    final colors = _getStageColors();

    return Column(
      children: data.map((stage) {
        final width = (stage.count / maxCount) * 300;
        final color = colors[stage.status] ?? Colors.grey;
        
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  stage.status.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                  ),
                  width: width,
                  alignment: Alignment.center,
                  child: Text(
                    '${stage.count}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  '${((stage.count / maxCount) * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final colors = _getStageColors();
    
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: data.map((stage) {
        final color = colors[stage.status] ?? Colors.grey;
        return _buildLegendItem(context, stage.status, color, stage.count);
      }).toList(),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color, int count) {
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
          '$label ($count)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Map<String, Color> _getStageColors() {
    return {
      'new': Colors.blue,
      'contacted': Colors.orange,
      'qualified': Colors.purple,
      'converted': Colors.green,
      'lost': Colors.red,
    };
  }
}