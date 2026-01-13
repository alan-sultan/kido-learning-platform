import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'social_login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F5),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              top: -120,
              right: -120,
              child: _BlurBubble(
                size: 240,
                color: Color(0x33F2CC0D),
              ),
            ),
            const Positioned(
              top: 260,
              left: -100,
              child: _BlurBubble(
                size: 180,
                color: Color(0x1A0EA5E9),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  const _LogoEmblem(),
                  const SizedBox(height: 8),
                  Text(
                    'KIDO',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1C190D),
                          letterSpacing: -1,
                        ),
                  ),
                  const SizedBox(height: 28),
                  const _HeroCard(),
                  const SizedBox(height: 30),
                  Text(
                    'Ready to Play & Learn?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF1C190D),
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Join the fun world of KIDO and discover new things every day!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xB31C190D),
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 26),
                  _PrimaryCta(
                    label: "Let's Play!",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SocialLoginScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  _ParentsButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoEmblem extends StatelessWidget {
  const _LogoEmblem();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Icon(
        Icons.smart_toy,
        color: Color(0xFFF2CC0D),
        size: 42,
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  static const _imageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuD7NfxmkreYR3CE3OfcovPJQzZUJnQgB7m3EjMbshwPvJoM9E-CTtQWeemUbMtQJs7_vO5dHdyE3Whwrpfj7ZIvI8c-2HBfdOmjc79CgrLQir1dhZ-DE5lceZE91kEcOAugQdqYIvKi0G_IJRVdNhURgjA2FkYWx8iCSF4EKYqwu5zYz7oXvtREqjoitUhteSeOzrG81YCJljTsI3fFcdTy54v61LR3CEkyxdbFZUgjCv12wzYmbzmmHgtDCmCI6ttLwDdyDkFnV8I';

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 180,
      child: SizedBox(
        width: double.infinity,
        child: AspectRatio(
          aspectRatio: 4 / 5,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: Colors.black12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        _imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0x66000000), Colors.transparent],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: Color(0xFFFF8A3C),
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'FUN!',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1C190D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF2CC0D),
          minimumSize: const Size.fromHeight(64),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          shadowColor: const Color(0x80D9B405),
          elevation: 6,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: Icon(
                Icons.play_arrow,
                color: Color(0xFFF2CC0D),
              ),
            ),
            SizedBox(width: 12),
            Text(
              "Let's Play!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1C190D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParentsButton extends StatelessWidget {
  const _ParentsButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        foregroundColor: const Color(0xFF9C8E49),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: const Icon(Icons.admin_panel_settings, size: 20),
      label: const Text(
        'Parents Login',
        style: TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BlurBubble extends StatelessWidget {
  const _BlurBubble({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: 45, sigmaY: 45),
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
