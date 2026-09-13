import 'package:flutter/material.dart';

import '../models/player_model.dart';

void showGameOverDialog(
  BuildContext context,
  List<Player> players,
  VoidCallback onFinish,
) {
  // Find the player with the highest total net worth
  Player winner = players.reduce(
    (curr, next) => curr.calculateTotalAssets() > next.calculateTotalAssets() ? curr : next,
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text('🏁 Game Over!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The final year has concluded. Final standings based on net worth[cite: 5]:',
            ),
            const SizedBox(height: 12),
            ...players.map(
              (p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  '${p.name}: ${p.calculateTotalAssets()} Mints',
                  style: TextStyle(
                    fontWeight: p == winner
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: p == winner ? Colors.purple : Colors.black,
                  ),
                ),
              ),
            ),
            const Divider(height: 20),
            Text(
              '🏆 Winner: ${winner.name} with ${winner.calculateTotalAssets()} Mints!',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              onFinish(); // Execute the callback (e.g., return to home)
            },
            child: const Text('Finish Game'),
          ),
        ],
      );
    },
  );
}
