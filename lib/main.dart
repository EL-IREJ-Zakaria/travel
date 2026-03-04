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

    _navigationTimer = Timer(const Duration(seconds: 3), () {
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

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatOffset;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _floatOffset = Tween<double>(begin: -7, end: 7).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _openHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 360),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.03, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDEBDD),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390, maxHeight: 844),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(42),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(42),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFEAF7EC),
                        Color(0xFFD6F0DE),
                        Color(0xFFCBE8D5),
                      ],
                      stops: [0.0, 0.55, 1.0],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _OnboardingBackdropPainter(),
                        ),
                      ),
                      SafeArea(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  Text(
                                    'It\'s a Big World',
                                    style: GoogleFonts.inter(
                                      color: const Color(
                                        0xCC132021,
                                      ), // 80% dark
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Out There,\nGo Explore',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF0C1717),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 38,
                                      height: 0.98,
                                      letterSpacing: -0.6,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Expanded(
                                    child: Center(
                                      child: AnimatedBuilder(
                                        animation: _floatOffset,
                                        builder: (context, child) {
                                          return Transform.translate(
                                            offset: Offset(0, _floatOffset.value),
                                            child: child,
                                          );
                                        },
                                        child: SizedBox(
                                          width: constraints.maxWidth,
                                          child: const AspectRatio(
                                            aspectRatio: 0.92,
                                            child: CustomPaint(
                                              painter: _TravelScenePainter(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Center(
                                    child: FractionallySizedBox(
                                      widthFactor: 0.8,
                                      child: _GetStartedButton(
                                        onPressed: _openHome,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Center(
                                    child: TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFF57706D,
                                        ),
                                        textStyle: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      child: const Text('Privacy Policy'),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final topGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.4),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.7, size.height * 0.12),
          radius: size.width * 0.55,
        ),
      );
    canvas.drawRect(Offset.zero & size, topGlow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TravelScenePainter extends CustomPainter {
  const _TravelScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final skyRect = Rect.fromLTWH(0, 0, size.width, size.height * 0.64);
    final sky = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFEAF8EE),
          const Color(0xFFD6F2E0),
        ],
      ).createShader(skyRect);
    canvas.drawRect(skyRect, sky);

    final sunPaint = Paint()..color = const Color(0xFFF4FFD2);
    canvas.drawCircle(
      Offset(size.width * 0.83, size.height * 0.16),
      size.width * 0.085,
      sunPaint,
    );

    final mountainFar = Path()
      ..moveTo(0, size.height * 0.62)
      ..quadraticBezierTo(
        size.width * 0.18,
        size.height * 0.49,
        size.width * 0.34,
        size.height * 0.6,
      )
      ..quadraticBezierTo(
        size.width * 0.48,
        size.height * 0.42,
        size.width * 0.65,
        size.height * 0.58,
      )
      ..quadraticBezierTo(
        size.width * 0.81,
        size.height * 0.48,
        size.width,
        size.height * 0.61,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      mountainFar,
      Paint()..color = const Color(0xFFB8E2C4),
    );

    final mountainMid = Path()
      ..moveTo(0, size.height * 0.71)
      ..quadraticBezierTo(
        size.width * 0.26,
        size.height * 0.54,
        size.width * 0.47,
        size.height * 0.71,
      )
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.53,
        size.width,
        size.height * 0.72,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      mountainMid,
      Paint()..color = const Color(0xFF84CBA1),
    );

    final mountainFront = Path()
      ..moveTo(0, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.7,
        size.width * 0.56,
        size.height * 0.82,
      )
      ..quadraticBezierTo(
        size.width * 0.76,
        size.height * 0.74,
        size.width,
        size.height * 0.84,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      mountainFront,
      Paint()..color = const Color(0xFF489467),
    );

    final foregroundHill = Path()
      ..moveTo(0, size.height * 0.9)
      ..quadraticBezierTo(
        size.width * 0.2,
        size.height * 0.82,
        size.width * 0.44,
        size.height * 0.9,
      )
      ..quadraticBezierTo(
        size.width * 0.69,
        size.height * 0.82,
        size.width,
        size.height * 0.91,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      foregroundHill,
      Paint()..color = const Color(0xFF1E6B4C),
    );

    final cx = size.width * 0.54;
    final bodyTop = size.height * 0.64;
    final bodyHeight = size.height * 0.2;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, size.height * 0.88),
        width: size.width * 0.16,
        height: size.height * 0.035,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.14),
    );

    canvas.drawCircle(
      Offset(cx, bodyTop - size.height * 0.05),
      size.width * 0.035,
      Paint()..color = const Color(0xFFEBC8A4),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, bodyTop + bodyHeight * 0.34),
          width: size.width * 0.11,
          height: bodyHeight * 0.62,
        ),
        const Radius.circular(14),
      ),
      Paint()..color = const Color(0xFF1B5846),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx - size.width * 0.058, bodyTop + bodyHeight * 0.34),
          width: size.width * 0.11,
          height: bodyHeight * 0.58,
        ),
        const Radius.circular(12),
      ),
      Paint()..color = const Color(0xFFC5D454),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx - size.width * 0.065, bodyTop + bodyHeight * 0.26),
          width: size.width * 0.035,
          height: bodyHeight * 0.44,
        ),
        const Radius.circular(20),
      ),
      Paint()..color = const Color(0xFFA3BB42),
    );

    final legsPaint = Paint()..color = const Color(0xFF1A3E36);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx - size.width * 0.015, bodyTop + bodyHeight * 0.76),
          width: size.width * 0.035,
          height: bodyHeight * 0.42,
        ),
        const Radius.circular(8),
      ),
      legsPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + size.width * 0.03, bodyTop + bodyHeight * 0.79),
          width: size.width * 0.035,
          height: bodyHeight * 0.4,
        ),
        const Radius.circular(8),
      ),
      legsPaint,
    );

    final cameraCenter = Offset(size.width * 0.2, size.height * 0.29);
    canvas.save();
    canvas.translate(cameraCenter.dx, cameraCenter.dy);
    canvas.rotate(-0.12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: const Offset(0, 0),
          width: size.width * 0.11,
          height: size.width * 0.072,
        ),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF2A8F70),
    );
    canvas.drawCircle(
      const Offset(0, 0),
      size.width * 0.018,
      Paint()..color = const Color(0xFFF6FBF8),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(-size.width * 0.02, -size.width * 0.045),
          width: size.width * 0.045,
          height: size.width * 0.012,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF4EBF98),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GetStartedButton extends StatefulWidget {
  const _GetStartedButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_GetStartedButton> createState() => _GetStartedButtonState();
}

class _GetStartedButtonState extends State<_GetStartedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Material(
        color: _isPressed ? const Color(0xFF1D976B) : const Color(0xFF22B07D),
        elevation: _isPressed ? 2 : 8,
        shadowColor: const Color(0xFF0F3D3E).withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onHighlightChanged: (value) {
            setState(() => _isPressed = value);
          },
          onTap: widget.onPressed,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Get Started',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F3D3E), Color(0xFF1D7D63)],
          ),
        ),
        child: Center(
          child: Text(
            'Safr Home',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 30,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}
