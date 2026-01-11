import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/child_profile.dart';
import '../services/app_services.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, this.profile});

  final ChildProfile? profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late String _selectedAvatarKey;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile?.name ?? '');
    _selectedAvatarKey =
        widget.profile?.avatarKey ?? ChildProfile.defaultAvatars.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNewProfile = widget.profile == null;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _isSaving ? null : () => Navigator.pop(context),
        ),
        title: Text(
          isNewProfile ? 'Create Profile' : 'Edit Profile',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                _buildPreviewCard(),
                const SizedBox(height: 40),
                const Text(
                  "What's your explorer's name?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                _buildNameField(),
                const SizedBox(height: 40),
                const Text(
                  'Pick an avatar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                _buildAvatarGrid(),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.black),
                              SizedBox(width: 8),
                              Text(
                                'Save Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    final bgColor = _avatarColor(_selectedAvatarKey);
    return Column(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: bgColor.withAlpha(60),
            shape: BoxShape.circle,
            border: Border.all(color: bgColor, width: 4),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: CustomPaint(
              painter: _ExplorerAvatarPainter(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _selectedAvatarKey.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: bgColor.darken(),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _nameController,
        maxLength: 18,
        decoration: InputDecoration(
          counterText: '',
          hintText: 'Explorer name',
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarGrid() {
    const avatars = ChildProfile.defaultAvatars;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: avatars.length,
      itemBuilder: (context, index) {
        final avatarKey = avatars[index];
        final isSelected = avatarKey == _selectedAvatarKey;
        final color = _avatarColor(avatarKey);
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedAvatarKey = avatarKey;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: color.withAlpha(40),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                avatarKey.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color.darken(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a name for your explorer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = AppServices.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to update profiles'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final repository = AppServices.childProfiles;
    try {
      if (widget.profile == null) {
        final newProfile = ChildProfile(
          id: repository.newProfileId(user.uid),
          name: name,
          avatarKey: _selectedAvatarKey,
          level: 1,
          stars: 0,
          streak: 0,
          totalLessons: 0,
          totalQuizzes: 0,
          badges: const <String>[],
          birthday: null,
        );
        await repository.createProfile(user.uid, newProfile);
      } else {
        final updated = widget.profile!.copyWith(
          name: name,
          avatarKey: _selectedAvatarKey,
        );
        await repository.updateProfile(user.uid, updated);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Color _avatarColor(String key) {
    switch (key) {
      case 'bunny':
        return Colors.pink[200]!;
      case 'fox':
        return Colors.deepOrange;
      case 'alien':
        return Colors.lightBlue;
      case 'monster':
        return Colors.purple;
      case 'bear':
      default:
        return Colors.orange;
    }
  }
}

class _ExplorerAvatarPainter extends CustomPainter {
  const _ExplorerAvatarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final headPaint = Paint()..color = const Color(0xFFD4A574);
    canvas.drawCircle(center, size.width * 0.45, headPaint);

    final hairPaint = Paint()..color = const Color(0xFF8B4513);
    final hairPath = Path();
    hairPath.addArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - size.height * 0.1),
        width: size.width * 0.9,
        height: size.width * 0.5,
      ),
      math.pi,
      math.pi,
    );
    canvas.drawPath(hairPath, hairPaint);

    final eyePaint = Paint()..color = Colors.black;
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.18, center.dy - size.height * 0.05),
      size.width * 0.06,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.18, center.dy - size.height * 0.05),
      size.width * 0.06,
      eyePaint,
    );

    final smilePath = Path();
    smilePath.addArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + size.height * 0.1),
        width: size.width * 0.4,
        height: size.width * 0.25,
      ),
      0,
      math.pi,
    );
    final smilePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(smilePath, smilePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension on Color {
  Color darken([double amount = .2]) {
    final hsl = HSLColor.fromColor(this);
    final adjusted =
        hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return adjusted.toColor();
  }
}
