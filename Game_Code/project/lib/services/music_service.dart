import 'package:shared_preferences/shared_preferences.dart';

class MusicService {
  static const String _musicKey = 'minted_music_enabled';

  static Future<bool> isEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_musicKey) ?? true;
  }

  static Future<void> setEnabled(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_musicKey, enabled);
    // Audio playback is intentionally a safe placeholder because the project
    // currently has no bundled music asset.
  }

  static Future<void> resetToDefault() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_musicKey);
  }
}
