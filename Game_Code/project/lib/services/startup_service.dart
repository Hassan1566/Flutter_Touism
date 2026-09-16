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
    showDialog<bool>(
      context: context,
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
    ).then((result) {
      if (result is! bool) return;

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
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

  /// Shows the dice-result dialog and applies the result after it closes.
  static Future<void> _showRiskDiceInput({
    required BuildContext context,
    required Player player,
    required VoidCallback onUpdated,
  }) async {
    final diceResult = await showDialog<int>(
      context: context,
      builder: (dialogContext) => const _RiskDiceDialog(),
    );

    if (!context.mounted || diceResult == null) return;

    final success = GameService.handleStartupRiskOption(player, diceResult);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Startup risk cost: ${diceResult * 100} Mints.'
              : 'Not enough balance.',
        ),
      ),
    );

    onUpdated();
  }
}

class _RiskDiceDialog extends StatefulWidget {
  const _RiskDiceDialog();

  @override
  State<_RiskDiceDialog> createState() => _RiskDiceDialogState();
}

class _RiskDiceDialogState extends State<_RiskDiceDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply() {
    final diceResult = int.tryParse(_controller.text.trim());

    if (diceResult == null || diceResult < 1 || diceResult > 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a dice result from 1 to 6.')),
      );
      return;
    }

    Navigator.pop(context, diceResult);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Startup Risk'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _apply(),
        decoration: const InputDecoration(
          labelText: 'Physical dice result',
          hintText: 'Enter 1 - 6',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _apply, child: const Text('Apply')),
      ],
    );
  }
}
