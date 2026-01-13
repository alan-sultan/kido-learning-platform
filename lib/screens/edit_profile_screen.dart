import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/avatar_catalog.dart';
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
      backgroundColor: const Color(0xFFF8F8F5),
      body: SafeArea(
        child: Column(
          children: [
            _HeaderBar(
              title: isNewProfile ? 'Create Profile' : 'Edit Profile',
              onBack: _isSaving ? null : () => Navigator.pop(context),
              onCancel: _isSaving ? null : () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 160),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AvatarHero(
                      imageUrl:
                          AvatarCatalog.byKey(_selectedAvatarKey).imageUrl,
                      onTap: _isSaving
                          ? null
                          : () {
                              // placeholder for avatar change
                            },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tap to change photo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF9FA4B0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'What is your name?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1C190D),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _NameField(controller: _nameController),
                    const SizedBox(height: 32),
                    const Text(
                      'Pick your character!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1C190D),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _CharacterGrid(
                      selectedKey: _selectedAvatarKey,
                      onSelect: (value) {
                        setState(() => _selectedAvatarKey = value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            _SaveBar(
              isSaving: _isSaving,
              onSave: _isSaving ? null : _handleSave,
            ),
          ],
        ),
      ),
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
}


class _HeaderBar extends StatelessWidget {
  const _HeaderBar({
    required this.title,
    required this.onBack,
    required this.onCancel,
  });

  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          _CircleButton(icon: Icons.arrow_back, onTap: onBack),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1C190D),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onCancel,
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF8D8A80),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 6,
        shadowColor: Colors.black12,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Icon(icon, color: const Color(0xFF1C190D)),
        ),
      ),
    );
  }
}

class _AvatarHero extends StatelessWidget {
  const _AvatarHero({required this.imageUrl, this.onTap});

  final String imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          ImageFiltered(
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
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF2CC0D), width: 6),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2DED0), width: 2),
              ),
              child: const Icon(Icons.photo_camera, color: Color(0xFFF2CC0D)),
            ),
          ),
        ],
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E4D6), width: 3),
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
        maxLength: 18,
        decoration: const InputDecoration(
          counterText: '',
          hintText: 'Type your name here...',
          hintStyle: TextStyle(color: Color(0xFFA59A7E)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1C190D),
        ),
      ),
    );
  }
}

class _CharacterGrid extends StatelessWidget {
  const _CharacterGrid({
    required this.selectedKey,
    required this.onSelect,
  });

  final String selectedKey;
  final ValueChanged<String> onSelect;

  static final _keys = ChildProfile.defaultAvatars;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: _keys.length + 1,
      itemBuilder: (context, index) {
        if (index == _keys.length) {
          return const _AddAvatarTile();
        }
        final key = _keys[index];
        return _AvatarTile(
          avatarKey: key,
          isSelected: key == selectedKey,
          onTap: () => onSelect(key),
        );
      },
    );
  }
}

class _AvatarTile extends StatelessWidget {
  const _AvatarTile({
    required this.avatarKey,
    required this.isSelected,
    required this.onTap,
  });

  final String avatarKey;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = AvatarCatalog.byKey(avatarKey);
    final accent = avatar.accent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? accent : Colors.transparent,
            width: 3,
          ),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 6,
              right: 6,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1 : 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 12, color: Colors.black),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      avatar.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  avatarKey.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7A7465),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddAvatarTile extends StatelessWidget {
  const _AddAvatarTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE0DCCB),
          width: 2,
        ),
        color: const Color(0xFFF3F1E6),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, color: Color(0xFFA7A08B), size: 32),
          SizedBox(height: 8),
          Text(
            'Add New',
            style: TextStyle(
              color: Color(0xFFA7A08B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.isSaving, required this.onSave});

  final bool isSaving;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF8F8F5), Color(0x00F8F8F5)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: ElevatedButton(
        onPressed: onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF2CC0D),
          foregroundColor: const Color(0xFF1C190D),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 8,
          shadowColor: const Color(0x40D9B405),
        ),
        child: isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
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
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.check_circle_outline),
                ],
              ),
      ),
    );
  }
}
