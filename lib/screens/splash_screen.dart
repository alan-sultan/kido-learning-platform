import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F5),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFFF2CC0D),
          child: Stack(
            children: [
              const _BackgroundDecor(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _LogoBadge(),
                              SizedBox(height: 18),
                              _Tagline(),
                              SizedBox(height: 32),
                              _MascotAvatar(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: AnimatedBuilder(
                        animation: _progress,
                        builder: (context, _) {
                          return _LoaderFooter(progress: _progress.value);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
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

class _Tagline extends StatelessWidget {
  const _Tagline();

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Let's Play & Learn!",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xCC1C190D),
      ),
    );
  }
}

class _BackgroundDecor extends StatelessWidget {
  const _BackgroundDecor();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          top: -50,
          left: -50,
          child: _BlurBlob(size: 200, color: Color(0x33FFFFFF)),
        ),
        Positioned(
          top: 140,
          right: -40,
          child: _BlurBlob(size: 140, color: Color(0x33F97316)),
        ),
        Positioned(
          bottom: 140,
          left: -30,
          child: _BlurBlob(size: 170, color: Color(0x33EC4899)),
        ),
        Positioned(
          bottom: -80,
          right: -70,
          child: _BlurBlob(size: 240, color: Color(0x26FFFFFF)),
        ),
        Positioned(
          top: 24,
          right: 24,
          child: _FloatingIcon(
            icon: Icons.star,
            size: 56,
            rotation: 0.2,
            color: Color(0x66FFFFFF),
          ),
        ),
        Positioned(
          top: 100,
          left: 28,
          child: _FloatingIcon(
            icon: Icons.pentagon_outlined,
            size: 44,
            rotation: -0.3,
            color: Color(0x66FFFFFF),
          ),
        ),
        Positioned(
          bottom: 140,
          left: 36,
          child: _FloatingIcon(
            icon: Icons.change_history,
            size: 48,
            rotation: 0.8,
            color: Color(0x66FFFFFF),
          ),
        ),
        Positioned(
          bottom: 60,
          right: 40,
          child: _FloatingIcon(
            icon: Icons.celebration,
            size: 72,
            rotation: 0.1,
            color: Color(0x330EA5E9),
          ),
        ),
      ],
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 35,
            offset: const Offset(0, 16),
          ),
        ],
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.5), width: 4),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LogoLetter('K', Color(0xFFEC4899)),
          SizedBox(width: 4),
          _LogoLetter('I', Color(0xFF0EA5E9)),
          SizedBox(width: 4),
          _LogoLetter('D', Color(0xFF22C55E)),
          SizedBox(width: 4),
          _LogoLetter('O', Color(0xFFF97316)),
        ],
      ),
    );
  }
}

class _LogoLetter extends StatelessWidget {
  const _LogoLetter(this.letter, this.color);

  final String letter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      letter,
      style: TextStyle(
        fontSize: 52,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: 2,
      ),
    );
  }
}

class _MascotAvatar extends StatelessWidget {
  const _MascotAvatar();

  static const _imageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDGzijjlGyYKrjJWVhlVKM-QVE-vSpA0UAkcFxIJtPEQxZen9NqtCRwc5aIiiAY7zUxc_OMaNtIPFR7mjk57M09YTXjzX7hI21l8ozVIisgIef97JGVIKnS3x9syiyHCeGyWeiscc_HopDSbQWWsF663WEkWblGSdNtZz-lJI__ECHjLlTpbj-AToEo43oKzu5QjdwsHSiSi1sRt-Ia8wZbaUJ_wq5j_p7vaeaI-Od-c8Hu-lEqcoCIrLzONmf_eP9sATtL-UZMmMM';

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: SizedBox(
        width: 320,
        height: 320,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 50,
                    offset: const Offset(0, 30),
                  ),
                ],
              ),
              child: ClipOval(
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Image.network(
                    _imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                    errorBuilder: (context, _, __) {
                      return Center(child: _buildFallbackBear());
                    },
                  ),
                ),
              ),
            ),
            const Positioned(
              bottom: -16,
              right: 12,
              child: _FloatingIcon(
                icon: Icons.celebration,
                size: 80,
                rotation: 0.1,
                color: Color(0x330EA5E9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackBear() {
    return CustomPaint(
      size: const Size(180, 180),
      painter: BearPainter(),
    );
  }
}

class _LoaderFooter extends StatelessWidget {
  const _LoaderFooter({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'LOADING FUN...',
          style: TextStyle(
            fontSize: 13,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w700,
            color: Color(0x991C190D),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: SizedBox(
            height: 16,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth * clamped;
                final minFill = constraints.maxWidth * 0.08;
                final barWidth =
                    clamped == 0 ? minFill : math.max(width, minFill);
                return Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: barWidth,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEC4899),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'v1.0.2',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0x801C190D),
          ),
        ),
      ],
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  const _FloatingIcon({
    required this.icon,
    this.size = 48,
    this.rotation = 0,
    this.color = const Color(0x66FFFFFF),
  });

  final IconData icon;
  final double size;
  final double rotation;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  const _BlurBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: 50, sigmaY: 50),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class BearPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Body (brown circle)
    final bodyPaint = Paint()..color = const Color(0xFF8B4513);
    canvas.drawCircle(center, size.width * 0.4, bodyPaint);

    // Head (slightly smaller brown circle)
    final headPaint = Paint()..color = const Color(0xFF8B4513);
    canvas.drawCircle(
      Offset(center.dx, center.dy - size.width * 0.15),
      size.width * 0.35,
      headPaint,
    );

    // Ears
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.2, center.dy - size.width * 0.3),
      size.width * 0.12,
      headPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.2, center.dy - size.width * 0.3),
      size.width * 0.12,
      headPaint,
    );

    // Rosy cheeks
    final cheekPaint = Paint()..color = const Color(0xFFFFB6C1);
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.15, center.dy - size.width * 0.05),
      size.width * 0.08,
      cheekPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.15, center.dy - size.width * 0.05),
      size.width * 0.08,
      cheekPaint,
    );

    // Eyes
    final eyePaint = Paint()..color = Colors.black;
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.1, center.dy - size.width * 0.15),
      size.width * 0.04,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.1, center.dy - size.width * 0.15),
      size.width * 0.04,
      eyePaint,
    );

    // Nose
    final nosePaint = Paint()..color = Colors.black;
    canvas.drawCircle(
      Offset(center.dx, center.dy - size.width * 0.05),
      size.width * 0.03,
      nosePaint,
    );

    // Mouth (smile)
    final mouthPath = Path();
    mouthPath.addArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy),
        width: size.width * 0.2,
        height: size.width * 0.15,
      ),
      0,
      math.pi,
    );
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(mouthPath, mouthPaint);

    // Arms (outstretched)
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.35, center.dy),
      size.width * 0.1,
      bodyPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.35, center.dy),
      size.width * 0.1,
      bodyPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
