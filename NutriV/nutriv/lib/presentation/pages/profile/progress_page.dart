import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../../core/theme/app_theme.dart';
import '../../bloc/meal/meal_bloc.dart';
import '../../bloc/meal/meal_event.dart';
import '../../bloc/meal/meal_state.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_state.dart';
import '../../../domain/entities/meal.dart';
import '../../../data/repositories/sync_meal_repository.dart';
import '../../../core/di/injection.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  List<Meal> _meals = [];
  double _calorieGoal = 2000;
  double _proteinGoal = 150;
  double _carbsGoal = 250;
  double _fatGoal = 65;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      setState(() {
        _calorieGoal = userState.user.calorieGoal;
        _proteinGoal = userState.user.proteinGoal;
        _carbsGoal = userState.user.carbsGoal;
        _fatGoal = userState.user.fatGoal;
      });
    }

    final mealState = context.read<MealBloc>().state;
    if (mealState is MealLoaded) {
      setState(() {
        _meals = mealState.meals;
        _isLoading = false;
      });
    } else {
      context.read<MealBloc>().add(LoadMeals(DateTime.now()));
    }
  }

  Map<String, double> _getMealCalories() {
    final mealCalories = <String, double>{};
    for (final meal in _meals) {
      final totalCalories = meal.foods.fold<double>(
        0,
        (sum, food) => sum + food.totalCalories,
      );
      mealCalories[meal.mealType] = totalCalories;
    }
    return mealCalories;
  }

  double _getTotalCalories() {
    return _meals.fold<double>(
      0,
      (sum, meal) => sum + meal.totalCalories,
    );
  }

  double _getTotalProtein() {
    return _meals.fold<double>(
      0,
      (sum, meal) => sum + meal.totalProtein,
    );
  }

  double _getTotalCarbs() {
    return _meals.fold<double>(
      0,
      (sum, meal) => sum + meal.totalCarbs,
    );
  }

  double _getTotalFat() {
    return _meals.fold<double>(
      0,
      (sum, meal) => sum + meal.totalFat,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<MealBloc, MealState>(
          listener: (context, state) {
            if (state is MealLoaded) {
              setState(() {
                _meals = state.meals;
                _isLoading = false;
              });
            }
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Estatísticas',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: _exportProgressCsv,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.download,
                                        size: 14,
                                        color: AppTheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Exportar',
                                        style: GoogleFonts.manrope(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: AppTheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Hoje',
                                      style: GoogleFonts.manrope(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? _buildLoadingCard()
                          : _buildCalorieSummaryCard(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDailyCaloriesChart(),
                      const SizedBox(height: 24),
                      _buildMacrosSection(),
                      const SizedBox(height: 24),
                      _buildInsightCard(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildCalorieSummaryCard() {
    final totalCalories = _getTotalCalories();
    final mealCalories = _getMealCalories();
    final maxCalories = mealCalories.values.isEmpty
        ? 1.0
        : mealCalories.values.reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meta Calórica',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: _calorieGoal.toInt().toString(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                            ),
                          ),
                          TextSpan(
                            text: ' kcal / dia',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Consumido',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    totalCalories.toInt().toString(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildDayBar(
                  'C',
                  mealCalories['café da manhã'] ?? 0,
                  maxCalories,
                ),
              ),
              Expanded(
                child: _buildDayBar(
                  'A',
                  mealCalories['almoço'] ?? 0,
                  maxCalories,
                ),
              ),
              Expanded(
                child: _buildDayBar(
                  'L',
                  mealCalories['lanche'] ?? 0,
                  maxCalories,
                ),
              ),
              Expanded(
                child: _buildDayBar(
                  'J',
                  mealCalories['jantar'] ?? 0,
                  maxCalories,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayBar(String label, double value, double maxValue) {
    final barHeight = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;
    final isOver = value > (_calorieGoal * 0.3);

    return Column(
      children: [
        Container(
          width: 24,
          height: 120,
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 24,
            height: 120 * barHeight,
            decoration: BoxDecoration(
              color: isOver ? AppTheme.errorContainer : AppTheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyCaloriesChart() {
    final mealCalories = _getMealCalories();
    final cafe = mealCalories['café da manhã'] ?? 0;
    final almoco = mealCalories['almoço'] ?? 0;
    final lanche = mealCalories['lanche'] ?? 0;
    final jantar = mealCalories['jantar'] ?? 0;

    final maxY = [cafe, almoco, lanche, jantar].reduce((a, b) => a > b ? a : b);
    final chartMaxY = maxY > 0 ? (maxY * 1.2).toDouble() : 100.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
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
          Text(
            'Consumo Diário',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Calorias consumidas por refeição',
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: chartMaxY,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Café', 'Almoço', 'Lanche', 'Janta'];
                        return Text(
                          days[value.toInt()],
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeBarGroup(0, cafe),
                  _makeBarGroup(1, almoco),
                  _makeBarGroup(2, lanche),
                  _makeBarGroup(3, jantar),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppTheme.primary,
          width: 40,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
      ],
    );
  }

  Widget _buildMacrosSection() {
    final totalProtein = _getTotalProtein();
    final totalCarbs = _getTotalCarbs();
    final totalFat = _getTotalFat();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Macronutrientes',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildMacroCard(
          'Proteína',
          totalProtein,
          _proteinGoal,
          AppTheme.proteinColor,
        ),
        const SizedBox(height: 16),
        _buildMacroCard(
          'Carboidratos',
          totalCarbs,
          _carbsGoal,
          AppTheme.carbsColor,
        ),
        const SizedBox(height: 16),
        _buildMacroCard(
          'Gorduras',
          totalFat,
          _fatGoal,
          AppTheme.fatColor,
        ),
      ],
    );
  }

  Widget _buildMacroCard(
    String label,
    double value,
    double goal,
    Color color,
  ) {
    final progress = goal > 0 ? value / goal : 0.0;
    final percentage = progress > 0 ? ((progress - 1) * 100).toInt() : 0;
    final isPositive = progress >= 1;

    return Container(
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      label == 'Proteína'
                          ? Icons.restaurant
                          : label == 'Carboidratos'
                              ? Icons.bakery_dining
                              : Icons.water_drop,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${value.toInt()}g / ${goal.toInt()}g',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (percentage != 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? AppTheme.primaryContainer
                        : AppTheme.errorContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${percentage > 0 ? '+' : ''}$percentage%',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isPositive ? AppTheme.primary : AppTheme.error,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard() {
    final totalCalories = _getTotalCalories();
    final caloriePercentage =
        _calorieGoal > 0 ? (totalCalories / _calorieGoal * 100).toInt() : 0;

    String insightText;
    if (_meals.isEmpty) {
      insightText =
          'Registre sua primeira refeição para ver insights personalizados.';
    } else if (caloriePercentage < 50) {
      insightText =
          'Você consumiu apenas $caloriePercentage% da meta. Continue se alimentando ao longo do dia.';
    } else if (caloriePercentage >= 50 && caloriePercentage < 80) {
      insightText =
          'Bom progresso! Você está em $caloriePercentage% da meta calórica.';
    } else if (caloriePercentage >= 80 && caloriePercentage <= 100) {
      insightText =
          'Quase lá! Você atingiu $caloriePercentage% da meta. Cuidado para não exceder.';
    } else {
      insightText =
          'Você excedeu a meta calórica em ${caloriePercentage - 100}%. Tente ajustar as próximas refeições.';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDim],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bolt, color: AppTheme.primary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insight de Saúde',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insightText,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportProgressCsv() async {
    if (_meals.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Nenhum dado para exportar',
            style: GoogleFonts.manrope(),
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Gerando relatório...',
          style: GoogleFonts.manrope(),
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    try {
      final repo = getIt<SyncMealRepository>();
      final csv = repo.exportMealsToCsv(_meals);

      final header =
          'Relatório NutriV - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}\n\n'
          'Resumo do Dia\n'
          'Calorias Totais,${_getTotalCalories().toInt()} kcal\n'
          'Proteína Total,${_getTotalProtein().toInt()}g\n'
          'Carboidratos Total,${_getTotalCarbs().toInt()}g\n'
          'Gordura Total,${_getTotalFat().toInt()}g\n'
          'Meta Calórica,${_calorieGoal.toInt()} kcal\n\n'
          'Detalhamento por Refeição\n';

      final fullCsv = header + csv;

      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}/nutriv_progresso_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv',
      );
      await file.writeAsString(fullCsv);

      if (!mounted) return;
      // ignore: deprecated_member_use
      await Share.share(
        'Arquivo CSV exportado: ${file.path}\n\n$fullCsv',
        subject:
            'NutriV - Progresso ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao exportar: $e',
            style: GoogleFonts.manrope(),
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}
