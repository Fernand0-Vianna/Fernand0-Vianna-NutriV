import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingTour extends StatefulWidget {
  final VoidCallback onComplete;
  
  const OnboardingTour({super.key, required this.onComplete});

  @override
  State<OnboardingTour> createState() => _OnboardingTourState();
}

class _OnboardingTourState extends State<OnboardingTour> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TourPage> _pages = [
    TourPage(
      icon: Icons.qr_code_scanner,
      title: 'Escaneie alimentos',
      description: 'Use a câmera para escanear códigos de barras ou fotografar alimentos e получите informações nutricionais instantaneamente.',
      color: AppTheme.primary,
    ),
    TourPage(
      icon: Icons.edit_note,
      title: 'Registrerefeições',
      description: 'Registre suasrefeiçõesdiáriase acompanhe suas calórias e macronutrientes de forma simples.',
      color: AppTheme.secondary,
    ),
    TourPage(
      icon: Icons.bar_chart,
      title: 'Acompanheprogresso',
      description: 'Visualizegráficos e estatísticas para entender seus hábitos alimentares e atingir suas metas.',
      color: AppTheme.tertiary,
    ),
    TourPage(
      icon: Icons.restaurant_menu,
      title: 'Descubra Receitas',
      description: 'Explore receitas saudáveise obtenha sugestões personalizadas baseado no seu perfil.',
      color: AppTheme.primary,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeTour();
    }
  }

  void _completeTour() async {
    final prefs = getIt<SharedPreferences>();
    await prefs.setBool('onboarding_tour_completed', true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeTour,
                child: Text(
                  'Pular',
                  style: GoogleFonts.manrope(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) => _buildPage(_pages[index]),
              ),
            ),
            _buildIndicators(),
            const SizedBox(height: 24),
            _buildButtons(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(TourPage page) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 64,
              color: page.color,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: GoogleFonts.manrope(
              fontSize: 16,
              color: AppTheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppTheme.primary
                : AppTheme.primary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Text(
                'Voltar',
                style: GoogleFonts.manrope(
                  color: AppTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            const SizedBox(width: 80),
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text(
              _currentPage == _pages.length - 1 ? 'Começar' : 'Próximo',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TourPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  TourPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

Future<bool> shouldShowOnboardingTour() async {
  final prefs = getIt<SharedPreferences>();
  return !(prefs.getBool('onboarding_tour_completed') ?? false);
}