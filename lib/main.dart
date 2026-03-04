import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const SafrApp());
}

class SafrApp extends StatelessWidget {
  const SafrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Safr',
      theme: ThemeData(useMaterial3: true),
      home: const SafrSplashScreen(),
    );
  }
}

class SafrSplashScreen extends StatefulWidget {
  const SafrSplashScreen({super.key});

  @override
  State<SafrSplashScreen> createState() => _SafrSplashScreenState();
}

class _SafrSplashScreenState extends State<SafrSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _drawController;
  late final AnimationController _loaderController;
  late final Timer _navigationTimer;

  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _drawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    );
    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _fade = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    );
    _scale = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutCubic,
      ),
    );

    _logoController.forward();
    _drawController.forward();

    _navigationTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _navigationTimer.cancel();
    _logoController.dispose();
    _drawController.dispose();
    _loaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const top = Color(0xFF1FAF7A);
    const middle = Color(0xFF22B07D);
    const deep = Color(0xFF0F3D3E);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [top, middle, deep],
                  stops: [0.0, 0.52, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _MountainMistPainter(),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _NoisePainter(opacity: 0.035),
            ),
          ),
          SafeArea(
            child: SizedBox.expand(
              child: Column(
                children: [
                  const Spacer(flex: 7),
                  FadeTransition(
                    opacity: _fade,
                    child: ScaleTransition(
                      scale: _scale,
                      child: _LogoBlock(drawAnimation: _drawController),
                    ),
                  ),
                  const Spacer(flex: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: _LoadingDots(controller: _loaderController),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoBlock extends StatelessWidget {
  const _LogoBlock({required this.drawAnimation});

  final Animation<double> drawAnimation;

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.inter(
      color: Colors.white,
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.0,
      height: 1.1,
    );
    final subtitleStyle = GoogleFonts.inter(
      color: Colors.white.withValues(alpha: 0.82),
      fontSize: 15,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 116,
          height: 116,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.11),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(-4, -4),
              ),
            ],
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: drawAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(72, 72),
                  painter: _SafrLogoPainter(progress: drawAnimation.value),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Safr', style: titleStyle),
        const SizedBox(height: 8),
        Text('Explore the world your way', style: subtitleStyle),
      ],
    );
  }
}

class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(3, (index) {
            final phase = (controller.value * 2 * math.pi) - (index * 0.7);
            final t = (math.sin(phase) + 1) / 2;
            final size = 6 + (t * 3);
            final opacity = 0.45 + (t * 0.5);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

class _SafrLogoPainter extends CustomPainter {
  _SafrLogoPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ringRadius = size.width * 0.38;

    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    final pathPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    final accentPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final ringPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: ringRadius));
    final sPath = Path()
      ..moveTo(size.width * 0.31, size.height * 0.28)
      ..cubicTo(
        size.width * 0.58,
        size.height * 0.16,
        size.width * 0.65,
        size.height * 0.52,
        size.width * 0.45,
        size.height * 0.57,
      )
      ..cubicTo(
        size.width * 0.24,
        size.height * 0.63,
        size.width * 0.34,
        size.height * 0.90,
        size.width * 0.70,
        size.height * 0.78,
      );

    final northPointer = Path()
      ..moveTo(center.dx, center.dy - ringRadius - 6)
      ..lineTo(center.dx - 4.8, center.dy - ringRadius + 2.5)
      ..lineTo(center.dx + 4.8, center.dy - ringRadius + 2.5)
      ..close();

    _drawPathProgress(canvas, ringPath, ringPaint, progress);
    _drawPathProgress(canvas, sPath, pathPaint, (progress - 0.22) / 0.78);

    if (progress > 0.72) {
      final alpha = ((progress - 0.72) / 0.28).clamp(0.0, 1.0);
      canvas.drawPath(
        northPointer,
        accentPaint..color = Colors.white.withValues(alpha: alpha),
      );
    }
  }

  void _drawPathProgress(Canvas canvas, Path path, Paint paint, double value) {
    final clamped = value.clamp(0.0, 1.0);
    if (clamped <= 0) return;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      final length = metric.length * clamped;
      final extract = metric.extractPath(0, length);
      canvas.drawPath(extract, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SafrLogoPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _MountainMistPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final leftMountain = Path()
      ..moveTo(0, size.height * 0.76)
      ..quadraticBezierTo(
        size.width * 0.2,
        size.height * 0.56,
        size.width * 0.48,
        size.height * 0.76,
      )
      ..lineTo(0, size.height)
      ..close();
    final rightMountain = Path()
      ..moveTo(size.width * 0.34, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.64,
        size.height * 0.5,
        size.width,
        size.height * 0.79,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.34, size.height)
      ..close();

    final mountainPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.08),
          Colors.black.withValues(alpha: 0.16),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawPath(leftMountain, mountainPaint);
    canvas.drawPath(rightMountain, mountainPaint);

    final mist = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.13),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(0, size.height * 0.56, size.width, size.height * 0.34),
      );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.56, size.width, size.height * 0.34),
      mist,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NoisePainter extends CustomPainter {
  _NoisePainter({required this.opacity});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: opacity);
    for (double y = 0; y < size.height; y += 5.0) {
      for (double x = 0; x < size.width; x += 5.0) {
        final noise = ((math.sin(x * 0.08) + math.cos(y * 0.11)) * 0.5 + 0.5);
        if (noise > 0.7) {
          canvas.drawCircle(Offset(x, y), 0.3, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F3D3E), Color(0xFF176C5A)],
          ),
        ),
        child: Center(
          child: Text(
            'Onboarding',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 28,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}
