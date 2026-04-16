import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../bloc/meal/meal_bloc.dart';
import '../../bloc/meal/meal_event.dart';
import '../../bloc/meal/meal_state.dart';
import '../../widgets/meal_card.dart';
import '../../../core/theme/app_theme.dart';

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
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                child: Column(
                  children: [_buildHeader(), const SizedBox(height: 20)],
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildDateSelector()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: BlocBuilder<MealBloc, MealState>(
                  builder: (context, state) {
                    if (state is MealLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(48),
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                        ),
                      );
                    }
                    if (state is MealLoaded) {
                      return _buildMealsList(state);
                    }
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: Text(
                          'Carregando...',
                          style: GoogleFonts.manrope(
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/scanner'),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: AppTheme.onPrimary),
        label: Text(
          'Adicionar',
          style: GoogleFonts.manrope(
            color: AppTheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Diário',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.onSurface,
          ),
        ),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: AppTheme.onSurface,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime.now().subtract(Duration(days: 13 - index));
          final isSelected = _isSameDay(date, _selectedDate);

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = date);
              context.read<MealBloc>().add(LoadMeals(date));
            },
            child: Container(
              width: 56,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).substring(0, 3),
                    style: GoogleFonts.manrope(
                      color: isSelected
                          ? AppTheme.onPrimary.withValues(alpha: 0.7)
                          : AppTheme.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date.day.toString(),
                    style: GoogleFonts.plusJakartaSans(
                      color: isSelected
                          ? AppTheme.onPrimary
                          : AppTheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isSelected)
                    Container(
                      width: 20,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppTheme.onPrimary,
                        borderRadius: BorderRadius.circular(2),
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

    return Column(
      children: mealTypes.map((mealType) {
        final mealsForType = state.getMealsByType(mealType);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
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
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getMealIcon(mealType),
                          color: AppTheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mealType,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurface,
                            ),
                          ),
                          if (mealsForType.isNotEmpty)
                            Text(
                              '${mealsForType.fold<double>(0, (sum, m) => sum + m.totalCalories).toInt()} kcal',
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  if (mealsForType.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add,
                            size: 16,
                            color: AppTheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Add',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: AppTheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (mealsForType.isEmpty)
                GestureDetector(
                  onTap: () => context.go('/scanner'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.outlineVariant,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: AppTheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Adicionar refeição',
                          style: GoogleFonts.manrope(
                            color: AppTheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...mealsForType.map(
                  (meal) => Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: MealCard(
                      meal: meal,
                      onTap: () {},
                      onDelete: () {
                        context.read<MealBloc>().add(DeleteMeal(meal.id));
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'Café da manhã':
        return Icons.free_breakfast;
      case 'Almoço':
        return Icons.lunch_dining;
      case 'Jantar':
        return Icons.dinner_dining;
      case 'Lanche':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _selectDate() async {
    final bloc = context.read<MealBloc>();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      bloc.add(LoadMeals(picked));
    }
  }
}
