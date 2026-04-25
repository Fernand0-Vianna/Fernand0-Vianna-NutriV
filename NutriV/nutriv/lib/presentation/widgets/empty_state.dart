import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

enum EmptyStateType {
  noData,
  noResults,
  error,
  loading,
  empty,
  favorites,
  meals,
  history,
  progress,
}

class EmptyState extends StatelessWidget {
  final EmptyStateType type;
  final String? title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? customIcon;

  const EmptyState({
    super.key,
    required this.type,
    this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            const SizedBox(height: 24),
            _buildTitle(),
            const SizedBox(height: 8),
            _buildSubtitle(),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              _buildActionButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;
    double size;

    if (customIcon != null) {
      icon = customIcon!;
      color = AppTheme.primary;
      size = 64;
    } else {
      switch (type) {
        case EmptyStateType.noData:
          icon = Icons.inbox_outlined;
          color = AppTheme.onSurfaceVariant;
          size = 64;
          break;
        case EmptyStateType.noResults:
          icon = Icons.search_off;
          color = AppTheme.onSurfaceVariant;
          size = 64;
          break;
        case EmptyStateType.error:
          icon = Icons.error_outline;
          color = AppTheme.error;
          size = 64;
          break;
        case EmptyStateType.loading:
          icon = Icons.hourglass_empty;
          color = AppTheme.primary;
          size = 64;
          break;
        case EmptyStateType.empty:
          icon = Icons.restaurant_outlined;
          color = AppTheme.onSurfaceVariant;
          size = 64;
          break;
        case EmptyStateType.favorites:
          icon = Icons.favorite_border;
          color = AppTheme.onSurfaceVariant;
          size = 64;
          break;
        case EmptyStateType.meals:
          icon = Icons.restaurant_menu_outlined;
          color = AppTheme.onSurfaceVariant;
          size = 64;
          break;
        case EmptyStateType.history:
          icon = Icons.history;
          color = AppTheme.onSurfaceVariant;
          size = 64;
          break;
        case EmptyStateType.progress:
          icon = Icons.trending_up;
          color = AppTheme.onSurfaceVariant;
          size = 64;
          break;
      }
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: size, color: color),
    );
  }

  Widget _buildTitle() {
    String text = title ?? _getDefaultTitle();

    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppTheme.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    String text = subtitle ?? _getDefaultSubtitle();

    return Text(
      text,
      style: GoogleFonts.manrope(
        fontSize: 14,
        color: AppTheme.onSurfaceVariant,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton(
      onPressed: onAction,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Text(
        actionLabel!,
        style: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getDefaultTitle() {
    switch (type) {
      case EmptyStateType.noData:
        return 'Nenhum dado disponível';
      case EmptyStateType.noResults:
        return 'Nenhum resultado encontrado';
      case EmptyStateType.error:
        return 'Ops! Algo deu errado';
      case EmptyStateType.loading:
        return 'Carregando...';
      case EmptyStateType.empty:
        return 'Lista vazia';
      case EmptyStateType.favorites:
        return 'Nenhum favorito ainda';
      case EmptyStateType.meals:
        return 'Nenhuma refeição registrada';
      case EmptyStateType.history:
        return 'Nenhum histórico';
      case EmptyStateType.progress:
        return 'Sem dados de progresso';
    }
  }

  String _getDefaultSubtitle() {
    switch (type) {
      case EmptyStateType.noData:
        return 'Adicione dados para começar';
      case EmptyStateType.noResults:
        return 'Tente buscar com outros termos';
      case EmptyStateType.error:
        return 'Tente novamente mais tarde';
      case EmptyStateType.loading:
        return 'Aguarde um momento';
      case EmptyStateType.empty:
        return 'Não há itens para exibir';
      case EmptyStateType.favorites:
        return 'Salve refeições frequentes para encontrá-las mais rápido';
      case EmptyStateType.meals:
        return 'Registre suas refeições para acompanhar sua alimentação';
      case EmptyStateType.history:
        return 'Seu histórico aparecerá aqui';
      case EmptyStateType.progress:
        return 'Continue usando o app para ver seu progresso';
    }
  }
}

class EmptyStateCard extends StatelessWidget {
  final EmptyStateType type;
  final String? title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateCard({
    super.key,
    required this.type,
    this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.outlineVariant,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(),
          const SizedBox(height: 16),
          _buildTitle(),
          const SizedBox(height: 8),
          _buildSubtitle(),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            _buildActionButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;

    switch (type) {
      case EmptyStateType.noData:
        icon = Icons.inbox_outlined;
        color = AppTheme.onSurfaceVariant;
        break;
      case EmptyStateType.noResults:
        icon = Icons.search_off;
        color = AppTheme.onSurfaceVariant;
        break;
      case EmptyStateType.error:
        icon = Icons.error_outline;
        color = AppTheme.error;
        break;
      case EmptyStateType.loading:
        icon = Icons.hourglass_empty;
        color = AppTheme.primary;
        break;
      case EmptyStateType.empty:
        icon = Icons.restaurant_outlined;
        color = AppTheme.onSurfaceVariant;
        break;
      case EmptyStateType.favorites:
        icon = Icons.favorite_border;
        color = AppTheme.onSurfaceVariant;
        break;
      case EmptyStateType.meals:
        icon = Icons.restaurant_menu_outlined;
        color = AppTheme.onSurfaceVariant;
        break;
      case EmptyStateType.history:
        icon = Icons.history;
        color = AppTheme.onSurfaceVariant;
        break;
      case EmptyStateType.progress:
        icon = Icons.trending_up;
        color = AppTheme.onSurfaceVariant;
        break;
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 32, color: color),
    );
  }

  Widget _buildTitle() {
    String text = title ?? _getDefaultTitle();

    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    String text = subtitle ?? _getDefaultSubtitle();

    return Text(
      text,
      style: GoogleFonts.manrope(
        fontSize: 13,
        color: AppTheme.onSurfaceVariant,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButton() {
    return OutlinedButton(
      onPressed: onAction,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primary,
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: AppTheme.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        actionLabel!,
        style: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getDefaultTitle() {
    switch (type) {
      case EmptyStateType.noData:
        return 'Nenhum dado';
      case EmptyStateType.noResults:
        return 'Sem resultados';
      case EmptyStateType.error:
        return 'Erro';
      case EmptyStateType.loading:
        return 'Carregando';
      case EmptyStateType.empty:
        return 'Vazio';
      case EmptyStateType.favorites:
        return 'Sem favoritos';
      case EmptyStateType.meals:
        return 'Sem refeições';
      case EmptyStateType.history:
        return 'Sem histórico';
      case EmptyStateType.progress:
        return 'Sem progresso';
    }
  }

  String _getDefaultSubtitle() {
    switch (type) {
      case EmptyStateType.noData:
        return 'Adicione dados';
      case EmptyStateType.noResults:
        return 'Tente buscar';
      case EmptyStateType.error:
        return 'Tente novamente';
      case EmptyStateType.loading:
        return 'Aguarde';
      case EmptyStateType.empty:
        return 'Nenhum item';
      case EmptyStateType.favorites:
        return 'Salve favoritos';
      case EmptyStateType.meals:
        return 'Registre refeições';
      case EmptyStateType.history:
        return 'Veja histórico';
      case EmptyStateType.progress:
        return 'Veja progresso';
    }
  }
}

class LoadingState extends StatelessWidget {
  final String? message;

  const LoadingState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppTheme.primary,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: AppTheme.primary,
                      ),
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          message!,
                          style: GoogleFonts.manrope(
                            color: AppTheme.onSurface,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}