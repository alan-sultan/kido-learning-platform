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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'LOGIN',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // White card container
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        // Owl illustration
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const CustomPaint(
                                size: Size(200, 200),
                                painter: OwlCharacterPainter(),
                              ),
                              // Kids Mode tag
                              Positioned(
                                bottom: 20,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Text(
                                    'Kids Mode',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Welcome text
                        const Text(
                          'Welcome to KIDO!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sign in to save your progress and keep the fun going!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        // Google login button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleGoogleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[700],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'G',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Sign in with Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Email login button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.email_outlined,
                                  color: Colors.black87,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Continue with Email',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Footer text
                  Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
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

class OwlCharacterPainter extends CustomPainter {
  const OwlCharacterPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Body (brown oval)
    final bodyPaint = Paint()..color = const Color(0xFF8B4513);
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.6,
        height: size.height * 0.7,
      ),
      bodyPaint,
    );

    // Head (larger brown circle)
    canvas.drawCircle(
      Offset(center.dx, center.dy - size.height * 0.15),
      size.width * 0.35,
      bodyPaint,
    );

    // Glasses
    final glassesPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    // Left lens
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
            center.dx - size.width * 0.15, center.dy - size.height * 0.2),
        width: size.width * 0.25,
        height: size.width * 0.2,
      ),
      glassesPaint,
    );
    // Right lens
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
            center.dx + size.width * 0.15, center.dy - size.height * 0.2),
        width: size.width * 0.25,
        height: size.width * 0.2,
      ),
      glassesPaint,
    );
    // Bridge
    canvas.drawLine(
      Offset(center.dx - size.width * 0.025, center.dy - size.height * 0.2),
      Offset(center.dx + size.width * 0.025, center.dy - size.height * 0.2),
      glassesPaint,
    );

    // Eyes
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.15, center.dy - size.height * 0.2),
      size.width * 0.08,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.15, center.dy - size.height * 0.2),
      size.width * 0.08,
      eyePaint,
    );
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.15, center.dy - size.height * 0.2),
      size.width * 0.04,
      pupilPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.15, center.dy - size.height * 0.2),
      size.width * 0.04,
      pupilPaint,
    );

    // Beak
    final beakPaint = Paint()..color = const Color(0xFFFFA500);
    final beakPath = Path();
    beakPath.moveTo(center.dx, center.dy - size.height * 0.05);
    beakPath.lineTo(
        center.dx - size.width * 0.05, center.dy + size.height * 0.05);
    beakPath.lineTo(
        center.dx + size.width * 0.05, center.dy + size.height * 0.05);
    beakPath.close();
    canvas.drawPath(beakPath, beakPaint);

    // Book (green)
    final bookPaint = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + size.height * 0.25),
          width: size.width * 0.5,
          height: size.height * 0.2,
        ),
        const Radius.circular(5),
      ),
      bookPaint,
    );
    // Book pages (white)
    canvas.drawLine(
      Offset(center.dx, center.dy + size.height * 0.15),
      Offset(center.dx, center.dy + size.height * 0.35),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
