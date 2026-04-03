import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';

class CalorieRing extends StatelessWidget {
  final double consumed;
  final double goal;

  const CalorieRing({super.key, required this.consumed, required this.goal});

  @override
  Widget build(BuildContext context) {
    final percentage = (consumed / goal).clamp(0.0, 1.0);
    final remaining = (goal - consumed).clamp(0.0, goal);

    return Column(
      children: [
        SizedBox(
          height: 160,
          width: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 50,
                  startDegreeOffset: 270,
                  sections: [
                    PieChartSectionData(
                      value: percentage * 100,
                      color: AppTheme.primaryColor,
                      radius: 18,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: (1 - percentage) * 100,
                      color: Colors.grey.shade200,
                      radius: 18,
                      showTitle: false,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    consumed.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '/ ${goal.toInt()}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildInfoColumn(
              'Consumidas',
              '${consumed.toInt()}',
              AppTheme.primaryColor,
            ),
            _buildInfoColumn(
              'Restantes',
              '${remaining.toInt()}',
              Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
