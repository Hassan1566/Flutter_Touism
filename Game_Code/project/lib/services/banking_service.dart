import 'package:flutter/material.dart';
import 'package:project/models/player_model.dart';

void showBankingDialog(
  BuildContext context,
  Player activePlayer,
  VoidCallback onUpdate,
) {
  showDialog(
    context: context,
    builder: (context) {
      TextEditingController amountController = TextEditingController();
      return AlertDialog(
        title: const Text('🏦 Banking & Loans'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Amount (Mints)',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    int amount = int.tryParse(amountController.text) ?? 0;
                    if (amount > 0) {
                      _processLoan(activePlayer, amount, onUpdate);
                      Navigator.pop(context);
                    } else if (amount == 0) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Error'),
                            content: const Text('Please enter a valid amount.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: const Text('Take Loan'),
                ),
                ElevatedButton(
                  onPressed: () {
                    int amount = int.tryParse(amountController.text) ?? 0;
                    if (amount > 0) {
                      _processInvestment(activePlayer, amount, onUpdate);
                      Navigator.pop(context);
                    } else if (amount == 0) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Error'),
                            content: const Text('Please enter a valid amount.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: const Text('Invest'),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

void _processLoan(Player player, int amount, VoidCallback onUpdate) {
  player.balance += amount;
  player.history.add({
    'title': 'Loan Taken',
    'result': '+$amount Mints',
    'timestamp': DateTime.now().toString(),
  });
  onUpdate();
}

void _processInvestment(Player player, int principal, VoidCallback onUpdate) {
  int totalReturn = principal + (principal * 0.05 * 3).toInt();
  player.balance += totalReturn;
  player.history.add({
    'title': 'Investment Matured',
    'result': '+$totalReturn Mints',
    'timestamp': DateTime.now().toString(),
  });
  onUpdate();
}
