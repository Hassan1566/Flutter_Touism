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
    // Keep the parent screen context. Do not use the dialog's context to
    // open another dialog after the first dialog has been popped.
    final parentContext = context;

    showDialog<bool>(
      context: parentContext,
      builder: (dialogContext) {
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

                Navigator.pop(dialogContext, success);
              },
              child: const Text('Pay 200'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                _showRiskDiceInput(
                  context: parentContext,
                  player: player,
                  onUpdated: onUpdated,
                );
              },
              child: const Text('Take Risk'),
            ),
          ],
        );
      },
    ).then((result) {
      if (!parentContext.mounted || result == null) return;

      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(
          content: Text(
            result
                ? 'You paid 200 for the startup event.'
                : 'Not enough balance.',
          ),
        ),
      );

      onUpdated();
    });
  }

  /// Gets the physical dice result from the user.
  static Future<void> _showRiskDiceInput({
    required BuildContext context,
    required Player player,
    required VoidCallback onUpdated,
  }) async {
    final parentContext = context;
    final controller = TextEditingController();

    try {
      final result = await showDialog<bool>(
        context: parentContext,
        builder: (dialogContext) {
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
                  Navigator.pop(dialogContext);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final diceResult = int.tryParse(controller.text.trim());

                  if (diceResult == null || diceResult < 1 || diceResult > 6) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Enter a dice result from 1 to 6.'),
                      ),
                    );
                    return;
                  }

                  final success = GameService.handleStartupRiskOption(
                    player,
                    diceResult,
                  );

                  Navigator.pop(dialogContext, success);
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      );

      if (!parentContext.mounted || result == null) return;

      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(
          content: Text(
            result
                ? 'Startup risk cost applied.'
                : 'Not enough balance.',
          ),
        ),
      );

      onUpdated();
    } finally {
      controller.dispose();
    }
  }
}
