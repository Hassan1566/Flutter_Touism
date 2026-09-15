import 'dart:math';

import 'package:flutter/material.dart';
import 'package:project/models/game_stat.dart';

class NewsService {
  static final Random _random = Random();

  // Remembers the last event so it is not immediately repeated.
  static int? _lastEventIndex;

  static final List<Map<String, dynamic>> _events = [
    {
      'title': '🌾 Famine Outbreak',
      'desc': 'Crops fail across regions.',
      'amount': -40,
    },
    {
      'title': '🌊 Severe Flood',
      'desc': 'Infrastructure damage requires repairs.',
      'amount': -60,
    },
    {
      'title': '📈 Market Boom',
      'desc': 'Markets perform strongly and players receive dividends.',
      'amount': 50,
    },
  ];

  /// Shows a News event and applies it to ALL players.
  static void showNewsDialog(
    BuildContext context,
    GameState gameState,
    VoidCallback onUpdate,
  ) {
    if (gameState.players.isEmpty) {
      return;
    }

    final eventIndex = _getEventIndex();
    final event = _events[eventIndex];

    final int amount = event['amount'] as int;
    final String title = event['title'] as String;
    final String description = event['desc'] as String;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('📰 Breaking News'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(description),
              const SizedBox(height: 12),
              Text(
                'Effect on every player: '
                '${amount >= 0 ? '+' : ''}$amount Mints',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: amount >= 0 ? Colors.green : Colors.red,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Players affected: ${gameState.players.length}',
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _applyNewsEvent(gameState, title, amount);

                onUpdate();

                Navigator.pop(dialogContext);

                _showAppliedMessage(
                  context,
                  title,
                  amount,
                  gameState.players.length,
                );
              },
              child: const Text('Apply to All'),
            ),
          ],
        );
      },
    );
  }

  /// Select an event without immediately repeating the previous event.
  static int _getEventIndex() {
    if (_events.length <= 1) {
      _lastEventIndex = 0;
      return 0;
    }

    int index;

    do {
      index = _random.nextInt(_events.length);
    } while (index == _lastEventIndex);

    _lastEventIndex = index;

    return index;
  }

  /// Apply the News effect to every player.
  static void _applyNewsEvent(GameState gameState, String title, int amount) {
    for (final player in gameState.players) {
      if (amount >= 0) {
        player.addMoney(amount);
      } else {
        final deduction = -amount;

        // Do not allow a player's balance to become negative.
        final actualDeduction = min(player.balance, deduction);

        if (actualDeduction > 0) {
          player.removeMoney(actualDeduction);
        }
      }

      player.addHistory(title, amount);
    }
  }

  static void _showAppliedMessage(
    BuildContext context,
    String title,
    int amount,
    int playerCount,
  ) {
    final effect = '${amount >= 0 ? '+' : ''}$amount Mints';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title applied to $playerCount players ($effect each).'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
