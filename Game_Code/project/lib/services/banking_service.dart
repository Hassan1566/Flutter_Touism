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
  int currentLoan = player.loan?.principal ?? 0;
  player.loan = LoanData(
    principal: currentLoan + amount,
    startYear: player.loan?.startYear ?? 1,
  );
  player.addHistory('Loan Taken', amount);
  onUpdate();
}

void _processInvestment(Player player, int principal, VoidCallback onUpdate) {
  // 1. Check if the player actually has enough cash to invest
  if (player.balance < principal) {
    // Optionally: show an error dialog to the user here
    return;
  }

  // 2. Deduct the invested cash from their active balance
  player.balance -= principal;

  // 3. Safely add the money to their active investments tracking
  int currentInvest = player.investment?.principal ?? 0;
  player.investment = InvestmentData(
    principal: currentInvest + principal,
    startYear: player.investment?.startYear ?? 1,
  );

  // 4. Log the transaction accurately
  player.addHistory('Investment Made', -principal);

  onUpdate();
}
