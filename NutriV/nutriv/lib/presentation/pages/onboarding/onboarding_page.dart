import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../../domain/entities/user.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/injection.dart';
import '../../../data/datasources/auth_service.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();

  bool _isMale = true;
  int _activityLevel = 1;
  String _goal = 'maintain';

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.surface, AppTheme.surfaceContainerLow],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        _buildHeader(),
                        const SizedBox(height: 32),
                        _buildProfileCard(),
                        const SizedBox(height: 20),
                        _buildGenderCard(),
                        const SizedBox(height: 20),
                        _buildActivityCard(),
                        const SizedBox(height: 20),
                        _buildGoalCard(),
                        const SizedBox(height: 32),
                        _buildStartButton(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.restaurant_menu,
            size: 40,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'NutriV',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Seu corpo, sua meta.',
          style: GoogleFonts.manrope(
            fontSize: 16,
            color: AppTheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
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
            'Seu Perfil',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nome',
              hintText: 'Seu nome',
              filled: true,
              fillColor: AppTheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: AppTheme.primary.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
            ),
            validator: (v) => Validators.validateRequired(v, 'Nome'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Peso (kg)',
                    hintText: '70',
                    filled: true,
                    fillColor: AppTheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) =>
                      Validators.validatePositiveNumber(v, 'Peso'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Altura (cm)',
                    hintText: '170',
                    filled: true,
                    fillColor: AppTheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) =>
                      Validators.validatePositiveNumber(v, 'Altura'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Idade',
              hintText: '25',
              filled: true,
              fillColor: AppTheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (v) => Validators.validatePositiveNumber(v, 'Idade'),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderCard() {
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
            'Gênero',
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
                child: _buildGenderOption(
                  'Masculino',
                  Icons.male,
                  _isMale,
                  () => setState(() => _isMale = true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGenderOption(
                  'Feminino',
                  Icons.female,
                  !_isMale,
                  () => setState(() => _isMale = false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(
    String label,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? AppTheme.onPrimary : AppTheme.onSurfaceVariant,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.manrope(
                color: selected
                    ? AppTheme.onPrimary
                    : AppTheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard() {
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
            'Nível de Atividade',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _activityLevel,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: List.generate(5, (i) {
                  return DropdownMenuItem(
                    value: i,
                    child: Text(
                      NutritionUtils.getActivityLevel(i),
                      style: GoogleFonts.manrope(color: AppTheme.onSurface),
                    ),
                  );
                }),
                onChanged: (v) {
                  if (v != null) setState(() => _activityLevel = v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard() {
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
            'Seu Objetivo',
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
                child: _buildGoalOption('Perder', 'lose', Icons.trending_down),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGoalOption('Manter', 'maintain', Icons.remove),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGoalOption('Ganhar', 'gain', Icons.trending_up),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalOption(String label, String value, IconData icon) {
    final selected = _goal == value;
    return GestureDetector(
      onTap: () => setState(() => _goal = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? AppTheme.onPrimary : AppTheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.manrope(
                color: selected
                    ? AppTheme.onPrimary
                    : AppTheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _signInWithGoogle,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.surfaceContainerLow,
              foregroundColor: AppTheme.onSurface,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.g_mobiledata, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Continuar com Google',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 0,
            ),
            child: Text(
              'Começar',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _signInWithGoogle() async {
    final authService = getIt<AuthService>();
    final user = await authService.signInWithGoogle();

    if (user != null && mounted) {
      context.read<UserBloc>().add(SaveUser(user));
      context.go('/');
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final weight = double.parse(_weightController.text);
      final height = double.parse(_heightController.text);
      final age = int.parse(_ageController.text);

      final bmr = NutritionUtils.calculateBMR(
        weight: weight,
        height: height,
        age: age,
        isMale: _isMale,
      );

      final tdee = NutritionUtils.calculateTDEE(bmr, _activityLevel);
      final goalCalories = NutritionUtils.calculateGoalCalories(tdee, _goal);

      final proteinGoal = _goal == 'lose' ? weight * 2.0 : weight * 1.6;
      final carbsGoal = goalCalories * 0.4 / 4;
      final fatGoal = goalCalories * 0.3 / 9;

      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        weight: weight,
        height: height,
        age: age,
        isMale: _isMale,
        activityLevel: _activityLevel,
        goal: _goal,
        calorieGoal: goalCalories,
        proteinGoal: proteinGoal,
        carbsGoal: carbsGoal,
        fatGoal: fatGoal,
        waterGoal: AppConstants.defaultWaterGoal,
        createdAt: DateTime.now(),
      );

      context.read<UserBloc>().add(SaveUser(user));
      context.go('/');
    }
  }
}
