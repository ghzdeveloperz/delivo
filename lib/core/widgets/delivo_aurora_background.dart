import 'dart:math' as math;

import 'package:flutter/material.dart';

class DelivoAuroraBackground extends StatefulWidget {
  const DelivoAuroraBackground({required this.child, super.key});

  final Widget child;

  @override
  State<DelivoAuroraBackground> createState() => _DelivoAuroraBackgroundState();
}

class _DelivoAuroraBackgroundState extends State<DelivoAuroraBackground>
    with SingleTickerProviderStateMixin {
  static const Duration _duration = Duration(seconds: 18);

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _duration)
      ..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (reduceMotion) {
      _controller
        ..stop()
        ..value = 0.16;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? const Color(0xFF090B16)
        : const Color(0xFFF7F8FC);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
      color: backgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: CustomPaint(painter: _DotGridPainter(isDark: isDark)),
          ),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _AuroraSmokePainter(
                    progress: _controller.value,
                    isDark: isDark,
                  ),
                );
              },
            ),
          ),
          IgnorePointer(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              child: isDark
                  ? const _DarkVignette(key: ValueKey<String>('dark-vignette'))
                  : const _LightVignette(
                      key: ValueKey<String>('light-vignette'),
                    ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _DarkVignette extends StatelessWidget {
  const _DarkVignette({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.10),
          radius: 1.12,
          colors: [
            Color(0x00101526),
            Color(0x12090B16),
            Color(0x5C090B16),
            Color(0xD9090B16),
          ],
          stops: [0, 0.48, 0.80, 1],
        ),
      ),
    );
  }
}

class _LightVignette extends StatelessWidget {
  const _LightVignette({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.08),
          radius: 1.18,
          colors: [
            Color(0x00FFFFFF),
            Color(0x08FFFFFF),
            Color(0x12F7F8FC),
            Color(0x2AF7F8FC),
          ],
          stops: [0, 0.48, 0.80, 1],
        ),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 20.0;
    const radius = 0.85;

    final paint = Paint()
      ..color = isDark ? const Color(0x24FFFFFF) : const Color(0x2230354C);

    for (double y = 0; y <= size.height; y += spacing) {
      for (double x = 0; x <= size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}

class _AuroraSmokePainter extends CustomPainter {
  const _AuroraSmokePainter({required this.progress, required this.isDark});

  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final perimeter = 2 * (size.width + size.height);

    final intensity = isDark ? 1.0 : 0.78;

    _drawSmoke(
      canvas,
      _pointOnPerimeter(perimeter * progress, size),
      const [Color(0xB76C5CE7), Color(0x862D9CDB), Color(0x002D9CDB)],
      250,
      0.26 * intensity,
    );

    _drawSmoke(
      canvas,
      _pointOnPerimeter(perimeter * ((progress + 0.34) % 1), size),
      const [Color(0x9D2ECF9F), Color(0x79F7B731), Color(0x00F7B731)],
      210,
      0.21 * intensity,
    );

    _drawSmoke(
      canvas,
      _pointOnPerimeter(perimeter * ((progress + 0.68) % 1), size),
      const [Color(0x9DFF5C6C), Color(0x7B8B7CF6), Color(0x008B7CF6)],
      230,
      0.22 * intensity,
    );

    _drawSecondaryMist(canvas, size, progress, intensity);
  }

  void _drawSmoke(
    Canvas canvas,
    Offset center,
    List<Color> colors,
    double radius,
    double opacity,
  ) {
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..shader = RadialGradient(
        colors: colors
            .map((color) => color.withValues(alpha: color.a * opacity))
            .toList(growable: false),
        stops: const [0, 0.46, 1],
      ).createShader(rect)
      ..blendMode = isDark ? BlendMode.screen : BlendMode.srcOver;

    canvas.drawCircle(center, radius, paint);
  }

  void _drawSecondaryMist(
    Canvas canvas,
    Size size,
    double t,
    double intensity,
  ) {
    final phase = t * math.pi * 2;

    final centerA = Offset(
      size.width * (0.18 + 0.08 * math.sin(phase * 0.72)),
      size.height * (0.04 + 0.02 * math.cos(phase * 0.51)),
    );

    final centerB = Offset(
      size.width * (0.84 + 0.06 * math.cos(phase * 0.66)),
      size.height * (0.94 + 0.02 * math.sin(phase * 0.58)),
    );

    _drawSmoke(
      canvas,
      centerA,
      const [Color(0x746C5CE7), Color(0x542D9CDB), Color(0x002D9CDB)],
      180,
      0.15 * intensity,
    );

    _drawSmoke(
      canvas,
      centerB,
      const [Color(0x582ECF9F), Color(0x46FF5C6C), Color(0x00FF5C6C)],
      190,
      0.13 * intensity,
    );
  }

  Offset _pointOnPerimeter(double distance, Size size) {
    final perimeter = 2 * (size.width + size.height);

    var d = distance % perimeter;

    if (d <= size.width) {
      return Offset(d, -20);
    }

    d -= size.width;

    if (d <= size.height) {
      return Offset(size.width + 20, d);
    }

    d -= size.height;

    if (d <= size.width) {
      return Offset(size.width - d, size.height + 20);
    }

    d -= size.width;

    return Offset(-20, size.height - d);
  }

  @override
  bool shouldRepaint(covariant _AuroraSmokePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
