import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../../domain/entities/user.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/constants/app_constants.dart';

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Bem-vindo ao NutriV',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vamos configurar seu perfil',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _buildTextField(
                  controller: _nameController,
                  label: 'Nome',
                  hint: 'Seu nome',
                  validator: (v) => Validators.validateRequired(v, 'Nome'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _weightController,
                        label: 'Peso (kg)',
                        hint: '70',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            Validators.validatePositiveNumber(v, 'Peso'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _heightController,
                        label: 'Altura (cm)',
                        hint: '170',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            Validators.validatePositiveNumber(v, 'Altura'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _ageController,
                  label: 'Idade',
                  hint: '25',
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      Validators.validatePositiveNumber(v, 'Idade'),
                ),
                const SizedBox(height: 24),
                Text('Gênero', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildGenderButton('Masculino', _isMale, () {
                        setState(() => _isMale = true);
                      }),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildGenderButton('Feminino', !_isMale, () {
                        setState(() => _isMale = false);
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Nível de atividade',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _activityLevel,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: List.generate(5, (i) {
                    return DropdownMenuItem(
                      value: i,
                      child: Text(NutritionUtils.getActivityLevel(i)),
                    );
                  }),
                  onChanged: (v) {
                    if (v != null) setState(() => _activityLevel = v);
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Seu objetivo',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildGoalButton(
                        'Perder',
                        'lose',
                        Icons.trending_down,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGoalButton(
                        'Manter',
                        'maintain',
                        Icons.remove,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGoalButton(
                        'Ganhar',
                        'gain',
                        Icons.trending_up,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('Começar'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: validator,
    );
  }

  Widget _buildGenderButton(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalButton(String label, String value, IconData icon) {
    final selected = _goal == value;
    return InkWell(
      onTap: () => setState(() => _goal = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.grey[700]),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
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
