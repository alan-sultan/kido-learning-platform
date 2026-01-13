import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2CC0D),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              top: -60,
              left: -60,
              child: _BlurBlob(
                size: 180,
                color: Color(0x33FFFFFF),
              ),
            ),
            const Positioned(
              top: 140,
              right: -40,
              child: _BlurBlob(
                size: 140,
                color: Color(0x33F97316),
              ),
            ),
            const Positioned(
              bottom: 160,
              left: -30,
              child: _BlurBlob(
                size: 170,
                color: Color(0x33EC4899),
              ),
            ),
            const Positioned(
              bottom: -80,
              right: -70,
              child: _BlurBlob(
                size: 240,
                color: Color(0x26FFFFFF),
              ),
            ),
            const Positioned(
              top: 48,
              right: 36,
              child: _FloatingIcon(
                icon: Icons.star_rounded,
                size: 54,
                rotation: 0.3,
              ),
            ),
            const Positioned(
              top: 110,
              left: 32,
              child: _FloatingIcon(
                icon: Icons.pentagon_outlined,
                size: 42,
                rotation: -0.25,
              ),
            ),
            const Positioned(
              bottom: 160,
              left: 40,
              child: _FloatingIcon(
                icon: Icons.change_history,
                size: 44,
                rotation: 0.8,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  const _LogoBadge(),
                  const SizedBox(height: 18),
                  Text(
                    "Let's Play & Learn!",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1C190D),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  const _MascotAvatar(),
                  const SizedBox(height: 36),
                  const _LoaderCard(),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(80),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.5), width: 4),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LogoLetter('K', Color(0xFFEC4899)),
          SizedBox(width: 2),
          _LogoLetter('I', Color(0xFF0EA5E9)),
          SizedBox(width: 2),
          _LogoLetter('D', Color(0xFF22C55E)),
          SizedBox(width: 2),
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 260,
          height: 260,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 45,
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
          bottom: -12,
          right: 8,
          child: _FloatingIcon(
            icon: Icons.celebration,
            size: 74,
            rotation: 0.1,
            color: Color(0x4D0EA5E9),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackBear() {
    return CustomPaint(
      size: const Size(180, 180),
      painter: BearPainter(),
    );
  }
}

class _LoaderCard extends StatelessWidget {
  const _LoaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(30),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'LOADING FUN...',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 13,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                  color: const Color(0x991C190D),
                ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 12,
              backgroundColor: Colors.white.withValues(alpha: 0.35),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFEC4899)),
              value: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'v1.0.2',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0x801C190D),
            ),
          ),
        ],
      ),
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
