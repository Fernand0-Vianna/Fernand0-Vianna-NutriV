import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.water_drop,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Água',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                '${currentIntake.toInt()} / ${goal.toInt()} ml',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.blue.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${remaining.toInt()} ml restantes',
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickAddButton(150),
              _buildQuickAddButton(250),
              _buildQuickAddButton(350),
              _buildQuickAddButton(500),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(int amount) {
    return GestureDetector(
      onTap: onAddWater,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Column(
          children: [
            const Icon(Icons.add, color: Colors.blue, size: 18),
            const SizedBox(height: 4),
            Text(
              '${amount}ml',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
