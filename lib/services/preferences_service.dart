import 'package:shared_preferences/shared_preferences.dart';

class PreferencesSnapshot {
  const PreferencesSnapshot({
    required this.musicEnabled,
    required this.soundsEnabled,
    required this.theme,
  });

  final bool musicEnabled;
  final bool soundsEnabled;
  final String theme;
}

class PreferencesService {
  PreferencesService._(this._prefs);

  final SharedPreferences _prefs;

  static const _musicKey = 'prefs_music_enabled';
  static const _soundsKey = 'prefs_sounds_enabled';
  static const _themeKey = 'prefs_theme_name';

  static PreferencesService? _instance;

  static Future<PreferencesService> configure() async {
    final prefs = await SharedPreferences.getInstance();
    _instance ??= PreferencesService._(prefs);
    return _instance!;
  }

  static PreferencesService get instance {
    final instance = _instance;
    if (instance == null) {
      throw StateError(
        'PreferencesService not configured. Call PreferencesService.configure() first.',
      );
    }
    return instance;
  }

  Future<PreferencesSnapshot> getPreferences() async {
    return PreferencesSnapshot(
      musicEnabled: _prefs.getBool(_musicKey) ?? true,
      soundsEnabled: _prefs.getBool(_soundsKey) ?? true,
      theme: _prefs.getString(_themeKey) ?? 'Sunny',
    );
  }

  Future<PreferencesSnapshot> updatePreferences({
    bool? musicEnabled,
    bool? soundsEnabled,
    String? theme,
  }) async {
    if (musicEnabled != null) {
      await _prefs.setBool(_musicKey, musicEnabled);
    }
    if (soundsEnabled != null) {
      await _prefs.setBool(_soundsKey, soundsEnabled);
    }
    if (theme != null) {
      await _prefs.setString(_themeKey, theme);
    }
    return getPreferences();
  }
}
