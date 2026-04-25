import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool isDarkMode;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
    this.isDarkMode = false,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lightColor = AppTheme.surfaceContainerLow;
    final darkColor = AppTheme.surfaceContainerHigh;
    final darkBaseColor = const Color(0xFF1A2E22);
    final darkShimmerColor = const Color(0xFF2D4535);

    final baseColor = widget.isDarkMode ? darkBaseColor : lightColor;
    final shimmerColor = widget.isDarkMode ? darkShimmerColor : darkColor;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                baseColor,
                shimmerColor,
                baseColor,
              ],
            ),
          ),
        );
      },
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final bool isDarkMode;

  const SkeletonCard({super.key, this.isDarkMode = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A2E22) : AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(
            height: 24,
            width: 150,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 12),
          SkeletonLoader(
            height: 16,
            width: 100,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SkeletonLoader(
                height: 32,
                width: 60,
                borderRadius: 16,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(width: 8),
              SkeletonLoader(
                height: 32,
                width: 60,
                borderRadius: 16,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(width: 8),
              SkeletonLoader(
                height: 32,
                width: 60,
                borderRadius: 16,
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SkeletonListItem extends StatelessWidget {
  final bool isDarkMode;

  const SkeletonListItem({super.key, this.isDarkMode = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A2E22) : AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SkeletonLoader(
            height: 48,
            width: 48,
            borderRadius: 12,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(height: 16, width: 120, isDarkMode: isDarkMode),
                const SizedBox(height: 8),
                SkeletonLoader(height: 12, width: 80, isDarkMode: isDarkMode),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonFoodCard extends StatelessWidget {
  final bool isDarkMode;

  const SkeletonFoodCard({super.key, this.isDarkMode = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A2E22) : AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2D4535) : AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(height: 18, width: 140, isDarkMode: isDarkMode),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SkeletonLoader(height: 24, width: 50, borderRadius: 12, isDarkMode: isDarkMode),
                    const SizedBox(width: 8),
                    SkeletonLoader(height: 24, width: 50, borderRadius: 12, isDarkMode: isDarkMode),
                    const SizedBox(width: 8),
                    SkeletonLoader(height: 24, width: 50, borderRadius: 12, isDarkMode: isDarkMode),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonMealCard extends StatelessWidget {
  final bool isDarkMode;

  const SkeletonMealCard({super.key, this.isDarkMode = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A2E22) : AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonLoader(
                height: 40,
                width: 40,
                borderRadius: 12,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(height: 16, width: 100, isDarkMode: isDarkMode),
                    const SizedBox(height: 4),
                    SkeletonLoader(height: 12, width: 60, isDarkMode: isDarkMode),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SkeletonLoader(height: 12, isDarkMode: isDarkMode),
        ],
      ),
    );
  }
}

class SkeletonMacroCard extends StatelessWidget {
  final bool isDarkMode;

  const SkeletonMacroCard({super.key, this.isDarkMode = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1A2E22) : AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonLoader(height: 12, width: 60, isDarkMode: isDarkMode),
            const SizedBox(height: 8),
            SkeletonLoader(height: 18, width: 40, isDarkMode: isDarkMode),
            const SizedBox(height: 8),
            SkeletonLoader(height: 4, isDarkMode: isDarkMode),
          ],
        ),
      ),
    );
  }
}