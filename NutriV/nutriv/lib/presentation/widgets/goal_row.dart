import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class GoalRow extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;
  final double? progress;

  const GoalRow({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${value.toInt()}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  Text(
                    ' $unit',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  if (progress != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${(progress! * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}