import 'package:flutter/material.dart';

import '../services/app_services.dart';
import '../services/navigation_service.dart';
import '../services/preferences_service.dart';

const _kSettingsBackground = Color(0xFFF8F8F5);
const _kSettingsPrimary = Color(0xFFF2CC0D);
const _kSettingsPrimaryDark = Color(0xFFD9B600);
const _kSettingsTextMain = Color(0xFF1C190D);
const _kSettingsTextMuted = Color(0xFF9C8E49);
const _kSettingsCardBorder = Color(0xFFE6E0C9);
const _kSettingsCardBg = Color(0xFFFFFFFF);

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
    final toggleValues = <String, bool>{
      'music': _musicEnabled,
      'sounds': _soundsEnabled,
    };

    return Scaffold(
      backgroundColor: _kSettingsBackground,
      body: SafeArea(
        child: Stack(
          children: [
            const _SettingsBackgroundDecor(),
            Column(
              children: [
                _SettingsHeader(onBack: () => Navigator.pop(context)),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionHeading(
                          icon: Icons.music_note,
                          iconBackground: Color(0x33F2CC0D),
                          title: 'Music & Sounds',
                        ),
                        const SizedBox(height: 16),
                        ..._toggleConfigs.map(
                          (config) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _SettingsToggleCard(
                              config: config,
                              value: toggleValues[config.id] ?? false,
                              disabled: _loadingPrefs,
                              onChanged: (value) =>
                                  _handleToggleChange(config.id, value),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const _SectionHeading(
                          icon: Icons.palette,
                          iconBackground: Color(0x332568EB),
                          title: 'Pick a Theme!',
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 230,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            itemBuilder: (context, index) {
                              final option = _themeOptions[index];
                              return _ThemeOptionCard(
                                option: option,
                                selected: option.id == _selectedTheme,
                                disabled: _loadingPrefs,
                                onTap: () =>
                                    _updatePreferences(theme: option.id),
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 16),
                            itemCount: _themeOptions.length,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _GrownUpsButton(onPressed: _handleGrownUpsTap),
                        const SizedBox(height: 24),
                        _SignOutButton(onPressed: _handleSignOut),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const _SettingsMascot(),
          ],
        ),
      ),
    );
  }

  void _handleToggleChange(String id, bool value) {
    if (_loadingPrefs) return;
    switch (id) {
      case 'music':
        _updatePreferences(musicEnabled: value);
        break;
      case 'sounds':
        _updatePreferences(soundsEnabled: value);
        break;
    }
  }

  void _handleGrownUpsTap() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ParentControlsSheet(
        userEmail: AppServices.auth.currentUser?.email ?? 'Family account',
        musicEnabled: _musicEnabled,
        soundsEnabled: _soundsEnabled,
        themeName: _selectedTheme,
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

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            customBorder: const CircleBorder(),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _kSettingsCardBg,
                borderRadius: BorderRadius.circular(26),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: _kSettingsTextMain),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _kSettingsTextMain,
                ),
              ),
            ),
          ),
          const SizedBox(width: 52),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.icon,
    required this.iconBackground,
    required this.title,
  });

  final IconData icon;
  final Color iconBackground;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: _kSettingsPrimaryDark),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: _kSettingsTextMain,
          ),
        ),
      ],
    );
  }
}

class _SettingsToggleCard extends StatelessWidget {
  const _SettingsToggleCard({
    required this.config,
    required this.value,
    required this.disabled,
    required this.onChanged,
  });

