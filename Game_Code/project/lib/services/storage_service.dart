import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_stat.dart';

class StorageService {
  static const String _gameStateKey = 'minted_game_state';

  /// Save the current game locally.
  ///
  /// SharedPreferences uses browser storage when running on Flutter Web.
  /// Return false instead of throwing so the UI remains usable when browser
  /// storage is unavailable or blocked.
  static Future<bool> saveGame(GameState gameState) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(gameState.toJson());
      return await preferences.setString(_gameStateKey, jsonString);
    } catch (error, stackTrace) {
      debugPrint('MINTED saveGame failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  /// Load the previously saved game.
  static Future<GameState?> loadGame() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final jsonString = preferences.getString(_gameStateKey);

      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final Map<String, dynamic> jsonData =
          jsonDecode(jsonString) as Map<String, dynamic>;

      return GameState.fromJson(jsonData);
    } catch (error, stackTrace) {
      debugPrint('MINTED loadGame failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  /// Check whether a saved game exists.
  static Future<bool> hasSavedGame() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return preferences.containsKey(_gameStateKey);
    } catch (error, stackTrace) {
      debugPrint('MINTED hasSavedGame failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  /// Delete the saved game.
  static Future<bool> deleteSavedGame() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return await preferences.remove(_gameStateKey);
    } catch (error, stackTrace) {
      debugPrint('MINTED deleteSavedGame failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }
}
