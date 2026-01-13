import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'login_screen.dart';
import '../services/app_services.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  final _authService = AppServices.auth;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      _CircleButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        const _HeroArt(),
                        const SizedBox(height: 24),
                        const _IntroCopy(),
                        const SizedBox(height: 24),
                        _EmailField(controller: _emailController),
                        const SizedBox(height: 24),
                        _SendButton(
                          isLoading: _isLoading,
                          onPressed:
                              _isLoading ? null : () => _handleSendMagicLink(),
                        ),
                        const SizedBox(height: 32),
                        _LoginLink(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const _BottomHint(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSendMagicLink() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.sendPasswordResetEmail(_emailController.text.trim());

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Password reset email sent to ${_emailController.text.trim()}!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
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
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_back),
      color: const Color(0xFF1C190D),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        elevation: 0,
        minimumSize: const Size(48, 48),
      ),
    );
  }
}

class _HeroArt extends StatelessWidget {
  const _HeroArt();

  static const _imageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCqVErbhws4EscvPSFTfwtwzbPVZcYld59cDeW6MNbgj1v55ytKcRnoUDhNCOrnxE4kDNijREL2Ij7USioVMWPt4r0sUMXPRbfUxit04xdCtZpoxGc_42Vy6Ckti1YSQxjSppmXFovD6YjAvH9MgBBOkQcNPQRa16MPUfFi3v9qhfr8Cvvs-YdAm0U_jXQc5n52k4d7LE3R95YPJkM2d8QS4MiP2KPLXTkNx489PYBBu78VP8YHhxng2mF09UmZzwFAgWSTukfrr5A';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _DashedCirclePainter(
                    color: const Color(0xFFF2CC0D).withValues(alpha: 0.4),
                  ),
                ),
              ),
              Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  color: Color(0x33F2CC0D),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(_imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: -6,
                right: -6,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2CC0D),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: const Icon(Icons.lock_reset, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IntroCopy extends StatelessWidget {
  const _IntroCopy();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Oops! Forgot it?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1C190D),
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Type in your parent's email address and we will send a magic link to fix it!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xAA1C190D),
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE8E4CE), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          hintText: 'Enter email here...',
          hintStyle: TextStyle(color: Color(0xFFB3A87A)),
          prefixIcon: Icon(Icons.mail_outline, color: Color(0xFF9C8E49)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF2CC0D),
        foregroundColor: const Color(0xFF1C190D),
        minimumSize: const Size.fromHeight(64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        elevation: 6,
        shadowColor: const Color(0x35D9B405),
      ),
      child: isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Color(0xFF1C190D)),
              ),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Send Magic Link',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.auto_fix_high),
              ],
            ),
    );
  }
}

class _LoginLink extends StatelessWidget {
  const _LoginLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: const Text.rich(
        TextSpan(
          text: 'Remembered it? ',
          style:
              TextStyle(color: Color(0xFF8E8463), fontWeight: FontWeight.w600),
          children: [
            TextSpan(
              text: 'Log In',
              style: TextStyle(
                color: Color(0xFF1C190D),
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomHint extends StatelessWidget {
  const _BottomHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: const Text(
        'We will send a single-use magic link to your parent. Make sure to double-check the email!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: Color(0xFF9E9480),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final radius = size.width / 2;
    const segments = 32;
    const dashPortion = 0.6;
    const step = (2 * math.pi) / segments;
    for (int i = 0; i < segments; i++) {
      final start = i * step;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius - 2),
        start,
        step * dashPortion,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
