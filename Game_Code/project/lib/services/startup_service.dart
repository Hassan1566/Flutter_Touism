import 'package:flutter/material.dart';

import '../models/player_model.dart';
import 'game_service.dart';

class StartupService {
  /// Shows the startup event dialog.
  static void showStartupEvent({
    required BuildContext context,
    required Player player,
    required VoidCallback onUpdated,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Startup Event'),
          content: const Text(
            'Your startup has encountered an event.\n\n'
            'Choose the fixed solution or take the risk '
            'using the physical dice.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                final success = GameService.handleStartupFixedOption(player);

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'You paid 200 for the startup event.'
                          : 'Not enough balance.',
                    ),
                  ),
                );

                onUpdated();
              },
              child: const Text('Pay 200'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                _showRiskDiceInput(
                  context: context,
                  player: player,
                  onUpdated: onUpdated,
                );
              },
              child: const Text('Take Risk'),
            ),
          ],
        );
      },
    );
  }

  /// Gets the physical dice result from the user.
  static void _showRiskDiceInput({
    required BuildContext context,
    required Player player,
    required VoidCallback onUpdated,
  }) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Startup Risk'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Physical dice result',
              hintText: 'Enter 1 - 6',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.dispose();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final result = int.tryParse(controller.text);

                if (result == null || result < 1 || result > 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter a dice result from 1 to 6.'),
                    ),
                  );
                  return;
                }

                final success = GameService.handleStartupRiskOption(
                  player,
                  result,
                );

                controller.dispose();
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Startup risk cost: ${result * 100}'
                          : 'Not enough balance.',
                    ),
                  ),
                );

                onUpdated();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}
