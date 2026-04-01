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
      appBar: AppBar(
        title: const Text('NutriV'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          if (userState is UserLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<MealBloc>().add(LoadMeals(DateTime.now()));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(userState.user.name),
                    const SizedBox(height: 24),
                    _buildCalorieSummary(userState),
                    const SizedBox(height: 24),
                    _buildMacrosRow(userState),
                    const SizedBox(height: 16),
                    _buildWaterTracker(),
                    const SizedBox(height: 24),
                    _buildTodayMeals(),
                  ],
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildGreeting(String name) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Bom dia';
    } else if (hour < 18) {
      greeting = 'Boa tarde';
    } else {
      greeting = 'Boa noite';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting,',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
        ),
        Text(
          name,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCalorieSummary(UserLoaded userState) {
    return BlocBuilder<MealBloc, MealState>(
      builder: (context, mealState) {
        double consumed = 0;
        double goal = userState.user.calorieGoal;

        if (mealState is MealLoaded) {
          consumed = mealState.totalCalories;
        }

        return CalorieRing(consumed: consumed, goal: goal);
      },
    );
  }

  Widget _buildWaterTracker() {
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

  Widget _buildMacrosRow(UserLoaded userState) {
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

        return Row(
          children: [
            Expanded(
              child: MacroCard(
                label: 'Proteína',
                value: protein,
                goal: proteinGoal,
                color: const Color(0xFF2196F3),
                unit: 'g',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MacroCard(
                label: 'Carboidratos',
                value: carbs,
                goal: carbsGoal,
                color: const Color(0xFFFF9800),
                unit: 'g',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MacroCard(
                label: 'Gordura',
                value: fat,
                goal: fatGoal,
                color: const Color(0xFFE91E63),
                unit: 'g',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTodayMeals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Refeições de hoje',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(onPressed: () {}, child: const Text('Ver mais')),
          ],
        ),
        const SizedBox(height: 8),
        BlocBuilder<MealBloc, MealState>(
          builder: (context, state) {
            if (state is MealLoaded) {
              if (state.meals.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.restaurant_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nenhuma refeição registrada hoje',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar refeição'),
                          ),
                        ],
                      ),
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
