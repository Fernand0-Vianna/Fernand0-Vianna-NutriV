import 'package:flutter/material.dart';

class WaterTrackerWidget extends StatelessWidget {
  final double currentIntake;
  final double goal;
  final VoidCallback onAddWater;
  final VoidCallback onRemoveWater;

  const WaterTrackerWidget({
    super.key,
    required this.currentIntake,
    required this.goal,
    required this.onAddWater,
    required this.onRemoveWater,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentIntake / goal).clamp(0.0, 1.0);
    final remaining = (goal - currentIntake).clamp(0.0, goal);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.water_drop, color: Colors.blue[400]),
                    const SizedBox(width: 8),
                    Text(
                      'Água',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${currentIntake.toInt()} / ${goal.toInt()} ml',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.blue[100],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${remaining.toInt()} ml restantes',
              style: TextStyle(
                color: Colors.blue[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAddButton(context, 150),
                _buildQuickAddButton(context, 250),
                _buildQuickAddButton(context, 350),
                _buildQuickAddButton(context, 500),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddButton(BuildContext context, int amount) {
    return InkWell(
      onTap: onAddWater,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(Icons.add, color: Colors.blue[400], size: 20),
            Text(
              '${amount}ml',
              style: TextStyle(
                color: Colors.blue[600],
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
