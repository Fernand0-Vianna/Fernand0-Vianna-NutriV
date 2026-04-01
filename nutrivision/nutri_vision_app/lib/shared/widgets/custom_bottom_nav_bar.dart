import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Para alguns ícones

import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(
              icon: FontAwesomeIcons.house,
              label: 'Início',
              index: 0,
              current: navigationShell.currentIndex,
            ),
            _buildNavItem(
              icon: FontAwesomeIcons.solidClipboard,
              label: 'Diário',
              index: 1,
              current: navigationShell.currentIndex,
            ),
            // Espaço para o FAB
            const SizedBox(width: 48), // Ajuste o tamanho conforme necessário
            _buildNavItem(
              icon: FontAwesomeIcons.solidFolderOpen,
              label: 'Arquivos',
              index: 3,
              current: navigationShell.currentIndex,
            ),
            _buildNavItem(
              icon: FontAwesomeIcons.solidUser,
              label: 'Perfil',
              index: 4,
              current: navigationShell.currentIndex,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildCaptureFAB(context),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required int current,
  }) {
    final bool isSelected = index == current;
    return Expanded(
      child: InkWell(
        onTap: () => _goBranch(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FaIcon(
                icon,
                color: isSelected ? AppColors.primaryGreen : Colors.grey,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primaryGreen : Colors.grey,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // Navegar para a tela de captura (ou abrir um modal)
        // Usamos index 2 para a rota de captura, mas sem passar pelo branch diretamente
        // pois a navegação do FAB é geralmente uma ação única, não um "branch" contínuo.
        // Você pode decidir se quer que ele seja um branch ou uma rota separada.
        // Neste exemplo, vou para o branch 2 (capture).
        // navigationShell.goBranch(2);
        context.go(AppRoutes.capture); // Pode ser uma rota fora do shell também
      },
      backgroundColor: AppColors.primaryGreen,
      shape: const CircleBorder(),
      elevation: 4.0,
      child: const Icon(
        FontAwesomeIcons.camera,
        color: AppColors.textLight,
      ),
    );
  }
}