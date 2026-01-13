import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'login_screen.dart';
import '../services/app_services.dart';
import '../services/navigation_service.dart';

class SocialLoginScreen extends StatefulWidget {
  const SocialLoginScreen({super.key});

  @override
  State<SocialLoginScreen> createState() => _SocialLoginScreenState();
}

class _SocialLoginScreenState extends State<SocialLoginScreen> {
  final _authService = AppServices.auth;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF8F8F5);
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child:
                      _TopBar(onBack: () => Navigator.of(context).maybePop()),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        const _HeroIllustration(),
                        const SizedBox(height: 24),
                        const _IntroText(),
                        const SizedBox(height: 32),
                        _PrimaryButton(
                          isLoading: _isLoading,
                          onPressed:
                              _isLoading ? null : () => _handleGoogleLogin(),
                        ),
                        const SizedBox(height: 16),
                        _SecondaryButton(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          child: const Text(
                            'Continue as Guest',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9BA2B0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const _LegalText(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await _authService.signInWithGoogle();
      final user = credential?.user ?? _authService.currentUser;
      final successMessage =
          'Signed in as ${user?.email ?? user?.displayName ?? 'your Google account'}';

      if (user != null) {
        _handleAuthSuccess(successMessage);
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'We could not confirm your Google session. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _handleAuthSuccess(String message) {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    NavigationService.popToRoot();
    NavigationService.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleButton(
          icon: Icons.arrow_back,
          onPressed: onBack,
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Text(
            'LOGIN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: Color(0xFF8D8A7F),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration();

  static const _imageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuB7VPIkrVC9tx4u0tYu5iVpyGY5oVP-a8fbjoF5jqx91P1jP5vN9OvrBtyyziSjL5GQqmml02klHXkFSn9e5om32I7zpkYv3nTHTmo2OCs3uhlS8R2YYuAXFiLiEQo7sldPPvcxkjHHvcFBpNmLYRxusmarlNddre0YegnvODDj5KIK1xNPwsnOc5GWmYv7AJcuceJMsZ-shwevr82tMmuUh4FAv5MEjS-SEJLgNsZ8UBVzahO6fXiGOnDorf7GyME_6mPkgD3Ll-I';

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 20,
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 45, sigmaY: 45),
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                color: Color(0x33F2CC0D),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 30,
                  offset: Offset(0, 18),
                ),
              ],
              image: const DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(_imageUrl),
              ),
            ),
          ),
        ),
        Positioned(
          right: 32,
          bottom: -12,
          child: _KidSafeBadge(),
        ),
      ],
    );
  }
}

class _KidSafeBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Color(0xFFE6F8ED),
            child: Icon(
              Icons.verified_user,
              size: 16,
              color: Color(0xFF0F9D58),
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Kid Safe',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C190D),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroText extends StatelessWidget {
  const _IntroText();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Welcome to KIDO!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1C190D),
            height: 1.2,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Sign in to save your progress and keep the fun going!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF7C7A73),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.isLoading, this.onPressed});

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF2CC0D),
        foregroundColor: const Color(0xFF1C190D),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        elevation: 6,
        shadowColor: const Color(0x55D9B405),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 6,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const _GoogleMark(),
            ),
          ),
          isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Color(0xFF1C190D)),
                  ),
                )
              : const Padding(
                  padding: EdgeInsets.only(left: 24),
                  child: Text(
                    'Sign in with Google',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFE8E0CE), width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(vertical: 18),
        backgroundColor: Colors.white,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mail_outline, color: Color(0xFF1C190D)),
          SizedBox(width: 12),
          Text(
            'Continue with Email',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C190D),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalText extends StatelessWidget {
  const _LegalText();

  @override
  Widget build(BuildContext context) {
    return const Text.rich(
      TextSpan(
        text: 'By creating an account or signing in, you agree to our ',
        style: TextStyle(
          fontSize: 11,
          color: Color(0xFF9A9A93),
          height: 1.5,
        ),
        children: [
          TextSpan(
            text: 'Terms of Service',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              color: Color(0xFF1C190D),
            ),
          ),
          TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              color: Color(0xFF1C190D),
            ),
          ),
          TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CustomPaint(
          painter: _GoogleMarkPainter(),
        ),
      ),
    );
  }
}

class _GoogleMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;
    final rect = Offset.zero & size;
    const sweep = math.pi / 2;

    paint
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = 2.5;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, paint);

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0, sweep, false, paint);

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, sweep, sweep, false, paint);

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, sweep * 2, sweep, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1C190D),
          shape: const CircleBorder(),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon),
      ),
    );
  }
}
