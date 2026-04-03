import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/meal/meal_bloc.dart';
import '../../bloc/meal/meal_event.dart';
import '../../bloc/meal/meal_state.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_state.dart';
import '../../bloc/water/water_bloc.dart';
import '../../bloc/water/water_event.dart';
import '../../widgets/macro_card.dart';
import '../../widgets/calorie_ring.dart';
import '../../widgets/meal_card.dart';
import '../../widgets/water_tracker_widget.dart';
import '../../../core/theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<MealBloc>().add(LoadMeals(DateTime.now()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          if (userState is UserLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<MealBloc>().add(LoadMeals(DateTime.now()));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGreetingCard(userState.user.name),
                      const SizedBox(height: 20),
                      _buildCalorieCard(userState),
                      const SizedBox(height: 20),
                      _buildMacrosSection(userState),
                      const SizedBox(height: 20),
                      _buildWaterSection(),
                      const SizedBox(height: 20),
                      _buildMealsSection(),
                    ],
                  ),
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildGreetingCard(String name) {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF00E676)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none, color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  Widget _buildCalorieCard(UserLoaded userState) {
    return BlocBuilder<MealBloc, MealState>(
      builder: (context, mealState) {
        double consumed = 0;
        double goal = userState.user.calorieGoal;

        if (mealState is MealLoaded) {
          consumed = mealState.totalCalories;
        }

        final progress = goal > 0 ? consumed / goal : 0.0;
        final remaining = (goal - consumed).clamp(0, goal);

        return Container(
          padding: const EdgeInsets.all(24),
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Calorias',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${remaining.toInt()} restantes',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CalorieRing(consumed: consumed, goal: goal),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMacrosSection(UserLoaded userState) {
    return BlocBuilder<MealBloc, MealState>(
      builder: (context, mealState) {
        double protein = 0, carbs = 0, fat = 0;
        double proteinGoal = userState.user.proteinGoal;
        double carbsGoal = userState.user.carbsGoal;
        double fatGoal = userState.user.fatGoal;

        if (mealState is MealLoaded) {
          protein = mealState.totalProtein;
          carbs = mealState.totalCarbs;
          fat = mealState.totalFat;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Macronutrientes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMacroWidget(
                    'Proteína',
                    protein,
                    proteinGoal,
                    const Color(0xFF2196F3),
                    'g',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMacroWidget(
                    'Carboidratos',
                    carbs,
                    carbsGoal,
                    const Color(0xFFFF9800),
                    'g',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMacroWidget(
                    'Gordura',
                    fat,
                    fatGoal,
                    const Color(0xFFE91E63),
                    'g',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMacroWidget(
    String label,
    double value,
    double goal,
    Color color,
    String unit,
  ) {
    final progress = goal > 0 ? value / goal : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            '${value.toInt()}/${goal.toInt()}$unit',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            width: 40,
            child: CircularProgressIndicator(
              value: progress.clamp(0, 1),
              backgroundColor: color.withValues(alpha: 0.2),
              color: color,
              strokeWidth: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterSection() {
    return BlocBuilder<WaterBloc, WaterState>(
      builder: (context, state) {
        if (state is WaterLoaded) {
          return WaterTrackerWidget(
            currentIntake: state.currentIntake,
            goal: state.goal,
            onAddWater: () =>
                context.read<WaterBloc>().add(const AddWater(250)),
            onRemoveWater: () =>
                context.read<WaterBloc>().add(const RemoveWater(250)),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMealsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Refeições de hoje',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Ver mais',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        BlocBuilder<MealBloc, MealState>(
          builder: (context, state) {
            if (state is MealLoaded) {
              if (state.meals.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.restaurant_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nenhuma refeição hoje',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                          label: const Text('Adicionar'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.meals.length,
                itemBuilder: (context, index) {
                  return MealCard(meal: state.meals[index]);
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ],
    );
  }
}
