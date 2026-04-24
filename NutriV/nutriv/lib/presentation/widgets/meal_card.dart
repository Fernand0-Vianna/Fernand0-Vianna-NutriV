import 'package:flutter/material.dart';
import '../../../domain/entities/meal.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  VoidCallback? onCopy;

  MealCard({
    super.key, 
    required this.meal, 
    this.onTap, 
    this.onDelete,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                      Icon(
                        _getMealIcon(meal.mealType),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        meal.name.isNotEmpty ? meal.name : meal.mealType,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text(
                    '${meal.totalCalories.toInt()} kcal',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              if (meal.foods.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: meal.foods.map((food) {
                    return Text(
                      food.food.name,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildMacroChip(
                    'P',
                    meal.totalProtein,
                    const Color(0xFF2196F3),
                  ),
                  const SizedBox(width: 8),
                  _buildMacroChip(
                    'C',
                    meal.totalCarbs,
                    const Color(0xFFFF9800),
                  ),
                  const SizedBox(width: 8),
                  _buildMacroChip('G', meal.totalFat, const Color(0xFFE91E63)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroChip(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: ${value.toInt()}g',
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'Café da manhã':
        return Icons.wb_sunny_outlined;
      case 'Almoço':
        return Icons.restaurant_outlined;
      case 'Jantar':
        return Icons.nightlight_outlined;
      case 'Lanche':
        return Icons.coffee_outlined;
      default:
        return Icons.restaurant_outlined;
    }
  }
}
