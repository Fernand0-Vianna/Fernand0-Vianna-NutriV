import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration duration;
  final double scaleValue;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool isOutlined;
  final bool isDisabled;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.duration = const Duration(milliseconds: 100),
    this.scaleValue = 0.95,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.isOutlined = false,
    this.isDisabled = false,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleValue).animate(
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
    return GestureDetector(
      onTapDown: widget.isDisabled
          ? null
          : (_) {
              _controller.forward();
              HapticFeedback.lightImpact();
            },
      onTapUp: widget.isDisabled
          ? null
          : (_) {
              _controller.reverse();
              widget.onPressed?.call();
            },
      onTapCancel: widget.isDisabled ? null : () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.isOutlined
            ? OutlinedButton(
                onPressed: widget.isDisabled ? () {} : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      widget.foregroundColor ?? AppTheme.primary,
                  side: BorderSide(
                    color: widget.foregroundColor ?? AppTheme.primary,
                  ),
                  padding: widget.padding,
                  shape: RoundedRectangleBorder(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(9999),
                  ),
                ),
                child: widget.child,
              )
            : ElevatedButton(
                onPressed: widget.isDisabled ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      widget.backgroundColor ?? AppTheme.primary,
                  foregroundColor:
                      widget.foregroundColor ?? AppTheme.onPrimary,
                  padding: widget.padding,
                  shape: RoundedRectangleBorder(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(9999),
                  ),
                ),
                child: widget.child,
              ),
      ),
    );
  }
}

class PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final double elevation;

  const PressableCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.elevation = 0,
  });

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 0, end: 2).animate(
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
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: widget.padding ?? const EdgeInsets.all(16),
          margin: widget.margin,
          decoration: BoxDecoration(
            color: widget.color ?? AppTheme.surfaceContainerLowest,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04 + (_elevationAnimation.value * 0.02)),
                blurRadius: 10 + _elevationAnimation.value,
                offset: Offset(0, 4 + _elevationAnimation.value),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class IconButtonAnimated extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final BorderRadius? borderRadius;
  final String? tooltip;

  const IconButtonAnimated({
    super.key,
    required this.icon,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.borderRadius,
    this.tooltip,
  });

  @override
  State<IconButtonAnimated> createState() => _IconButtonAnimatedState();
}

class _IconButtonAnimatedState extends State<IconButtonAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
    final button = GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppTheme.surfaceContainerLow,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          ),
          child: Icon(
            widget.icon,
            color: widget.iconColor ?? AppTheme.primary,
            size: widget.size * 0.5,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

class FloatingActionButtonAnimated extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? label;
  final bool extended;

  const FloatingActionButtonAnimated({
    super.key,
    required this.icon,
    this.onTap,
    this.label,
    this.extended = false,
  });

  @override
  State<FloatingActionButtonAnimated> createState() =>
      _FloatingActionButtonAnimatedState();
}

class _FloatingActionButtonAnimatedState
    extends State<FloatingActionButtonAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
    final fab = GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        HapticFeedback.mediumImpact();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.extended && widget.label != null
            ? FloatingActionButton.extended(
                onPressed: () {},
                backgroundColor: AppTheme.primary,
                icon: Icon(widget.icon, color: AppTheme.onPrimary),
                label: Text(
                  widget.label!,
                  style: GoogleFonts.manrope(
                    color: AppTheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : FloatingActionButton(
                onPressed: () {},
                backgroundColor: AppTheme.primary,
                child: Icon(widget.icon, color: AppTheme.onPrimary),
              ),
      ),
    );

    return fab;
  }
}

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool showShadow;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              boxShadow: showShadow
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, color: iconColor ?? AppTheme.primary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class ChipButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? selectedColor;

  const ChipButton({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor ?? AppTheme.primary
              : AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? (selectedColor ?? AppTheme.primary).withValues(alpha: 0.2)
                  : Colors.transparent,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppTheme.onPrimary : AppTheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: GoogleFonts.manrope(
                color:
                    isSelected ? AppTheme.onPrimary : AppTheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ToggleChipButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool>? onChanged;
  final IconData? icon;

  const ToggleChipButton({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged?.call(!isSelected);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : AppTheme.outlineVariant,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppTheme.onPrimary : AppTheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color:
                    isSelected ? AppTheme.onPrimary : AppTheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}