import 'package:flutter/material.dart';

class PineappleLogoV2 extends StatelessWidget {
  final double size;
  final Color fruitColor;
  final Color crownColor;
  final Color lensColor;

  const PineappleLogoV2({
    super.key,
    this.size = 120,
    this.fruitColor = const Color(0xFFFFB800),
    this.crownColor = const Color(0xFF006A35),
    this.lensColor = const Color(0xFF1a1a1a),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PineappleLogoV2Painter(
          fruitColor: fruitColor,
          crownColor: crownColor,
          lensColor: lensColor,
        ),
      ),
    );
  }
}

class _PineappleLogoV2Painter extends CustomPainter {
  final Color fruitColor;
  final Color crownColor;
  final Color lensColor;

  _PineappleLogoV2Painter({
    required this.fruitColor,
    required this.crownColor,
    required this.lensColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final fruitRadius = size.width * 0.32;

    _drawShadow(canvas, center, fruitRadius * 2.2);
    _drawCrown(canvas, center, size.width * 0.42);
    _drawFruitBody(canvas, center, fruitRadius);
    _drawScales(canvas, center, fruitRadius);
    _drawCameraLensV2(canvas, center, size.width * 0.20);
  }

  void _drawShadow(Canvas canvas, Offset center, double radius) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(2, radius * 0.3),
        width: radius * 1.8,
        height: radius * 2.0,
      ),
      shadowPaint,
    );
  }

  void _drawCrown(Canvas canvas, Offset center, double width) {
    final paint = Paint()
      ..color = crownColor
      ..style = PaintingStyle.fill;

    final baseY = center.dy - width * 0.35;

    final List<Offset> leafPoints = [
      Offset(center.dx - width * 0.4, baseY),
      Offset(center.dx - width * 0.25, baseY - width * 0.6),
      Offset(center.dx - width * 0.35, baseY - width * 0.55),
      Offset(center.dx - width * 0.15, baseY - width * 0.7),
      Offset(center.dx - width * 0.2, baseY - width * 0.65),
      Offset(center.dx - width * 0.05, baseY - width * 0.75),
      Offset(center.dx - width * 0.1, baseY - width * 0.7),
      Offset(center.dx, baseY - width * 0.78),
      Offset(center.dx, baseY - width * 0.72),
      Offset(center.dx + width * 0.05, baseY - width * 0.75),
      Offset(center.dx + width * 0.1, baseY - width * 0.7),
      Offset(center.dx + width * 0.05, baseY - width * 0.75),
      Offset(center.dx + width * 0.15, baseY - width * 0.7),
      Offset(center.dx + width * 0.2, baseY - width * 0.65),
      Offset(center.dx + width * 0.25, baseY - width * 0.7),
      Offset(center.dx + width * 0.35, baseY - width * 0.55),
      Offset(center.dx + width * 0.4, baseY),
    ];

    final path = Path();
    path.moveTo(leafPoints[0].dx, leafPoints[0].dy);

    for (int i = 0; i < leafPoints.length - 1; i += 2) {
      if (i + 1 < leafPoints.length) {
        path.quadraticBezierTo(
          leafPoints[i].dx,
          leafPoints[i].dy - width * 0.2,
          leafPoints[i + 1].dx,
          leafPoints[i + 1].dy,
        );
      }
    }

    for (int i = leafPoints.length - 1; i >= 0; i -= 2) {
      if (i > 0) {
        path.quadraticBezierTo(
          leafPoints[i].dx,
          leafPoints[i].dy,
          leafPoints[i - 1].dx,
          leafPoints[i - 1].dy,
        );
      }
    }

    path.close();
    canvas.drawPath(path, paint);

    for (int i = 0; i < leafPoints.length; i += 2) {
      if (i + 1 < leafPoints.length) {
        final leafPath = Path();
        final start = leafPoints[i];
        final mid = Offset(
          (leafPoints[i].dx + leafPoints[i + 1].dx) / 2,
          leafPoints[i].dy - width * 0.1,
        );
        final end = leafPoints[i + 1];

        leafPath.moveTo(start.dx, start.dy);
        leafPath.quadraticBezierTo(mid.dx, mid.dy, end.dx, end.dy);
        leafPath.quadraticBezierTo(mid.dx, mid.dy - width * 0.05, start.dx, start.dy);

        canvas.drawPath(leafPath, paint);
      }
    }
  }

  void _drawFruitBody(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = fruitColor
      ..style = PaintingStyle.fill;

    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      colors: [
        const Color(0xFFFFD54F),
        fruitColor,
        const Color(0xFFFFA000),
      ],
    );

    final rect = Rect.fromCenter(
      center: center + Offset(0, radius * 0.15),
      width: radius * 2,
      height: radius * 2.2,
    );

    final gradientPaint = Paint()
      ..shader = gradient.createShader(rect);

    canvas.drawOval(rect, gradientPaint);
  }

  void _drawScales(Canvas canvas, Offset center, double radius) {
    final scalePaint = Paint()
      ..color = const Color(0xFFFFC107)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final highlightPaint = Paint()
      ..color = const Color(0xFFFFEB3B).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    for (double row = 0; row < 6; row++) {
      final rowOffset = row * radius * 0.28;
      final y = center.dy - radius * 0.5 + rowOffset + radius * 0.15;
      final scaleSpacing = radius * 0.28;

      final startX = center.dx - radius * (0.9 - row * 0.15);
      final endX = center.dx + radius * (0.9 - row * 0.15);
      final count = row == 0 || row == 5 ? 5 : 7;

      for (int i = 0; i < count; i++) {
        final x = startX + (endX - startX) * i / (count - 1);
        final isEven = i % 2 == 0;

        final scaleY = y + (isEven ? 0 : radius * 0.06);
        final scaleRadius = radius * (0.08 + (i % 2) * 0.02);

        canvas.drawCircle(
          Offset(x, scaleY),
          scaleRadius,
          scalePaint,
        );

        if (isEven) {
          canvas.drawCircle(
            Offset(x, scaleY),
            scaleRadius * 0.6,
            highlightPaint,
          );
        }
      }
    }
  }

  void _drawCameraLensV2(Canvas canvas, Offset center, double radius) {
    final outerRingPaint = Paint()
      ..color = const Color(0xFF2E2E2E)
      ..style = PaintingStyle.fill;

    final ringPaint = Paint()
      ..color = const Color(0xFF404040)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final innerPaint = Paint()
      ..color = lensColor
      ..style = PaintingStyle.fill;

    final bluePaint = Paint()
      ..color = const Color(0xFF4A90D9)
      ..style = PaintingStyle.fill;

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, outerRingPaint);

    for (int i = 0; i < 12; i++) {
      final angle = i * 3.14159 / 6;
      final dotX = center.dx + radius * 0.85 * _cos(angle);
      final dotY = center.dy + radius * 0.85 * _sin(angle);
      canvas.drawCircle(
        Offset(dotX, dotY),
        radius * 0.05,
        Paint()..color = const Color(0xFFFFD700)..style = PaintingStyle.fill,
      );
    }

    canvas.drawCircle(center, radius * 0.88, ringPaint);

    final innerGradient = RadialGradient(
      center: const Alignment(-0.2, -0.2),
      colors: [
        const Color(0xFF3A3A3A),
        lensColor,
      ],
    );

    final innerRect = Rect.fromCircle(center: center, radius: radius * 0.85);
    final innerGradientPaint = Paint()
      ..shader = innerGradient.createShader(innerRect);

    canvas.drawCircle(center, radius * 0.85, innerGradientPaint);

    canvas.drawCircle(center, radius * 0.5, bluePaint);

    canvas.drawCircle(
      center + Offset(-radius * 0.25, -radius * 0.25),
      radius * 0.15,
      highlightPaint,
    );

    final reflectionPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center + Offset(radius * 0.2, radius * 0.2),
      radius * 0.12,
      reflectionPaint,
    );

    for (int i = 0; i < 6; i++) {
      final angle = i * 3.14159 / 3;
      final innerDotX = center.dx + radius * 0.35 * _cos(angle);
      final innerDotY = center.dy + radius * 0.35 * _sin(angle);
      canvas.drawCircle(
        Offset(innerDotX, innerDotY),
        radius * 0.03,
        Paint()..color = Colors.white.withValues(alpha: 0.15),
      );
    }
  }

  double _cos(double angle) {
    final a = ((angle * 180 / 3.14159) % 360).toInt();
    return _trigTable[a] ?? 1.0;
  }

  double _sin(double angle) {
    final a = ((angle * 180 / 3.14159) % 360).toInt();
    return _trigTable[a + 360] ?? 0.0;
  }

  static final _trigTable = {
    0: 1.0, 30: 0.866, 45: 0.707, 60: 0.5, 90: 0.0,
    120: -0.5, 135: -0.707, 150: -0.866, 180: -1.0,
    210: -0.866, 225: -0.707, 240: -0.5, 270: 0.0,
    300: 0.5, 315: 0.707, 330: 0.866, 360: 1.0,
    0 + 360: 0.0, 30 + 360: 0.5, 45 + 360: 0.707,
    60 + 360: 0.866, 90 + 360: 1.0, 120 + 360: 0.866,
    135 + 360: 0.707, 150 + 360: 0.5, 180 + 360: 0.0,
    210 + 360: -0.5, 225 + 360: -0.707, 240 + 360: -0.866,
    270 + 360: -1.0, 300 + 360: -0.866, 315 + 360: -0.707,
    330 + 360: -0.5, 360 + 360: 0.0,
  };

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PineappleLogoSimpleV2 extends StatelessWidget {
  final double size;
  final Color fruitColor;
  final Color crownColor;

  const PineappleLogoSimpleV2({
    super.key,
    this.size = 120,
    this.fruitColor = const Color(0xFFFFB800),
    this.crownColor = const Color(0xFF006A35),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _PineappleSimpleV2Painter(
              fruitColor: fruitColor,
              crownColor: crownColor,
            ),
          ),
          Positioned(
            bottom: size * 0.22,
            child: _buildLens(size * 0.28),
          ),
        ],
      ),
    );
  }

  Widget _buildLens(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.3),
          colors: [
            Color(0xFF4A4A4A),
            Color(0xFF2A2A2A),
            Color(0xFF1A1A1A),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.all(size * 0.08),
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            center: Alignment(-0.2, -0.2),
            colors: [
              Color(0xFF3A3A3A),
              Color(0xFF1A1A1A),
            ],
          ),
          shape: BoxShape.circle,
        ),
        child: Stack(
          children: [
            Center(
              child: Container(
                width: size * 0.45,
                height: size * 0.45,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.3),
                    colors: [
                      const Color(0xFF5A9BD4),
                      const Color(0xFF4A90D9),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: size * 0.1,
              top: size * 0.1,
              child: Container(
                width: size * 0.12,
                height: size * 0.12,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: size * 0.08,
              bottom: size * 0.15,
              child: Container(
                width: size * 0.08,
                height: size * 0.08,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PineappleSimpleV2Painter extends CustomPainter {
  final Color fruitColor;
  final Color crownColor;

  _PineappleSimpleV2Painter({
    required this.fruitColor,
    required this.crownColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final crownWidth = size.width * 0.5;
    final fruitWidth = size.width * 0.55;

    _drawCrownSimple(canvas, center, crownWidth);
    _drawFruitSimple(canvas, center, fruitWidth);
  }

  void _drawCrownSimple(Canvas canvas, Offset center, double width) {
    final paint = Paint()
      ..color = crownColor
      ..style = PaintingStyle.fill;

    final baseY = center.dy - width * 0.5;

    for (int i = 0; i < 7; i++) {
      final offset = (i - 3) * width * 0.15;
      final leafHeight = width * (0.9 - (i.abs() - 3).abs() * 0.15);

      final path = Path();
      path.moveTo(center.dx + offset, baseY);
      path.quadraticBezierTo(
        center.dx + offset - width * 0.08,
        baseY - leafHeight * 0.6,
        center.dx + offset - width * 0.1,
        baseY - leafHeight,
      );
      path.quadraticBezierTo(
        center.dx + offset,
        baseY - leafHeight * 0.5,
        center.dx + offset,
        baseY,
      );

      canvas.drawPath(path, paint);
    }
  }

  void _drawFruitSimple(Canvas canvas, Offset center, double width) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawOval(
      Rect.fromCenter(
        center: center + const Offset(2, 4),
        width: width * 1.8,
        height: width * 2.0,
      ),
      shadowPaint,
    );

    final gradientPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          const Color(0xFFFFD54F),
          fruitColor,
          const Color(0xFFFFA000),
        ],
      ).createShader(
        Rect.fromCenter(
          center: center,
          width: width * 1.8,
          height: width * 2.0,
        ),
      );

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: width * 1.8,
        height: width * 2.0,
      ),
      gradientPaint,
    );

    final scalePaint = Paint()
      ..color = const Color(0xFFFFC107)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final highlightPaint = Paint()
      ..color = const Color(0xFFFFEB3B).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    for (double row = 0; row < 5; row++) {
      final y = center.dy - width * 0.6 + row * width * 0.3;
      final scaleCount = row == 0 || row == 4 ? 4 : 6;

      for (int i = 0; i < scaleCount; i++) {
        final x = center.dx - width * (0.7 - row * 0.1) + i * width * (0.28 - row * 0.02);
        final isEven = i % 2 == 0;

        canvas.drawCircle(
          Offset(x, y + (isEven ? 0 : width * 0.05)),
          width * 0.09,
          scalePaint,
        );

        if (isEven) {
          canvas.drawCircle(
            Offset(x, y),
            width * 0.05,
            highlightPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}