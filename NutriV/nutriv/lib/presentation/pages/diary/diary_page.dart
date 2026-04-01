import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/meal/meal_bloc.dart';
import '../../bloc/meal/meal_event.dart';
import '../../bloc/meal/meal_state.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_state.dart';
import '../../widgets/meal_card.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<MealBloc>().add(LoadMeals(_selectedDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          Expanded(
            child: BlocBuilder<MealBloc, MealState>(
              builder: (context, state) {
                if (state is MealLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is MealLoaded) {
                  return _buildMealsList(state);
                }
                return const Center(child: Text('Carregando...'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/scanner'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = DateTime.now().subtract(Duration(days: 6 - index));
          final isSelected = _isSameDay(date, _selectedDate);
          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = date);
              context.read<MealBloc>().add(LoadMeals(date));
            },
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayName(date.weekday),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealsList(MealLoaded state) {
    final mealTypes = ['Café da manhã', 'Almoço', 'Jantar', 'Lanche'];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mealTypes.length,
      itemBuilder: (context, index) {
        final mealType = mealTypes[index];
        final mealsForType = state.getMealsByType(mealType);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  mealType,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (mealsForType.isNotEmpty)
                  Text(
                    '${mealsForType.fold<double>(0, (sum, m) => sum + m.totalCalories).toInt()} kcal',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (mealsForType.isEmpty)
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.add_circle_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Adicionar refeição'),
                  onTap: () => context.go('/scanner'),
                ),
              )
            else
              ...mealsForType.map(
                (meal) => MealCard(
                  meal: meal,
                  onTap: () {},
                  onDelete: () {
                    context.read<MealBloc>().add(DeleteMeal(meal.id));
                  },
                ),
              ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getDayName(int weekday) {
    const days = ['', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return days[weekday];
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      context.read<MealBloc>().add(LoadMeals(picked));
    }
  }
}
