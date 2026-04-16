import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  0,
                  Icons.home_outlined,
                  Icons.home,
                  'Início',
                  context,
                ),
                _buildNavItem(
                  1,
                  Icons.menu_book_outlined,
                  Icons.menu_book,
                  'Diário',
                  context,
                ),
                _buildNavItem(
                  2,
                  Icons.add_circle_outline,
                  Icons.add_circle,
                  'Add',
                  context,
                ),
                _buildNavItem(
                  3,
                  Icons.search_outlined,
                  Icons.search,
                  'Busca',
                  context,
                ),
                _buildNavItem(
                  4,
                  Icons.person_outline,
                  Icons.person,
                  'Perfil',
                  context,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
    BuildContext context,
  ) {
    final isSelected = _calculateSelectedIndex(context) == index;
    final isCenter = index == 2;

    if (isCenter) {
      return GestureDetector(
        onTap: () => _onItemTapped(index, context),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryDim],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.add, color: AppTheme.onPrimary, size: 28),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _onItemTapped(index, context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? AppTheme.primary
                  : AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location == '/') return 0;
    if (location == '/diary') return 1;
    if (location == '/scanner') return 2;
    if (location == '/profile') return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/diary');
        break;
      case 2:
        context.go('/scanner');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}
