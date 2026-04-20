import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
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
                AppTheme.surfaceContainerLow,
                AppTheme.surfaceContainerHigh,
                AppTheme.surfaceContainerLow,
              ],
            ),
          ),
        );
      },
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(height: 24, width: 150),
          const SizedBox(height: 12),
          const SkeletonLoader(height: 16, width: 100),
          const SizedBox(height: 16),
          Row(
            children: [
              const SkeletonLoader(height: 32, width: 60, borderRadius: 16),
              const SizedBox(width: 8),
              const SkeletonLoader(height: 32, width: 60, borderRadius: 16),
              const SizedBox(width: 8),
              const SkeletonLoader(height: 32, width: 60, borderRadius: 16),
            ],
          ),
        ],
      ),
    );
  }
}

class SkeletonListItem extends StatelessWidget {
  const SkeletonListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const SkeletonLoader(
            height: 48,
            width: 48,
            borderRadius: 12,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLoader(height: 16, width: 120),
                SizedBox(height: 8),
                SkeletonLoader(height: 12, width: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonFoodCard extends StatelessWidget {
  const SkeletonFoodCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLoader(height: 18, width: 140),
                SizedBox(height: 12),
                Row(
                  children: [
                    SkeletonLoader(height: 24, width: 50, borderRadius: 12),
                    SizedBox(width: 8),
                    SkeletonLoader(height: 24, width: 50, borderRadius: 12),
                    SizedBox(width: 8),
                    SkeletonLoader(height: 24, width: 50, borderRadius: 12),
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