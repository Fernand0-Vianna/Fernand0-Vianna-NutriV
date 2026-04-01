import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CalorieRing extends StatelessWidget {
  final double consumed;
  final double goal;

  const CalorieRing({super.key, required this.consumed, required this.goal});

  @override
  Widget build(BuildContext context) {
    final percentage = (consumed / goal).clamp(0.0, 1.0);
    final remaining = (goal - consumed).clamp(0.0, goal);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 180,
              width: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 60,
                      startDegreeOffset: 270,
                      sections: [
                        PieChartSectionData(
                          value: percentage * 100,
                          color: Theme.of(context).colorScheme.primary,
                          radius: 20,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: (1 - percentage) * 100,
                          color: Colors.grey.shade200,
                          radius: 20,
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
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '/ ${goal.toInt()} kcal',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoColumn(
                  context,
                  'Consumidas',
                  '${consumed.toInt()}',
                  Colors.green,
                ),
                _buildInfoColumn(
                  context,
                  'Restantes',
                  '${remaining.toInt()}',
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
