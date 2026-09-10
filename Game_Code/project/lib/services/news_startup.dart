import 'dart:math';

import 'package:flutter/material.dart';
import 'package:project/models/player_model.dart';

void showNewsStartupDialog(
  BuildContext context,
  Player activePlayer,
  VoidCallback onUpdate,
) {
  final List<Map<String, dynamic>> events = [
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
      'desc': 'Stock values soar and pay dividends.',
      'amount': 50,
    },
  ];

  // Randomly select one event
  final randomEvent = events[Random().nextInt(events.length)];

  showDialog(
    context: context,
    builder: (context) {
      int amount = randomEvent['amount'] as int;
      return AlertDialog(
        title: const Text('📰 Breaking News'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              randomEvent['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(randomEvent['desc'] as String),
            const SizedBox(height: 12),
            Text(
              'Effect: ${amount >= 0 ? '+' : ''}$amount Mints',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: amount >= 0 ? Colors.green : Colors.red,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              activePlayer.balance += amount;
              activePlayer.history.add({
                'title': randomEvent['title'],
                'result': '${amount >= 0 ? '+' : ''}$amount Mints',
                'timestamp': DateTime.now().toString(),
              });
              onUpdate();
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      );
    },
  );
}
