import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_stat.dart';

class StorageService {
  static const String _gameStateKey = 'minted_game_state';

  /// Save the current game locally.
  static Future<bool> saveGame(GameState gameState) async {
    final preferences = await SharedPreferences.getInstance();

    final jsonString = jsonEncode(gameState.toJson());

    return preferences.setString(_gameStateKey, jsonString);
  }

  /// Load the previously saved game.
  static Future<GameState?> loadGame() async {
    final preferences = await SharedPreferences.getInstance();

    final jsonString = preferences.getString(_gameStateKey);

    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      final Map<String, dynamic> jsonData =
          jsonDecode(jsonString) as Map<String, dynamic>;

      return GameState.fromJson(jsonData);
    } catch (e) {
      return null;
    }
  }

  /// Check whether a saved game exists.
  static Future<bool> hasSavedGame() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.containsKey(_gameStateKey);
  }

  /// Delete the saved game.
  static Future<bool> deleteSavedGame() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.remove(_gameStateKey);
  }
}
