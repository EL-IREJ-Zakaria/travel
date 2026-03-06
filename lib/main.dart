import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const SafrApp());
}

const List<IconData> _kMainNavIcons = <IconData>[
  Icons.home_rounded,
  Icons.travel_explore_rounded,
  Icons.menu_book_rounded,
  Icons.favorite_border_rounded,
  Icons.person_outline_rounded,
];

const List<String> _kMainNavLabels = <String>[
  'Home',
  'Explore',
  'Trips',
  'Favorites',
  'Profile',
];

Route<void> _buildSmartRoute(Widget page) {
  return PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
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

    _fade = CurvedAnimation(parent: _logoController, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
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
          Positioned.fill(child: CustomPaint(painter: _MountainMistPainter())),
          Positioned.fill(
            child: IgnorePointer(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(painter: _NoisePainter(opacity: 0.035)),
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
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white.withValues(alpha: 0.13), Colors.transparent],
          ).createShader(
            Rect.fromLTWH(
              0,
              size.height * 0.56,
              size.width,
              size.height * 0.34,
            ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
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
                                            offset: Offset(
                                              0,
                                              _floatOffset.value,
                                            ),
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
      ..shader =
          RadialGradient(
            colors: [Colors.white.withValues(alpha: 0.4), Colors.transparent],
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
        colors: [const Color(0xFFEAF8EE), const Color(0xFFD6F2E0)],
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
    canvas.drawPath(mountainFar, Paint()..color = const Color(0xFFB8E2C4));

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
    canvas.drawPath(mountainMid, Paint()..color = const Color(0xFF84CBA1));

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
    canvas.drawPath(mountainFront, Paint()..color = const Color(0xFF489467));

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
    canvas.drawPath(foregroundHill, Paint()..color = const Color(0xFF1E6B4C));

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FocusNode _searchFocusNode = FocusNode();
  static const String _profileImageUrl =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330'
      '?auto=format&fit=crop&w=400&q=80';
  final List<String> _exploreTabs = const [
    'All',
    'Popular',
    'Recommended',
    'Most Viewed',
  ];
  final List<_Destination> _destinations = const [
    _Destination(
      name: 'Ubud Rice Terrace',
      country: 'Indonesia',
      rating: 4.9,
      imageUrl:
          'https://images.unsplash.com/photo-1537996194471-e657df975ab4'
          '?auto=format&fit=crop&w=1200&q=80',
      tripLength: '5 days',
      priceLabel: '\$920',
      description:
          'Lush rice terraces, sunrise yoga and hidden waterfalls across a calm tropical route.',
    ),
    _Destination(
      name: 'Passo Rolle, TN',
      country: 'Italy',
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b'
          '?auto=format&fit=crop&w=1200&q=80',
      tripLength: '4 days',
      priceLabel: '\$760',
      description:
          'A panoramic alpine escape with mountain roads, cable cars and dramatic golden-hour views.',
    ),
    _Destination(
      name: 'Chefchaouen Medina',
      country: 'Morocco',
      rating: 4.7,
      imageUrl:
          'https://images.unsplash.com/photo-1528127269322-539801943592'
          '?auto=format&fit=crop&w=1200&q=80',
      tripLength: '3 days',
      priceLabel: '\$430',
      description:
          'Blue-painted streets, artisan shops and rooftop cafés that overlook the Rif mountains.',
    ),
    _Destination(
      name: 'Santorini Sunset',
      country: 'Greece',
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff'
          '?auto=format&fit=crop&w=1200&q=80',
      tripLength: '6 days',
      priceLabel: '\$1,150',
      description:
          'White cliffside villages, caldera cruises and sunset dinners in Oia and Fira.',
    ),
  ];
  final List<_Category> _categories = const [
    _Category(
      label: 'Mountains',
      imageUrl:
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b'
          '?auto=format&fit=crop&w=600&q=80',
      alignment: Alignment.topCenter,
    ),
    _Category(
      label: 'Camp',
      imageUrl:
          'https://images.unsplash.com/photo-1504280390368-3971d7d1fcae'
          '?auto=format&fit=crop&w=600&q=80',
      alignment: Alignment.center,
    ),
    _Category(
      label: 'Beach',
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e'
          '?auto=format&fit=crop&w=600&q=80',
      alignment: Alignment.bottomCenter,
    ),
    _Category(
      label: 'City',
      imageUrl:
          'https://images.unsplash.com/photo-1449824913935-59a10b8d2000'
          '?auto=format&fit=crop&w=600&q=80',
      alignment: Alignment.centerRight,
    ),
  ];
  final List<_TripPlan> _tripPlans = const [
    _TripPlan(
      title: 'Weekend Escape',
      location: 'Marrakesh to Agafay',
      days: '2D / 1N',
      budgetLabel: '\$280',
      imageUrl:
          'https://images.unsplash.com/photo-1539650116574-75c0c6d73f4e'
          '?auto=format&fit=crop&w=1000&q=80',
    ),
    _TripPlan(
      title: 'Work + Chill',
      location: 'Lisbon Coastline',
      days: '4D / 3N',
      budgetLabel: '\$540',
      imageUrl:
          'https://images.unsplash.com/photo-1513735492246-483525079686'
          '?auto=format&fit=crop&w=1000&q=80',
    ),
    _TripPlan(
      title: 'Nature Focus',
      location: 'Swiss Alps',
      days: '5D / 4N',
      budgetLabel: '\$990',
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4'
          '?auto=format&fit=crop&w=1000&q=80',
    ),
  ];
  final List<_TravelTip> _travelTips = const [
    _TravelTip(
      title: 'Best sunrise viewpoints',
      subtitle: 'Find spots with fewer crowds and cleaner weather windows.',
      readTime: '5 min read',
      imageUrl:
          'https://images.unsplash.com/photo-1470770841072-f978cf4d019e'
          '?auto=format&fit=crop&w=800&q=80',
    ),
    _TravelTip(
      title: 'Pack light for spring trips',
      subtitle: 'A 7-piece packing system for mixed weather and city walks.',
      readTime: '4 min read',
      imageUrl:
          'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800'
          '?auto=format&fit=crop&w=800&q=80',
    ),
  ];

  int _activeTabIndex = 1;
  int _activeNavIndex = 0;
  String _activeCategory = 'Camp';
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_handleSearchFocus);
  }

  @override
  void dispose() {
    _searchFocusNode
      ..removeListener(_handleSearchFocus)
      ..dispose();
    super.dispose();
  }

  void _handleSearchFocus() {
    if (_isSearchFocused != _searchFocusNode.hasFocus) {
      setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
    }
  }

  void _openDetails(_Destination destination) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 340),
        pageBuilder: (context, animation, secondaryAnimation) {
          return _DestinationDetailsScreen(destination: destination);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _openAccountDetails() {
    Navigator.of(context).push(_buildSmartRoute(const _AccountDetailsScreen()));
  }

  void _openNotificationSettings() {
    Navigator.of(
      context,
    ).push(_buildSmartRoute(const _NotificationSettingsScreen()));
  }

  void _openPaymentMethods() {
    Navigator.of(context).push(_buildSmartRoute(const _PaymentMethodsScreen()));
  }

  void _openPreferencesDetails() {
    Navigator.of(context).push(_buildSmartRoute(const _PreferencesScreen()));
  }

  void _openHelpSupport() {
    Navigator.of(context).push(_buildSmartRoute(const _HelpSupportScreen()));
  }

  void _openSettingsPage() {
    Navigator.of(context).push(
      _buildSmartRoute(
        _SettingsScreen(
          onNotificationsTap: _openNotificationSettings,
          onPaymentTap: _openPaymentMethods,
          onPreferencesTap: _openPreferencesDetails,
          onHelpTap: _openHelpSupport,
          onBottomNavTap: _handleNestedNavTap,
        ),
      ),
    );
  }

  void _handleNestedNavTap(int index) {
    if (index == 4) {
      Navigator.of(context).maybePop();
      return;
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
    if (!mounted) return;
    setState(() => _activeNavIndex = index);
  }

  Widget _buildExploreContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi Williamson,',
                  style: GoogleFonts.inter(
                    color: const Color(0xCC111111),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _TravelNetworkImage(
                      imageUrl: _profileImageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 290,
              child: Text(
                'Where do you want to go?',
                style: GoogleFonts.inter(
                  color: const Color(0xFF111111),
                  fontSize: 31,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
            ),
            const SizedBox(height: 26),
            AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeInOut,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isSearchFocused
                      ? const Color(0xFF22B07D).withValues(alpha: 0.6)
                      : Colors.transparent,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: _isSearchFocused ? 0.11 : 0.06,
                    ),
                    blurRadius: _isSearchFocused ? 16 : 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF8A8A8A),
                    size: 21,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      focusNode: _searchFocusNode,
                      cursorColor: const Color(0xFF22B07D),
                      style: GoogleFonts.inter(
                        color: const Color(0xFF111111),
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Discover a city',
                        hintStyle: GoogleFonts.inter(
                          color: const Color(0xFF8A8A8A),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        isCollapsed: true,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    splashRadius: 20,
                    icon: const Icon(
                      Icons.tune_rounded,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            _SectionHeader(title: 'Featured Journey', onSeeAll: () {}),
            const SizedBox(height: 14),
            _FeaturedDealCard(
              destination: _destinations.first,
              onTap: () => _openDetails(_destinations.first),
            ),
            const SizedBox(height: 30),
            _SectionHeader(title: 'Explore Cities', onSeeAll: () {}),
            const SizedBox(height: 14),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _exploreTabs.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final active = _activeTabIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _activeTabIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFF22B07D).withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active
                              ? const Color(0xFF22B07D).withValues(alpha: 0.45)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        _exploreTabs[index],
                        style: GoogleFonts.inter(
                          color: active
                              ? const Color(0xFF22B07D)
                              : const Color(0xFF9A9A9A),
                          fontSize: 14,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 214,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _destinations.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final destination = _destinations[index];
                  return _DestinationCard(
                    destination: destination,
                    onTap: () => _openDetails(destination),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            _SectionHeader(title: 'Trip Plans', onSeeAll: () {}),
            const SizedBox(height: 14),
            SizedBox(
              height: 194,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _tripPlans.length,
                separatorBuilder: (context, index) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final plan = _tripPlans[index];
                  return _TripPlanCard(plan: plan);
                },
              ),
            ),
            const SizedBox(height: 32),
            _SectionHeader(title: 'Categories', onSeeAll: () {}),
            const SizedBox(height: 14),
            SizedBox(
              height: 106,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final active = _activeCategory == category.label;
                  return _CategoryCard(
                    category: category,
                    active: active,
                    onTap: () {
                      setState(() => _activeCategory = category.label);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            _SectionHeader(title: 'Travel Tips', onSeeAll: () {}),
            const SizedBox(height: 14),
            Column(
              children: List<Widget>.generate(_travelTips.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == _travelTips.length - 1 ? 0 : 12,
                  ),
                  child: _TravelTipCard(tip: _travelTips[index]),
                );
              }),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyForTab() {
    if (_activeNavIndex == 0) {
      return _buildExploreContent();
    }
    if (_activeNavIndex == 4) {
      return _ProfileOverviewScreen(
        onAccountSettingsTap: _openAccountDetails,
        onNotificationsTap: _openNotificationSettings,
        onPaymentTap: _openPaymentMethods,
        onPreferencesTap: _openSettingsPage,
      );
    }

    return _NavPlaceholder(
      icon: _kMainNavIcons[_activeNavIndex],
      label: _kMainNavLabels[_activeNavIndex],
    );
  }

  Widget _buildBottomNav() {
    return _FloatingBottomNavBar(
      activeIndex: _activeNavIndex,
      onTap: (index) => setState(() => _activeNavIndex = index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F6),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Column(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 360),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.02, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey<int>(_activeNavIndex),
                      child: _buildBodyForTab(),
                    ),
                  ),
                ),
                _buildBottomNav(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingBottomNavBar extends StatelessWidget {
  const _FloatingBottomNavBar({required this.activeIndex, required this.onTap});

  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
        child: Container(
          height: 66,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            children: List<Widget>.generate(_kMainNavIcons.length, (index) {
              final active = activeIndex == index;
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => onTap(index),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active
                            ? const Color(0xFF2FAF7A).withValues(alpha: 0.14)
                            : Colors.transparent,
                        border: Border.all(
                          color: active
                              ? const Color(0xFF2FAF7A).withValues(alpha: 0.6)
                              : Colors.transparent,
                        ),
                      ),
                      child: Icon(
                        _kMainNavIcons[index],
                        color: active
                            ? const Color(0xFF2FAF7A)
                            : const Color(0xFFA8A8A8),
                        size: 22,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _ProfileOverviewScreen extends StatelessWidget {
  const _ProfileOverviewScreen({
    required this.onAccountSettingsTap,
    required this.onNotificationsTap,
    required this.onPaymentTap,
    required this.onPreferencesTap,
  });

  final VoidCallback onAccountSettingsTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onPaymentTap;
  final VoidCallback onPreferencesTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 88),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF2FAF7A), Color(0xFF35C48B)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Manage your account',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                left: 14,
                right: 14,
                bottom: -142,
                child: _ProfileUserCard(),
              ),
            ],
          ),
          const SizedBox(height: 158),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: [
                _AccountListTileCard(
                  icon: Icons.person_outline_rounded,
                  title: 'Account Settings',
                  subtitle: 'Manage your account details',
                  onTap: onAccountSettingsTap,
                ),
                const SizedBox(height: 16),
                _AccountListTileCard(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  subtitle: 'Manage notification preferences',
                  onTap: onNotificationsTap,
                ),
                const SizedBox(height: 16),
                _AccountListTileCard(
                  icon: Icons.credit_card_rounded,
                  title: 'Payment Methods',
                  subtitle: 'Manage cards and payment',
                  onTap: onPaymentTap,
                ),
                const SizedBox(height: 16),
                _AccountListTileCard(
                  icon: Icons.settings_rounded,
                  title: 'Preferences',
                  subtitle: 'App settings and preferences',
                  onTap: onPreferencesTap,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ProfileUserCard extends StatelessWidget {
  const _ProfileUserCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.11),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF2FAF7A),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'W',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF35C48B),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.photo_camera_outlined,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Williamson',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF111111),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _ProfileInfoLine(
                      icon: Icons.mail_outline_rounded,
                      text: 'williamson@safr.com',
                    ),
                    const SizedBox(height: 3),
                    _ProfileInfoLine(
                      icon: Icons.phone_outlined,
                      text: '+1 (555) 123-4567',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            color: const Color(0xFF111111).withValues(alpha: 0.1),
            height: 1,
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _ProfileStatItem(value: '12', label: 'Trips'),
              ),
              Expanded(
                child: _ProfileStatItem(value: '28', label: 'Reviews'),
              ),
              Expanded(
                child: _ProfileStatItem(value: '156', label: 'Photos'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoLine extends StatelessWidget {
  const _ProfileInfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF7A7A7A)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: const Color(0xFF7A7A7A),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileStatItem extends StatelessWidget {
  const _ProfileStatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            color: const Color(0xFF111111),
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF7A7A7A),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AccountListTileCard extends StatelessWidget {
  const _AccountListTileCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor = const Color(0xFF2FAF7A),
    this.titleColor = const Color(0xFF111111),
    this.subtitleColor = const Color(0xFF7A7A7A),
    this.iconBackgroundColor = const Color(0xFFE9F4EE),
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.transparent,
    this.trailingColor = const Color(0xFF8A8A8A),
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;
  final Color iconBackgroundColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color trailingColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBackgroundColor,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: titleColor,
                        fontSize: 22 / 1.375,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        color: subtitleColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: trailingColor, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen({
    required this.onNotificationsTap,
    required this.onPaymentTap,
    required this.onPreferencesTap,
    required this.onHelpTap,
    required this.onBottomNavTap,
  });

  final VoidCallback onNotificationsTap;
  final VoidCallback onPaymentTap;
  final VoidCallback onPreferencesTap;
  final VoidCallback onHelpTap;
  final ValueChanged<int> onBottomNavTap;

  Future<void> _showLogoutConfirmation(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Logout',
            style: GoogleFonts.inter(
              color: const Color(0xFF111111),
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Are you sure you want to sign out from your account?',
            style: GoogleFonts.inter(
              color: const Color(0xFF575757),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: const Color(0xFF7A7A7A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF111111),
                    content: Text(
                      'You have been logged out.',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
              child: Text(
                'Logout',
                style: GoogleFonts.inter(
                  color: const Color(0xFFE25A5A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F6),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 18, 14, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => Navigator.of(context).pop(),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.arrow_back_rounded,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Settings',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF111111),
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        _AccountListTileCard(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notifications',
                          subtitle: 'Manage notification preferences',
                          onTap: onNotificationsTap,
                        ),
                        const SizedBox(height: 14),
                        _AccountListTileCard(
                          icon: Icons.credit_card_rounded,
                          title: 'Payment Methods',
                          subtitle: 'Manage cards and payment',
                          onTap: onPaymentTap,
                        ),
                        const SizedBox(height: 14),
                        _AccountListTileCard(
                          icon: Icons.settings_rounded,
                          title: 'Preferences',
                          subtitle: 'App settings and preferences',
                          onTap: onPreferencesTap,
                        ),
                        const SizedBox(height: 14),
                        _AccountListTileCard(
                          icon: Icons.help_outline_rounded,
                          title: 'Help & Support',
                          subtitle: 'Get help and contact support',
                          onTap: onHelpTap,
                        ),
                        const SizedBox(height: 14),
                        _AccountListTileCard(
                          icon: Icons.logout_rounded,
                          title: 'Logout',
                          subtitle: 'Sign out from your account',
                          onTap: () => _showLogoutConfirmation(context),
                          iconColor: const Color(0xFFE25A5A),
                          titleColor: const Color(0xFFE25A5A),
                          subtitleColor: const Color(0xFFBC6C6C),
                          iconBackgroundColor: const Color(0xFFFFEBEB),
                          backgroundColor: const Color(0xFFFFF7F7),
                          borderColor: const Color(0xFFFFC6C6),
                          trailingColor: const Color(0xFFE25A5A),
                        ),
                        const SizedBox(height: 26),
                        Center(
                          child: Text(
                            'Safr App v1.0.0',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF8A8A8A),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _FloatingBottomNavBar(activeIndex: 4, onTap: onBottomNavTap),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsSubScreenScaffold extends StatelessWidget {
  const _SettingsSubScreenScaffold({
    required this.title,
    required this.body,
    this.trailing,
  });

  final String title;
  final Widget body;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F6),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.of(context).pop(),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF111111),
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountDetailsScreen extends StatefulWidget {
  const _AccountDetailsScreen();

  @override
  State<_AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<_AccountDetailsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Williamson');
    _emailController = TextEditingController(text: 'williamson@safr.com');
    _phoneController = TextEditingController(text: '+1 (555) 123-4567');
    _countryController = TextEditingController(text: 'United States');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsSubScreenScaffold(
      title: 'Account Details',
      trailing: TextButton(
        onPressed: () {
          _nameController.text = 'Williamson';
          _emailController.text = 'williamson@safr.com';
          _phoneController.text = '+1 (555) 123-4567';
          _countryController.text = 'United States';
          setState(() {});
        },
        child: Text(
          'Reset',
          style: GoogleFonts.inter(
            color: const Color(0xFF2FAF7A),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 66,
                      height: 66,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF2FAF7A),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'W',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF35C48B),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Photo',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF111111),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'JPG, PNG up to 5MB',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF7A7A7A),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Change',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF2FAF7A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ProfileInputField(
            label: 'Full Name',
            icon: Icons.person_outline_rounded,
            controller: _nameController,
          ),
          const SizedBox(height: 12),
          _ProfileInputField(
            label: 'Email Address',
            icon: Icons.mail_outline_rounded,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _ProfileInputField(
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _ProfileInputField(
            label: 'Country',
            icon: Icons.public_rounded,
            controller: _countryController,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2FAF7A), Color(0xFF35C48B)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2FAF7A).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text('Account details updated.'),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Center(
                      child: Text(
                        'Save Changes',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationSettingsScreen extends StatefulWidget {
  const _NotificationSettingsScreen();

  @override
  State<_NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<_NotificationSettingsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _dealsEnabled = true;
  bool _tripReminders = true;
  bool _newsletter = false;
  bool _quietHours = false;

  @override
  Widget build(BuildContext context) {
    return _SettingsSubScreenScaffold(
      title: 'Notifications',
      body: Column(
        children: [
          _SettingsToggleCard(
            title: 'Push Notifications',
            subtitle: 'Receive alerts for bookings and trip updates.',
            value: _pushEnabled,
            onChanged: (value) => setState(() => _pushEnabled = value),
          ),
          const SizedBox(height: 12),
          _SettingsToggleCard(
            title: 'Email Notifications',
            subtitle: 'Get updates and receipts by email.',
            value: _emailEnabled,
            onChanged: (value) => setState(() => _emailEnabled = value),
          ),
          const SizedBox(height: 12),
          _SettingsToggleCard(
            title: 'Special Deals',
            subtitle: 'Receive personalized travel offers.',
            value: _dealsEnabled,
            onChanged: (value) => setState(() => _dealsEnabled = value),
          ),
          const SizedBox(height: 12),
          _SettingsToggleCard(
            title: 'Trip Reminders',
            subtitle: 'Airport reminders and itinerary alerts.',
            value: _tripReminders,
            onChanged: (value) => setState(() => _tripReminders = value),
          ),
          const SizedBox(height: 12),
          _SettingsToggleCard(
            title: 'Newsletter',
            subtitle: 'Travel stories and inspiration every week.',
            value: _newsletter,
            onChanged: (value) => setState(() => _newsletter = value),
          ),
          const SizedBox(height: 12),
          _SettingsToggleCard(
            title: 'Quiet Hours',
            subtitle: _quietHours
                ? 'Enabled from 10:00 PM to 7:00 AM'
                : 'Mute notifications overnight.',
            value: _quietHours,
            onChanged: (value) => setState(() => _quietHours = value),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodsScreen extends StatefulWidget {
  const _PaymentMethodsScreen();

  @override
  State<_PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<_PaymentMethodsScreen> {
  String _selectedId = 'visa_main';

  final List<_PaymentMethodModel> _methods = const <_PaymentMethodModel>[
    _PaymentMethodModel(
      id: 'visa_main',
      label: 'Visa',
      masked: '**** **** **** 1842',
      expiry: '08/29',
      color: Color(0xFF2FAF7A),
    ),
    _PaymentMethodModel(
      id: 'master_backup',
      label: 'Mastercard',
      masked: '**** **** **** 9007',
      expiry: '03/28',
      color: Color(0xFF188F66),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _SettingsSubScreenScaffold(
      title: 'Payment Methods',
      body: Column(
        children: [
          ..._methods.map((method) {
            final selected = method.id == _selectedId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PaymentMethodCard(
                method: method,
                selected: selected,
                onTap: () => setState(() => _selectedId = method.id),
              ),
            );
          }),
          _AccountListTileCard(
            icon: Icons.add_card_rounded,
            title: 'Add New Card',
            subtitle: 'Save a new payment method for faster checkout',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _AccountListTileCard(
            icon: Icons.receipt_long_outlined,
            title: 'Billing Address',
            subtitle: '128 King Street, San Francisco, CA',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _PreferencesScreen extends StatefulWidget {
  const _PreferencesScreen();

  @override
  State<_PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<_PreferencesScreen> {
  String _language = 'English';
  String _currency = 'USD (\$)';
  bool _autoPlayVideo = true;
  bool _saveForOffline = true;
  bool _biometricLock = false;

  @override
  Widget build(BuildContext context) {
    return _SettingsSubScreenScaffold(
      title: 'Preferences',
      body: Column(
        children: [
          _SelectionCard<String>(
            title: 'Language',
            subtitle: 'Choose your preferred language',
            icon: Icons.translate_rounded,
            value: _language,
            options: const <String>['English', 'French', 'Spanish', 'Arabic'],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _language = value);
            },
          ),
          const SizedBox(height: 12),
          _SelectionCard<String>(
            title: 'Currency',
            subtitle: 'Default price display',
            icon: Icons.payments_outlined,
            value: _currency,
            options: const <String>[
              'USD (\$)',
              'EUR (€)',
              'GBP (£)',
              'MAD (DH)',
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _currency = value);
            },
          ),
          const SizedBox(height: 12),
          _SettingsToggleCard(
            title: 'Auto-play Travel Videos',
            subtitle: 'Preview destination videos in feed.',
            value: _autoPlayVideo,
            onChanged: (value) => setState(() => _autoPlayVideo = value),
          ),
          const SizedBox(height: 12),
          _SettingsToggleCard(
            title: 'Save Guides for Offline',
            subtitle: 'Download travel tips and city guides automatically.',
            value: _saveForOffline,
            onChanged: (value) => setState(() => _saveForOffline = value),
          ),
          const SizedBox(height: 12),
          _SettingsToggleCard(
            title: 'Biometric Lock',
            subtitle: 'Use Face ID / Touch ID to unlock app.',
            value: _biometricLock,
            onChanged: (value) => setState(() => _biometricLock = value),
          ),
        ],
      ),
    );
  }
}

class _HelpSupportScreen extends StatelessWidget {
  const _HelpSupportScreen();

  @override
  Widget build(BuildContext context) {
    return _SettingsSubScreenScaffold(
      title: 'Help & Support',
      body: Column(
        children: [
          _AccountListTileCard(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Live Chat',
            subtitle: 'Average response time: under 5 minutes',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _AccountListTileCard(
            icon: Icons.mail_outline_rounded,
            title: 'Email Support',
            subtitle: 'support@safr.com',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _AccountListTileCard(
            icon: Icons.call_outlined,
            title: 'Call Us',
            subtitle: '+1 (555) 000-1122',
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _FaqCard(
            question: 'How do I cancel a booking?',
            answer:
                'Open Trips, select your booking, and tap Cancel. Refund policy depends on provider terms.',
          ),
          const SizedBox(height: 10),
          _FaqCard(
            question: 'How can I update payment details?',
            answer:
                'Go to Profile > Settings > Payment Methods and choose the card you want to update.',
          ),
          const SizedBox(height: 10),
          _FaqCard(
            question: 'How do I contact emergency support?',
            answer:
                'Use Live Chat and select Emergency priority for urgent travel assistance.',
          ),
        ],
      ),
    );
  }
}

class _ProfileInputField extends StatelessWidget {
  const _ProfileInputField({
    required this.label,
    required this.icon,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(
          color: const Color(0xFF111111),
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: const Color(0xFF2FAF7A)),
          labelText: label,
          labelStyle: GoogleFonts.inter(
            color: const Color(0xFF7A7A7A),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SettingsToggleCard extends StatelessWidget {
  const _SettingsToggleCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF111111),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF7A7A7A),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            activeColor: const Color(0xFF2FAF7A),
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SelectionCard<T> extends StatelessWidget {
  const _SelectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final T value;
  final List<T> options;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2FAF7A), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF111111),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              color: const Color(0xFF7A7A7A),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          DropdownButton<T>(
            value: value,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            iconEnabledColor: const Color(0xFF2FAF7A),
            style: GoogleFonts.inter(
              color: const Color(0xFF111111),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            onChanged: onChanged,
            items: options.map((option) {
              return DropdownMenuItem<T>(
                value: option,
                child: Text(option.toString()),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final _PaymentMethodModel method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [method.color, method.color.withValues(alpha: 0.84)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? Colors.white.withValues(alpha: 0.85)
                  : Colors.transparent,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: method.color.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.label,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      method.masked,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.93),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                method.expiry,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  const _FaqCard({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        collapsedIconColor: const Color(0xFF7A7A7A),
        iconColor: const Color(0xFF2FAF7A),
        title: Text(
          question,
          style: GoogleFonts.inter(
            color: const Color(0xFF111111),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Text(
              answer,
              style: GoogleFonts.inter(
                color: const Color(0xFF666666),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodModel {
  const _PaymentMethodModel({
    required this.id,
    required this.label,
    required this.masked,
    required this.expiry,
    required this.color,
  });

  final String id;
  final String label;
  final String masked;
  final String expiry;
  final Color color;
}

class _FeaturedDealCard extends StatelessWidget {
  const _FeaturedDealCard({required this.destination, required this.onTap});

  final _Destination destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 188,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _TravelNetworkImage(
                imageUrl: destination.imageUrl,
                fit: BoxFit.cover,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.65),
                    ],
                    stops: const [0.2, 1],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            destination.name,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ),
                        Text(
                          destination.priceLabel,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          destination.country,
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.schedule_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          destination.tripLength,
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripPlanCard extends StatelessWidget {
  const _TripPlanCard({required this.plan});

  final _TripPlan plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 208,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: SizedBox(
              height: 104,
              width: double.infinity,
              child: _TravelNetworkImage(
                imageUrl: plan.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF111111),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plan.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF7D7D7D),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      size: 14,
                      color: Color(0xFF22B07D),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      plan.days,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF22B07D),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      plan.budgetLabel,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF111111),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

class _TravelTipCard extends StatelessWidget {
  const _TravelTipCard({required this.tip});

  final _TravelTip tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 84,
              height: 84,
              child: _TravelNetworkImage(
                imageUrl: tip.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF111111),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  tip.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF6F6F6F),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tip.readTime,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF22B07D),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF22B07D).withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF22B07D)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF1B3E35),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TravelNetworkImage extends StatelessWidget {
  const _TravelNetworkImage({
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final String imageUrl;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: fit,
      alignment: alignment,
      filterQuality: FilterQuality.medium,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Container(
          color: const Color(0xFFE9EFEC),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF22B07D),
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFE9EFEC),
          child: const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Color(0xFF8FA59D),
              size: 28,
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: const Color(0xFF111111),
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onSeeAll,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              'See all >',
              style: GoogleFonts.inter(
                color: const Color(0xFF22B07D),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({required this.destination, required this.onTap});

  final _Destination destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 172,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.11),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _TravelNetworkImage(
                imageUrl: destination.imageUrl,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.64),
                    ],
                    stops: const [0.45, 1],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  destination.country,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFFD55A),
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                destination.rating.toStringAsFixed(1),
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          destination.priceLabel,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.active,
    required this.onTap,
  });

  final _Category category;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
        width: 84,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? const Color(0xFF22B07D).withValues(alpha: 0.45)
                : Colors.transparent,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: active ? 0.12 : 0.06),
              blurRadius: active ? 14 : 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: SizedBox(
                height: 66,
                width: double.infinity,
                child: _TravelNetworkImage(
                  imageUrl: category.imageUrl,
                  fit: BoxFit.cover,
                  alignment: category.alignment,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  category.label,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF111111),
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavPlaceholder extends StatelessWidget {
  const _NavPlaceholder({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: const Color(0xFF22B07D)),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF111111),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DestinationDetailsScreen extends StatelessWidget {
  const _DestinationDetailsScreen({required this.destination});

  final _Destination destination;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _TravelNetworkImage(
                          imageUrl: destination.imageUrl,
                          fit: BoxFit.cover,
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.45),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 14,
                          top: 14,
                          child: Material(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => Navigator.of(context).pop(),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.arrow_back_rounded),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  destination.name,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF111111),
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 18,
                      color: Color(0xFF22B07D),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      destination.country,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF8A8A8A),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: Color(0xFFFFCF4A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      destination.rating.toStringAsFixed(1),
                      style: GoogleFonts.inter(
                        color: const Color(0xFF111111),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _DetailChip(
                      icon: Icons.schedule_rounded,
                      label: destination.tripLength,
                    ),
                    _DetailChip(
                      icon: Icons.payments_outlined,
                      label: 'From ${destination.priceLabel}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  destination.description,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF555555),
                    fontSize: 15,
                    height: 1.55,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _Destination {
  const _Destination({
    required this.name,
    required this.country,
    required this.rating,
    required this.imageUrl,
    required this.tripLength,
    required this.priceLabel,
    required this.description,
  });

  final String name;
  final String country;
  final double rating;
  final String imageUrl;
  final String tripLength;
  final String priceLabel;
  final String description;
}

class _Category {
  const _Category({
    required this.label,
    required this.imageUrl,
    required this.alignment,
  });

  final String label;
  final String imageUrl;
  final Alignment alignment;
}

class _TripPlan {
  const _TripPlan({
    required this.title,
    required this.location,
    required this.days,
    required this.budgetLabel,
    required this.imageUrl,
  });

  final String title;
  final String location;
  final String days;
  final String budgetLabel;
  final String imageUrl;
}

class _TravelTip {
  const _TravelTip({
    required this.title,
    required this.subtitle,
    required this.readTime,
    required this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String readTime;
  final String imageUrl;
}
