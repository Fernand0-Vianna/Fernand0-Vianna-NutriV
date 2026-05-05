import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/theme_notifier.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/datasources/auth_service.dart';
import '../../../data/repositories/sync_meal_repository.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_state.dart';
import '../../bloc/user/user_event.dart';
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
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildProfileHeader(context, state)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      children: [
                        _buildStatsBar(state),
                        const SizedBox(height: 24),
                        _buildGoalsCard(context, state),
                        const SizedBox(height: 24),
                        _buildStatsCard(context, state),
                        const SizedBox(height: 24),
                        _buildSettingsCard(context),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserLoaded state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDim],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Perfil',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onPrimary,
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer.withValues(alpha:  0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppTheme.onPrimary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.onPrimary, width: 3),
            ),
            child: Center(
              child: Text(
                state.user.name.isNotEmpty
                    ? state.user.name[0].toUpperCase()
                    : 'U',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state.user.name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.onPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer.withValues(alpha:  0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getGoalText(state.user.goal),
              style: GoogleFonts.manrope(
                color: AppTheme.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _showEditProfileDialog(context, state),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.onPrimary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit, size: 18, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Editar Perfil',
                    style: GoogleFonts.manrope(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(UserLoaded state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('${state.user.weight.toInt()}', 'kg', 'Peso'),
          Container(width: 1, height: 40, color: AppTheme.outlineVariant),
          _buildStatItem('${state.user.height.toInt()}', 'cm', 'Altura'),
          Container(width: 1, height: 40, color: AppTheme.outlineVariant),
          _buildStatItem('${state.user.age}', 'anos', 'Idade'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String unit, String label) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onSurface,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsCard(BuildContext context, UserLoaded state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flag,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Metas Diárias',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildGoalRow(
            'Calorias',
            state.user.calorieGoal,
            'kcal',
            AppTheme.primary,
          ),
          const SizedBox(height: 16),
          _buildGoalRow(
            'Proteína',
            state.user.proteinGoal,
            'g',
            const Color(0xFF2196F3),
          ),
          const SizedBox(height: 16),
          _buildGoalRow(
            'Carboidratos',
            state.user.carbsGoal,
            'g',
            const Color(0xFFFF9800),
          ),
          const SizedBox(height: 16),
          _buildGoalRow(
            'Gordura',
            state.user.fatGoal,
            'g',
            const Color(0xFFE91E63),
          ),
          const SizedBox(height: 16),
          _buildGoalRow('Água', state.user.waterGoal / 1000, 'L', Colors.blue),
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
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.manrope(
                color: AppTheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          '${value.toInt()} $unit',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(BuildContext context, UserLoaded state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.analytics,
                      color: AppTheme.secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Detalhes',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProgressPage()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Ver Progresso',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            'Atividade',
            NutritionUtils.getActivityLevel(state.user.activityLevel),
            Icons.directions_run,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Objetivo',
            _getGoalText(state.user.goal),
            Icons.flag,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.onSurfaceVariant, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            Icons.person_outline,
            'Meu Perfil',
            () => _showProfileInfo(context),
          ),
          _buildSettingsItem(
            Icons.notifications_outlined,
            'Notificações',
            () => _showNotificationsSettings(context),
          ),
          _buildSettingsItem(
            Icons.favorite_outline,
            'Favoritos',
            () => _showFavorites(context),
          ),
          _buildSettingsItem(
            Icons.settings_outlined,
            'Configurações',
            () => _showAppSettings(context),
          ),
          _buildSettingsItem(
            Icons.download,
            'Exportar Dados',
            () => _showExportOptions(context),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            color: AppTheme.errorContainer.withValues(alpha:  0.1),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.errorContainer.withValues(alpha:  0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.logout,
                  color: AppTheme.error,
                  size: 20,
                ),
              ),
              title: Text(
                'Sair',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.error,
                ),
              ),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Sair'),
                    content: const Text(
                      'Tem certeza que deseja sair? Você precisará fazer login novamente para acessar seus dados.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.manrope(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(
                          'Sair',
                          style: GoogleFonts.manrope(
                            color: AppTheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  try {
                    await getIt<AuthService>().signOut();
                  } catch (_) {}
                  if (context.mounted) {
                    context.read<UserBloc>().add(DeleteUser());
                    context.go('/login');
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileInfo(BuildContext context) {
    final userState = context.read<UserBloc>().state;
    if (userState is! UserLoaded) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Informações do Perfil',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _infoRow('Nome', userState.user.name),
            _infoRow('E-mail', userState.user.email ?? 'Não cadastrado'),
            _infoRow('Peso', '${userState.user.weight} kg'),
            _infoRow('Altura', '${userState.user.height} cm'),
            _infoRow('Idade', '${userState.user.age} anos'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(color: AppTheme.onSurfaceVariant),
          ),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationsSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          bool mealReminders = true;
          bool waterReminders = true;
          bool goalAlerts = true;
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Notificações',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                _switchTile(
                  'Lembrete de Refeições',
                  mealReminders,
                  (v) => setState(() => mealReminders = v),
                ),
                _switchTile(
                  'Lembrete de Água',
                  waterReminders,
                  (v) => setState(() => waterReminders = v),
                ),
                _switchTile(
                  'Alertas de Meta',
                  goalAlerts,
                  (v) => setState(() => goalAlerts = v),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Configurações salvas!',
                            style: GoogleFonts.manrope(),
                          ),
                          backgroundColor: AppTheme.primary,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Salvar',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _switchTile(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.manrope(color: AppTheme.onSurface)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  void _showFavorites(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Alimentos Favoritos',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: AppTheme.onSurfaceVariant.withValues(alpha:  0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum favorito ainda',
                      style: GoogleFonts.manrope(
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Adicione alimentos aos favoritos\npara encontrá-los mais rápido',
                      style: GoogleFonts.manrope(
                        color: AppTheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppSettings(BuildContext context) {
    final themeNotifier = getIt<ThemeNotifier>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ListenableBuilder(
        listenable: themeNotifier,
        builder: (ctx, _) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Configurações',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(
                    Icons.dark_mode_outlined,
                    color: AppTheme.primary,
                  ),
                  title: Text(
                    'Tema Escuro',
                    style: GoogleFonts.manrope(color: AppTheme.onSurface),
                  ),
                  trailing: Switch(
                    value: themeNotifier.isDarkMode,
                    onChanged: (v) {
                      themeNotifier.setThemeMode(
                        v ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                    activeThumbColor: AppTheme.primary,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.language, color: AppTheme.primary),
                  title: Text(
                    'Idioma',
                    style: GoogleFonts.manrope(color: AppTheme.onSurface),
                  ),
                  trailing: Text(
                    'Português',
                    style:
                        GoogleFonts.manrope(color: AppTheme.onSurfaceVariant),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading:
                      const Icon(Icons.info_outline, color: AppTheme.primary),
                  title: Text(
                    'Sobre',
                    style: GoogleFonts.manrope(color: AppTheme.onSurface),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppTheme.onSurfaceVariant,
                  ),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'NutriV',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2026 NutriV',
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Exportar Dados',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading:
                  const Icon(Icons.restaurant_menu, color: AppTheme.primary),
              title: Text('Diário Alimentar',
                  style: GoogleFonts.manrope(color: AppTheme.onSurface)),
              subtitle: Text('CSV das refeições',
                  style: GoogleFonts.manrope(color: AppTheme.onSurfaceVariant)),
              onTap: () {
                Navigator.pop(ctx);
                _exportDiary();
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.monitor_weight, color: AppTheme.primary),
              title: Text(' Histórico de Peso',
                  style: GoogleFonts.manrope(color: AppTheme.onSurface)),
              subtitle: Text('CSV do peso',
                  style: GoogleFonts.manrope(color: AppTheme.onSurfaceVariant)),
              onTap: () {
                Navigator.pop(ctx);
                _exportWeight();
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _exportDiary() async {
    try {
      final meals = await getIt<SyncMealRepository>().getAllMeals();
      final csv = getIt<SyncMealRepository>().exportMealsToCsv(meals);
      debugPrint('CSV gerado: ${csv.substring(0, csv.length > 100 ? 100 : csv.length)}...');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${meals.length} refeições exportadas'),
          backgroundColor: AppTheme.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao exportar dados. Tente novamente.'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _exportWeight() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Em desenvolvimento'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    String? badge,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.w500,
          color: AppTheme.onSurface,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onError,
                ),
              ),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppTheme.outlineVariant),
        ],
      ),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Editar Perfil',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Nome',
                            filled: true,
                            fillColor: AppTheme.surfaceContainerLow,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: weightController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Peso (kg)',
                                  filled: true,
                                  fillColor: AppTheme.surfaceContainerLow,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: heightController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Altura (cm)',
                                  filled: true,
                                  fillColor: AppTheme.surfaceContainerLow,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: ageController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Idade',
                            filled: true,
                            fillColor: AppTheme.surfaceContainerLow,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Objetivo',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildGoalChip(
                              'Perder',
                              'lose',
                              selectedGoal,
                              (v) => setState(() => selectedGoal = v),
                            ),
                            const SizedBox(width: 12),
                            _buildGoalChip(
                              'Manter',
                              'maintain',
                              selectedGoal,
                              (v) => setState(() => selectedGoal = v),
                            ),
                            const SizedBox(width: 12),
                            _buildGoalChip(
                              'Ganhar',
                              'gain',
                              selectedGoal,
                              (v) => setState(() => selectedGoal = v),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Salvar',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
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

  Widget _buildGoalChip(
    String label,
    String value,
    String selected,
    Function(String) onSelect,
  ) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            color: isSelected ? AppTheme.onPrimary : AppTheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
