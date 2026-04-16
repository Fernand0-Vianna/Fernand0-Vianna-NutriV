import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_state.dart';
import '../../bloc/user/user_event.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/theme/app_theme.dart';
import 'progress_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoaded) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(context, state),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildGoalsCard(context, state),
                        const SizedBox(height: 16),
                        _buildStatsCard(context, state),
                        const SizedBox(height: 16),
                        _buildSettingsCard(context),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserLoaded state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, Color(0xFF00E676)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                state.user.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state.user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getGoalText(state.user.goal),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _showEditProfileDialog(context, state),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, size: 18, color: AppTheme.primary),
                  SizedBox(width: 8),
                  Text(
                    'Editar Perfil',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGoalsCard(BuildContext context, UserLoaded state) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flag, color: AppTheme.primary),
              SizedBox(width: 8),
              Text(
                'Metas Diárias',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildGoalRow(
            'Calorias',
            state.user.calorieGoal,
            'kcal',
            AppTheme.primary,
          ),
          const SizedBox(height: 12),
          _buildGoalRow(
            'Proteína',
            state.user.proteinGoal,
            'g',
            const Color(0xFF2196F3),
          ),
          const SizedBox(height: 12),
          _buildGoalRow(
            'Carboidratos',
            state.user.carbsGoal,
            'g',
            const Color(0xFFFF9800),
          ),
          const SizedBox(height: 12),
          _buildGoalRow(
            'Gordura',
            state.user.fatGoal,
            'g',
            const Color(0xFFE91E63),
          ),
          const SizedBox(height: 12),
          _buildGoalRow('Água', state.user.waterGoal, 'ml', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildGoalRow(String label, double value, String unit, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
        Text(
          '${value.toInt()} $unit',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatsCard(BuildContext context, UserLoaded state) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: AppTheme.primary),
              SizedBox(width: 8),
              Text(
                'Estatísticas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Peso', '${state.user.weight} kg'),
              ),
              Expanded(
                child: _buildStatItem(
                  'Altura',
                  '${state.user.height.toInt()} cm',
                ),
              ),
              Expanded(
                child: _buildStatItem('Idade', '${state.user.age} anos'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Atividade',
                  NutritionUtils.getActivityLevel(state.user.activityLevel),
                ),
              ),
              const Expanded(child: SizedBox()),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
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
          _buildSettingsItem(
            Icons.trending_up,
            'Ver Progresso',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProgressPage()),
            ),
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            Icons.notifications_outlined,
            'Notificações',
            () {},
          ),
          const Divider(height: 1),
          _buildSettingsItem(Icons.privacy_tip_outlined, 'Privacidade', () {}),
          const Divider(height: 1),
          _buildSettingsItem(Icons.help_outline, 'Ajuda', () {}),
          const Divider(height: 1),
          _buildSettingsItem(Icons.info_outline, 'Sobre', () {}),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  String _getGoalText(String goal) {
    switch (goal) {
      case 'lose':
        return 'Perder peso';
      case 'gain':
        return 'Ganhar peso';
      default:
        return 'Manter peso';
    }
  }

  void _showEditProfileDialog(BuildContext context, UserLoaded state) {
    final nameController = TextEditingController(text: state.user.name);
    final weightController = TextEditingController(
      text: state.user.weight.toString(),
    );
    final heightController = TextEditingController(
      text: state.user.height.toString(),
    );
    final ageController = TextEditingController(
      text: state.user.age.toString(),
    );
    String selectedGoal = state.user.goal;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar Perfil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Peso (kg)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Altura (cm)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Idade'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedGoal,
                  decoration: const InputDecoration(labelText: 'Objetivo'),
                  items: const [
                    DropdownMenuItem(value: 'lose', child: Text('Perder peso')),
                    DropdownMenuItem(
                      value: 'maintain',
                      child: Text('Manter peso'),
                    ),
                    DropdownMenuItem(value: 'gain', child: Text('Ganhar peso')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedGoal = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final weight = double.tryParse(weightController.text);
                final height = double.tryParse(heightController.text);
                final age = int.tryParse(ageController.text);

                if (nameController.text.isNotEmpty &&
                    weight != null &&
                    height != null &&
                    age != null) {
                  final updatedUser = state.user.copyWith(
                    name: nameController.text,
                    weight: weight,
                    height: height,
                    age: age,
                    goal: selectedGoal,
                  );
                  context.read<UserBloc>().add(UpdateUser(updatedUser));
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
