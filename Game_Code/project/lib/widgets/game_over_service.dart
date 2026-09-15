import 'package:flutter/material.dart';

import '../models/game_stat.dart';
import '../models/player_model.dart';

void showGameOverDialog(
  BuildContext context,
  GameState gameState,
  VoidCallback onFinish,
) {
  if (gameState.players.isEmpty) {
    onFinish();
    return;
  }

  final players = [...gameState.players];
  players.sort(
    (a, b) => gameState
        .calculateNetWorth(b)
        .compareTo(gameState.calculateNetWorth(a)),
  );

  final winner = players.first;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('🏁 Game Over!'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Year ${gameState.maxYears} has concluded. Final standings:',
              ),
              const SizedBox(height: 12),
              ...players.map(
                (player) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '${player.name}: ${gameState.calculateNetWorth(player)} Mints',
                    style: TextStyle(
                      fontWeight: player == winner
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
              const Divider(height: 20),
              Text(
                '🏆 Winner: ${winner.name} with ${gameState.calculateNetWorth(winner)} Mints!',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onFinish();
            },
            child: const Text('Finish Game'),
          ),
        ],
      );
    },
  );
}
