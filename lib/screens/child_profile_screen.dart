import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/avatar_catalog.dart';
import '../models/child_profile.dart';
import '../services/app_services.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class ChildProfileScreen extends StatefulWidget {
  const ChildProfileScreen({super.key});

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {
  late final Future<ChildProfile?> _ensureProfileFuture;
  String? _activeChildId;

  @override
  void initState() {
    super.initState();
    _ensureProfileFuture = AppServices.ensureDefaultChildProfile();
    _activeChildId = AppServices.childSelection.activeChildId;
    AppServices.childSelection.addListener(_handleSelectionServiceUpdate);
  }

  @override
  void dispose() {
    AppServices.childSelection.removeListener(_handleSelectionServiceUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AppServices.auth.currentUser;
    if (user == null) {
      return _buildAuthRequired(context);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F5),
      body: Stack(
        children: [
          const _BackdropBlobs(),
          SafeArea(
            child: Column(
              children: [
                _TopAppBar(
                  onBack: () => Navigator.of(context).maybePop(),
                  onSettings: () {},
                ),
                Expanded(
                  child: FutureBuilder<ChildProfile?>(
                    future: _ensureProfileFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return _buildErrorState(
                          'We could not load profiles. Please try again shortly.',
                        );
                      }

                      return StreamBuilder<List<ChildProfile>>(
                        stream:
                            AppServices.childProfiles.watchProfiles(user.uid),
                        builder: (context, profilesSnapshot) {
                          if (profilesSnapshot.connectionState ==
                                  ConnectionState.waiting &&
                              !profilesSnapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (profilesSnapshot.hasError) {
                            return _buildErrorState(
                                'Unable to load profiles right now.');
                          }

                          final profiles = profilesSnapshot.data ?? const [];
                          if (profiles.isEmpty) {
                            return _buildEmptyState(context);
                          }

                          final selectedProfile =
                              _selectedProfileFromList(profiles);
                          return _buildProfileBody(
                              context, profiles, selectedProfile);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(2),
    );
  }

  Widget _buildProfileBody(
    BuildContext context,
    List<ChildProfile> profiles,
    ChildProfile profile,
  ) {
    final badgeLabel = profile.badges.isNotEmpty
        ? '+ ${profile.badges.first.toUpperCase()}'
        : '+ SUPER LEARNER';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
      child: Column(
        children: [
          if (profiles.length > 1) ...[
            const SizedBox(height: 12),
            _buildProfileSelector(profiles, profile.id),
          ],
          const SizedBox(height: 16),
          _buildProfileHeader(profile, badgeLabel),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.hub,
                  iconColor: const Color(0xFF2563EB),
                  value: profile.level.toString(),
                  label: 'CURRENT LEVEL',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.star,
                  iconColor: const Color(0xFFEAB308),
                  value: profile.stars.toString(),
                  label: 'STARS EARNED',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openEditProfile(profile),
              icon: const Icon(Icons.edit, color: Color(0xFF1C190D)),
              label: const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C190D),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2CC0D),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                elevation: 6,
                shadowColor: const Color(0x40D9B405),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildListTile(
            icon: Icons.emoji_events,
            iconColor: const Color(0xFFF97316),
            title: 'My Achievements',
            subtitle: 'View your trophies and badges',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildListTile(
            icon: Icons.switch_account,
            iconColor: const Color(0xFFA855F7),
            title: 'Switch Profile',
            subtitle: 'Log in as another child',
            onTap: () => _showProfilePicker(profiles),
          ),
          const SizedBox(height: 12),
          _buildListTile(
            icon: Icons.add_circle_outline,
            iconColor: const Color(0xFF0EA5E9),
            title: 'Add New Explorer',
            subtitle: 'Create another playful learner',
            onTap: _handleAddProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ChildProfile profile, String badgeLabel) {
    final avatar = AvatarCatalog.byKey(profile.avatarKey);
    final accent = avatar.accent;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 45, sigmaY: 45),
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accent, width: 6),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 30,
                    offset: Offset(0, 18),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  avatar.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 24,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                    Icon(Icons.stars, color: Color(0xFFF97316), size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Kid Safe',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C190D),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          profile.name,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1C190D),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt, color: accent, size: 16),
              const SizedBox(width: 6),
              Text(
                badgeLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: accent.darken(),
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSelector(
    List<ChildProfile> profiles,
    String selectedId,
  ) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: profiles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final profile = profiles[index];
          final isSelected = profile.id == selectedId;
          final avatar = AvatarCatalog.byKey(profile.avatarKey);
          final color = avatar.accent;
          return GestureDetector(
            onTap: () => _onSelectProfile(profile.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? color : Colors.transparent,
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.network(
                        avatar.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    profile.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFF1C190D)
                          : const Color(0xFF8F8A7A),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  ChildProfile _selectedProfileFromList(List<ChildProfile> profiles) {
    final serviceActiveId = AppServices.childSelection.activeChildId;
    final candidateId = serviceActiveId ?? _activeChildId;

    ChildProfile selected;
    if (candidateId != null) {
      selected = profiles.firstWhere(
        (profile) => profile.id == candidateId,
        orElse: () => profiles.first,
      );
    } else {
      selected = profiles.first;
    }

    final bool serviceNeedsUpdate =
        serviceActiveId == null || selected.id != serviceActiveId;
    final bool localNeedsUpdate = _activeChildId != selected.id;

    if (serviceNeedsUpdate || localNeedsUpdate) {
      _scheduleSelectionSync(
        selected.id,
        notifyService: serviceNeedsUpdate,
      );
    }

    return selected;
  }

  void _onSelectProfile(String profileId) {
    if (_activeChildId == profileId) return;
    setState(() {
      _activeChildId = profileId;
    });
    AppServices.childSelection.selectProfile(profileId);
  }

  Future<void> _openEditProfile(ChildProfile profile) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(profile: profile),
      ),
    );
  }

  Future<void> _handleAddProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditProfileScreen(),
      ),
    );
  }

  Future<void> _showProfilePicker(List<ChildProfile> profiles) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Choose Explorer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...profiles.map(
                  (profile) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _withOpacity(
                        AvatarCatalog.byKey(profile.avatarKey).accent,
                        0.2,
                      ),
                      child: Text(
                        profile.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    title: Text(profile.name),
                    trailing: profile.id == _activeChildId
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      _onSelectProfile(profile.id);
                    },
                  ),
                ),
                const Divider(),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleAddProfile();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add another explorer'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _scheduleSelectionSync(
    String childId, {
    required bool notifyService,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_activeChildId != childId) {
        setState(() {
          _activeChildId = childId;
        });
      }
      if (notifyService) {
        AppServices.childSelection.selectProfile(childId);
      }
    });
  }

  void _handleSelectionServiceUpdate() {
    final serviceActiveId = AppServices.childSelection.activeChildId;
    if (serviceActiveId == null || serviceActiveId == _activeChildId) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _activeChildId = serviceActiveId;
    });
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1C190D),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8A8266),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Pull to refresh or try again later.',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _BackdropBlobs(),
            const SizedBox(height: 24),
            const Text(
              'Ready to create your explorer?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1C190D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Add your child profile to track levels, stars, and adventures.',
              style: TextStyle(fontSize: 16, color: Color(0xFF8E8879)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await AppServices.ensureDefaultChildProfile();
                if (mounted) setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2CC0D),
                foregroundColor: const Color(0xFF1C190D),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                elevation: 6,
                shadowColor: const Color(0x35D9B405),
              ),
              child: const Text(
                'Create Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthRequired(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please sign in to view your child profile.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _withOpacity(Color color, double opacity) {
    final alpha = (opacity * 255).round().clamp(0, 255).toInt();
    return color.withAlpha(alpha);
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C190D),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8E8879),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFB0A999)),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(int selectedIndex) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
          border: Border.all(color: const Color(0xFFEAE4D2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home, 0, selectedIndex),
            _buildNavItem(Icons.map, 1, selectedIndex),
            _buildProfileNavItem(selectedIndex == 2),
            _buildNavItem(Icons.school, 3, selectedIndex),
            _buildNavItem(Icons.settings, 4, selectedIndex),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, int selectedIndex) {
    final isSelected = index == selectedIndex;
    return IconButton(
      onPressed: () {},
      icon: Icon(icon),
      color: isSelected ? const Color(0xFFF2CC0D) : const Color(0xFF9B9480),
    );
  }

  Widget _buildProfileNavItem(bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xFFF2CC0D) : Colors.white,
        boxShadow: isSelected
            ? const [
                BoxShadow(
                  color: Color(0x33F2CC0D),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(12),
      child: Icon(
        Icons.person,
        color: isSelected ? const Color(0xFF1C190D) : const Color(0xFF9B9480),
        size: 28,
      ),
    );
  }
}

class _BackdropBlobs extends StatelessWidget {
  const _BackdropBlobs();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -120,
          left: -80,
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                color: Color(0x33F2CC0D),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -160,
          right: -120,
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(
              width: 360,
              height: 360,
              decoration: const BoxDecoration(
                color: Color(0x33C084FC),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopAppBar extends StatelessWidget {
  const _TopAppBar({required this.onBack, required this.onSettings});

  final VoidCallback onBack;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          _CircleIconButton(icon: Icons.arrow_back_ios_new, onTap: onBack),
          const Spacer(),
          const Text(
            'KIDO',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1C190D),
            ),
          ),
          const Spacer(),
          _CircleIconButton(icon: Icons.settings, onTap: onSettings),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 3,
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
extension _ColorShade on Color {
  Color darken([double amount = .2]) {
    final hsl = HSLColor.fromColor(this);
    final adjusted =
        hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return adjusted.toColor();
  }
}
