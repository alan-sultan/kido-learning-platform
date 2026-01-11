import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/app_services.dart';
import '../services/navigation_service.dart';
import '../services/preferences_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _musicEnabled = true;
  bool _soundsEnabled = true;
  String _selectedTheme = 'Sunny';
  bool _loadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await PreferencesService.instance.getPreferences();
      if (!mounted) return;
      setState(() {
        _musicEnabled = prefs.musicEnabled;
        _soundsEnabled = prefs.soundsEnabled;
        _selectedTheme = prefs.theme;
        _loadingPrefs = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingPrefs = false;
      });
      NavigationService.showSnackBar(
        SnackBar(
          content: Text('Could not load settings: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updatePreferences({
    bool? musicEnabled,
    bool? soundsEnabled,
    String? theme,
  }) async {
    if (_loadingPrefs) return;

    final lastState = (
      music: _musicEnabled,
      sounds: _soundsEnabled,
      theme: _selectedTheme,
    );

    setState(() {
      if (musicEnabled != null) {
        _musicEnabled = musicEnabled;
      }
      if (soundsEnabled != null) {
        _soundsEnabled = soundsEnabled;
      }
      if (theme != null) {
        _selectedTheme = theme;
      }
    });

    try {
      final snapshot = await PreferencesService.instance.updatePreferences(
        musicEnabled: musicEnabled,
        soundsEnabled: soundsEnabled,
        theme: theme,
      );
      if (!mounted) return;
      setState(() {
        _musicEnabled = snapshot.musicEnabled;
        _soundsEnabled = snapshot.soundsEnabled;
        _selectedTheme = snapshot.theme;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _musicEnabled = lastState.music;
        _soundsEnabled = lastState.sounds;
        _selectedTheme = lastState.theme;
      });
      NavigationService.showSnackBar(
        SnackBar(
          content: Text('Could not save settings: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Music & Sounds section
                    const Text(
                      'Music & Sounds',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Music toggle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.purple[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.music_note,
                              color: Colors.purple[700],
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Music',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Fun tunes!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _musicEnabled,
                            onChanged: _loadingPrefs
                                ? null
                                : (value) => _updatePreferences(
                                      musicEnabled: value,
                                    ),
                            thumbColor:
                                WidgetStatePropertyAll(Colors.amber[700]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Sounds toggle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.volume_up,
                              color: Colors.blue[700],
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Sounds',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Click & pop!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _soundsEnabled,
                            onChanged: _loadingPrefs
                                ? null
                                : (value) => _updatePreferences(
                                      soundsEnabled: value,
                                    ),
                            thumbColor:
                                WidgetStatePropertyAll(Colors.amber[700]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Pick a Theme section
                    const Text(
                      'Pick a Theme!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildThemeCard(
                            'Sunny',
                            Colors.amber[700]!,
                            Icons.wb_sunny,
                            isSelected: _selectedTheme == 'Sunny',
                            onTap: _loadingPrefs
                                ? null
                                : () => _updatePreferences(theme: 'Sunny'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildThemeCard(
                            'Space',
                            Colors.purple[700]!,
                            Icons.rocket_launch,
                            isSelected: _selectedTheme == 'Space',
                            onTap: _loadingPrefs
                                ? null
                                : () => _updatePreferences(theme: 'Space'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // For Grown-ups section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'For Grown-ups',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleSignOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100), // Space for bear character
                  ],
                ),
              ),
            ),
            // Bear character at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: CustomPaint(
                  size: const Size(80, 80),
                  painter: SettingsBearCharacterPainter(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(
    String name,
    Color color,
    IconData icon, {
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: isSelected ? 3 : 0,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignOut() async {
    try {
      await AppServices.auth.signOut();
      NavigationService.popToRoot();
      NavigationService.showSnackBar(
        const SnackBar(
          content: Text('Signed out successfully.'),
          backgroundColor: Colors.black87,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      NavigationService.showSnackBar(
        SnackBar(
          content: Text('Sign-out failed: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

class SettingsBearCharacterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Body (brown circle)
    final bodyPaint = Paint()..color = const Color(0xFF8B4513);
    canvas.drawCircle(center, size.width * 0.4, bodyPaint);

    // Head
    canvas.drawCircle(
      Offset(center.dx, center.dy - size.width * 0.15),
      size.width * 0.35,
      bodyPaint,
    );

    // Ears
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.2, center.dy - size.width * 0.3),
      size.width * 0.12,
      bodyPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.2, center.dy - size.width * 0.3),
      size.width * 0.12,
      bodyPaint,
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
    canvas.drawCircle(
      Offset(center.dx, center.dy - size.width * 0.05),
      size.width * 0.03,
      eyePaint,
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