  final _ToggleSettingConfig config;
  final bool value;
  final bool disabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: disabled ? 0.5 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: _kSettingsCardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _kSettingsCardBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: config.iconBackground,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(config.icon, color: config.iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _kSettingsTextMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    config.subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _kSettingsTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            _SettingsToggleSwitch(
              value: value,
              disabled: disabled,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsToggleSwitch extends StatelessWidget {
  const _SettingsToggleSwitch({
    required this.value,
    required this.disabled,
    required this.onChanged,
  });

  final bool value;
  final bool disabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 68,
        height: 36,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: value ? _kSettingsPrimary : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(999),
          boxShadow: value
              ? const [
                  BoxShadow(
                    color: Color(0x338E6C00),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  const _ThemeOptionCard({
    required this.option,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  final _ThemeOption option;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: disabled ? 0.6 : 1,
        child: GestureDetector(
          onTap: disabled ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: _kSettingsCardBg,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: selected ? _kSettingsPrimary : Colors.transparent,
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: option.accentColor,
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Icon(option.icon, color: Colors.white, size: 34),
                    ),
                    if (selected)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: _kSettingsPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 16,
                            color: _kSettingsTextMain,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  option.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kSettingsTextMain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GrownUpsButton extends StatelessWidget {
  const _GrownUpsButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.admin_panel_settings, color: _kSettingsTextMain),
        label: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'For Grown-ups',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _kSettingsTextMain,
            ),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _kSettingsCardBorder, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: const Text('Sign Out'),
      ),
    );
  }
}

class _SettingsBackgroundDecor extends StatelessWidget {
  const _SettingsBackgroundDecor();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                color: Color(0x33F2CC0D),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x55F2CC0D),
                    blurRadius: 80,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -60,
            child: Container(
              width: 160,
              height: 160,
              decoration: const BoxDecoration(
                color: Color(0x223B82F6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x333B82F6),
                    blurRadius: 60,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsMascot extends StatelessWidget {
  const _SettingsMascot();

  static const _mascotUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAnVSfory594mO-WeYdPLoz7lFBAYHgJtr4DZvWV7zDbEVhfYiwHF50_WocJxSGW2ssLjDp2z1xy-ykEpBV_ICuiDLX9FI2hulBg1UJ1BusRIj6s95UOITotEBYL0P16VTHNfLcmhbpp-O6RsMFbVMW4qpRb9ZgbkFf7SO-Ydctlok2YyyL4NF-jLVIIsE-pftT69x2pZL4Y6qMacFudNsohZUlkARj4pcwIs3Dw0_EUSVVToceHNKxcLCJs8--wrR3QJPt83ktVVA';

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 12,
      child: IgnorePointer(
        ignoring: true,
        child: Image.network(
          _mascotUrl,
          width: 130,
          height: 130,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _ParentControlsSheet extends StatelessWidget {
  const _ParentControlsSheet({
    required this.userEmail,
    required this.musicEnabled,
    required this.soundsEnabled,
    required this.themeName,
  });

  final String userEmail;
  final bool musicEnabled;
  final bool soundsEnabled;
  final String themeName;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Parent Controls',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _kSettingsTextMain,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              userEmail,
              style: const TextStyle(
                fontSize: 14,
                color: _kSettingsTextMuted,
              ),
            ),
            const SizedBox(height: 20),
            _ParentSummaryRow(
              icon: Icons.queue_music,
              label: 'Music',
              value: musicEnabled ? 'On' : 'Off',
            ),
            const SizedBox(height: 12),
            _ParentSummaryRow(
              icon: Icons.volume_up,
              label: 'Sounds',
              value: soundsEnabled ? 'On' : 'Off',
            ),
            const SizedBox(height: 12),
            _ParentSummaryRow(
              icon: Icons.palette,
              label: 'Theme',
              value: themeName,
            ),
          ],
        ),
      ),
    );
  }
}

class _ParentSummaryRow extends StatelessWidget {
  const _ParentSummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F0E6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: _kSettingsPrimaryDark),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _kSettingsTextMain,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _kSettingsTextMain,
          ),
        ),
      ],
    );
  }
}

class _ToggleSettingConfig {
  const _ToggleSettingConfig({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
}

class _ThemeOption {
  const _ThemeOption({
    required this.id,
    required this.label,
    required this.icon,
    required this.accentColor,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color accentColor;
}

const List<_ToggleSettingConfig> _toggleConfigs = [
  _ToggleSettingConfig(
    id: 'music',
    title: 'Music',
    subtitle: 'Fun tunes!',
    icon: Icons.queue_music,
    iconBackground: Color(0xFFFFEDD5),
    iconColor: Color(0xFFFF7043),
  ),
  _ToggleSettingConfig(
    id: 'sounds',
    title: 'Sounds',
    subtitle: 'Click & pop!',
    icon: Icons.volume_up,
    iconBackground: Color(0xFFE0E7FF),
    iconColor: Color(0xFF6366F1),
  ),
];

const List<_ThemeOption> _themeOptions = [
  _ThemeOption(
    id: 'Sunny',
    label: 'Sunny',
    icon: Icons.wb_sunny,
    accentColor: Color(0xFFF2CC0D),
  ),
  _ThemeOption(
    id: 'Space',
    label: 'Space',
    icon: Icons.rocket_launch,
    accentColor: Color(0xFF6366F1),
  ),
  _ThemeOption(
    id: 'Jungle',
    label: 'Jungle',
    icon: Icons.forest,
    accentColor: Color(0xFF34D399),
  ),
  _ThemeOption(
    id: 'Candy',
    label: 'Candy',
    icon: Icons.icecream,
    accentColor: Color(0xFFF472B6),
  ),
];
