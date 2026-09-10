import 'package:flutter/material.dart';
import 'package:project/models/player_model.dart';

void showQuizDialog(
  BuildContext context,
  Player activePlayer,
  VoidCallback onUpdate,
) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('🧠 Quiz Challenge'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select difficulty level:'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                _processReward(activePlayer, 20, 'Easy', onUpdate);
                Navigator.pop(context);
              },
              child: const Text('Easy (20 Mints)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                _processReward(activePlayer, 50, 'Medium', onUpdate);
                Navigator.pop(context);
              },
              child: const Text('Medium (50 Mints)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                _processReward(activePlayer, 100, 'Hard', onUpdate);
                Navigator.pop(context);
              },
              child: const Text('Hard (100 Mints)'),
            ),
          ],
        ),
      );
    },
  );
}

void _processReward(
  Player player,
  int amount,
  String difficulty,
  VoidCallback onUpdate,
) {
  player.balance += amount;
  player.history.add({
    'title': 'Quiz ($difficulty)',
    'result': '+$amount Mints',
    'timestamp': DateTime.now().toString(),
  });
  onUpdate();
}
