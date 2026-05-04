import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/meal/meal_bloc.dart';
import '../../bloc/meal/meal_event.dart';
import '../../bloc/meal/meal_state.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_state.dart';
import '../../bloc/water/water_bloc.dart';
import '../../bloc/water/water_event.dart';
import '../../widgets/meal_card.dart';
import '../../widgets/water_tracker_widget.dart';
import '../../widgets/skeleton_loader.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_animations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _caloriesAnimationController;

  @override
  void initState() {
    super.initState();
    context.read<MealBloc>().add(LoadMeals(DateTime.now()));
    _caloriesAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _caloriesAnimationController.forward();
  }

  @override
  void dispose() {
    _caloriesAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          if (userState is UserLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<MealBloc>().add(LoadMeals(DateTime.now()));
                context.read<WaterBloc>().add(LoadWaterIntake(DateTime.now()));
                await Future.delayed(const Duration(milliseconds: 500));
              },
              color: AppTheme.primary,
              backgroundColor: AppTheme.surfaceContainerLowest,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeIn(child: _buildHeader(userState.user.name)),
                          const SizedBox(height: 24),
                          FadeIn(
                            delay: const Duration(milliseconds: 100),
                            child: _buildHeroCard(userState),
                          ),
                          const SizedBox(height: 24),
                          FadeIn(
                            delay: const Duration(milliseconds: 200),
                            child: _buildQuickActions(),
                          ),
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
                          FadeIn(
                            delay: const Duration(milliseconds: 300),
                            child: _buildMacrosSection(userState),
                          ),
                          const SizedBox(height: 24),
                          FadeIn(
                            delay: const Duration(milliseconds: 400),
                            child: _buildWaterSection(),
                          ),
                          const SizedBox(height: 24),
                          FadeIn(
                            delay: const Duration(milliseconds: 500),
                            child: _buildMealsSection(),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return _buildLoadingState();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(height: 16, width: 80),
                  const SizedBox(height: 8),
                  SkeletonLoader(height: 32, width: 150),
                ],
              ),
              SkeletonLoader(height: 44, width: 44, borderRadius: 22),
            ],
          ),
          const SizedBox(height: 24),
          SkeletonLoader(height: 200, borderRadius: 32),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 0; i < 3; i++)
                SkeletonLoader(height: 80, width: 80, borderRadius: 16),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              for (int i = 0; i < 3; i++) ...[
                Expanded(child: SkeletonLoader(height: 100, borderRadius: 20)),
                if (i < 2) const SizedBox(width: 12),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String name) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Bom dia';
    } else if (hour < 18) {
      greeting = 'Boa tarde';
    } else {
      greeting = 'Boa noite';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: AppTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.go('/profile'),
          child: Semantics(
            label: 'Abrir perfil do usuário',
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDim],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha:  0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: AppTheme.onPrimary,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(UserLoaded userState) {
    return BlocBuilder<MealBloc, MealState>(
      builder: (context, mealState) {
        double consumed = 0;
        double goal = userState.user.calorieGoal;

        if (mealState is MealLoaded) {
          consumed = mealState.totalCalories;
        }

        final remaining = (goal - consumed).clamp(0, goal);
        final progress = goal > 0 ? consumed / goal : 0.0;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryDim],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha:  0.25),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _caloriesAnimationController,
                builder: (context, child) {
                  return SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: progress.clamp(0, 1) *
                              _caloriesAnimationController.value,
                          strokeWidth: 10,
                          backgroundColor:
                              AppTheme.onPrimary.withValues(alpha:  0.15),
                          valueColor:
                              const AlwaysStoppedAnimation(AppTheme.onPrimary),
                          strokeCap: StrokeCap.round,
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                consumed.toInt().toString(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.onPrimary,
                                ),
                              ),
                              Text(
                                'kcal',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color:
                                      AppTheme.onPrimary.withValues(alpha:  0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meta Diária',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: AppTheme.onPrimary.withValues(alpha:  0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${goal.toInt()} kcal',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.onPrimary.withValues(alpha:  0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${remaining.toInt()} restantes',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildQuickActionButton(
          icon: Icons.camera_alt_outlined,
          label: 'Scan',
          onTap: () => context.go('/scanner'),
        ),
        _buildQuickActionButton(
          icon: Icons.bar_chart_rounded,
          label: 'Stats',
          onTap: () => context.go('/progress'),
        ),
        _buildQuickActionButton(
          icon: Icons.restaurant_menu,
          label: 'Receitas',
          onTap: () => context.go('/recipes'),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: 'Ir para $label',
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:  0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: AppTheme.primary, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
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
            Text(
              'Macronutrientes',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMacroCard(
                    'Proteína',
                    protein,
                    proteinGoal,
                    AppTheme.proteinColor,
                    Icons.egg_alt_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMacroCard(
                    'Carboidratos',
                    carbs,
                    carbsGoal,
                    AppTheme.carbsColor,
                    Icons.grain_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMacroCard(
                    'Gorduras',
                    fat,
                    fatGoal,
                    AppTheme.fatColor,
                    Icons.opacity_outlined,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMacroCard(
    String label,
    double value,
    double goal,
    Color color,
    IconData icon,
  ) {
    final progress = goal > 0 ? value / goal : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: AppTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${value.toInt()}g',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              backgroundColor: color.withValues(alpha:  0.15),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 5,
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
            Text(
              'Refeições de hoje',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/diary'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(
                'Ver mais',
                style: GoogleFonts.manrope(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<MealBloc, MealState>(
          builder: (context, state) {
            if (state is MealLoaded) {
              if (state.meals.isEmpty) {
                return _buildEmptyMealsState();
              }
              return Column(
                children: state.meals.take(3).map((meal) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MealCard(meal: meal),
                  );
                }).toList(),
              );
            }
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyMealsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outline.withValues(alpha:  0.5)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryContainer,
                  AppTheme.surfaceContainerLow
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_outlined,
              size: 32,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma refeição hoje',
            style: GoogleFonts.manrope(
              fontSize: 16,
              color: AppTheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.go('/scanner'),
            icon: const Icon(Icons.add, size: 20),
            label: Text(
              'Adicionar',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
