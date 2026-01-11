import 'dart:math' as math;
import 'package:flutter/material.dart';

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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'KIDO',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<ChildProfile?>(
          future: _ensureProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorState(
                'We could not load profiles. Please try again shortly.',
              );
            }

            return StreamBuilder<List<ChildProfile>>(
              stream: AppServices.childProfiles.watchProfiles(user.uid),
              builder: (context, profilesSnapshot) {
                if (profilesSnapshot.connectionState ==
                        ConnectionState.waiting &&
                    !profilesSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (profilesSnapshot.hasError) {
                  return _buildErrorState('Unable to load profiles right now.');
                }

                final profiles = profilesSnapshot.data ?? const [];
                if (profiles.isEmpty) {
                  return _buildEmptyState(context);
                }

                final selectedProfile = _selectedProfileFromList(profiles);
                return _buildProfileBody(context, profiles, selectedProfile);
              },
            );
          },
        ),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            _buildProfileSelector(profiles, profile.id),
            const SizedBox(height: 24),
            Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color:
                            _withOpacity(_avatarColor(profile.avatarKey), 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _avatarColor(profile.avatarKey),
                          width: 3,
                        ),
                      ),
                      child: CustomPaint(
                        size: const Size(120, 120),
                        painter: ChildAvatarPainter(),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.amber[700],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
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
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    badgeLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.person,
                        iconColor: Colors.blue[700]!,
                        value: profile.level.toString(),
                        label: 'CURRENT LEVEL',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.star,
                        iconColor: Colors.amber[700]!,
                        value: profile.stars.toString(),
                        label: 'STARS EARNED',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _openEditProfile(profile),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.black,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Edit Profile',
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
                const SizedBox(height: 16),
                _buildListTile(
                  icon: Icons.emoji_events,
                  iconColor: Colors.amber[700]!,
                  title: 'My Achievements',
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildListTile(
                  icon: Icons.switch_account,
                  iconColor: Colors.purple,
                  title: 'Switch Profile',
                  onTap: () => _showProfilePicker(profiles),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _handleAddProfile,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.amber[700]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: Icon(Icons.add, color: Colors.amber[700]!),
                    label: Text(
                      'Add New Explorer',
                      style: TextStyle(
                        color: Colors.amber[700],
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSelector(
    List<ChildProfile> profiles,
    String selectedId,
  ) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: profiles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final profile = profiles[index];
          final isSelected = profile.id == selectedId;
          final color = _avatarColor(profile.avatarKey);
          return GestureDetector(
            onTap: () => _onSelectProfile(profile.id),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _withOpacity(color, 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? color : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: CustomPaint(
                      painter: ChildAvatarPainter(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 80,
                  child: Text(
                    profile.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
                      backgroundColor:
                          _withOpacity(_avatarColor(profile.avatarKey), 0.2),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: iconColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Ready to create your explorer?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Add your child profile to track levels, stars, and adventures.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await AppServices.ensureDefaultChildProfile();
                if (mounted) setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Create Profile',
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

  Color _withOpacity(Color color, double opacity) {
    final alpha = (opacity * 255).round().clamp(0, 255).toInt();
    return color.withAlpha(alpha);
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _withOpacity(iconColor, 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        trailing:
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
        onTap: onTap,
      ),
    );
  }

  Widget _buildBottomNavigationBar(int selectedIndex) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        boxShadow: [
          BoxShadow(
            color: _withOpacity(Colors.black, 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 0, selectedIndex),
          _buildNavItem(Icons.play_circle_outline, 1, selectedIndex),
          _buildNavItem(Icons.person, 2, selectedIndex),
          _buildNavItem(Icons.settings, 3, selectedIndex),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, int selectedIndex) {
    final isSelected = index == selectedIndex;
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber[700] : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

class ChildAvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Head (circle)
    final headPaint = Paint()..color = const Color(0xFFD4A574);
    canvas.drawCircle(center, size.width * 0.4, headPaint);

    // Hair
    final hairPaint = Paint()..color = const Color(0xFF8B4513);
    final hairPath = Path();
    hairPath.addArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - size.height * 0.1),
        width: size.width * 0.7,
        height: size.width * 0.5,
      ),
      math.pi,
      math.pi,
    );
    canvas.drawPath(hairPath, hairPaint);

    // Face features
    final facePaint = Paint()..color = Colors.black;
    // Eyes
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.12, center.dy - size.height * 0.05),
      size.width * 0.04,
      facePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.12, center.dy - size.height * 0.05),
      size.width * 0.04,
      facePaint,
    );

    // Smile
    final smilePath = Path();
    smilePath.addArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + size.height * 0.05),
        width: size.width * 0.25,
        height: size.width * 0.15,
      ),
      0,
      math.pi,
    );
    final smilePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(smilePath, smilePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
