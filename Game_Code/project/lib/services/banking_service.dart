import 'package:flutter/material.dart';

import '../models/player_model.dart';

class BankingService {
  /// Shows the main banking dialog.
  static void showBankingDialog(
    BuildContext context,
    Player player,
    VoidCallback onUpdate,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final amountController = TextEditingController();

        return AlertDialog(
          title: const Text('🏦 Banking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Balance: ${player.balance} Mints'),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (Mints)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                showLoanInfo(context, player, amountController, onUpdate);
              },
              child: const Text('Take Loan'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = int.tryParse(amountController.text);

                if (amount == null || amount <= 0) {
                  _showMessage(context, 'Please enter a valid amount.');
                  return;
                }

                final success = makeInvestment(player, amount);

                if (success) {
                  Navigator.pop(context);

                  _showMessage(context, 'Investment of $amount Mints created.');

                  onUpdate();
                } else {
                  _showMessage(context, 'You cannot make this investment.');
                }
              },
              child: const Text('Invest'),
            ),
          ],
        );
      },
    );
  }

  /// Shows loan confirmation/details.
  static void showLoanInfo(
    BuildContext context,
    Player player,
    TextEditingController controller,
    VoidCallback onUpdate,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('🏦 Take Loan'),
          content: const Text(
            'Loan interest is 10% per year.\n\n'
            'The loan principal is repaid at the '
            'end of Year 3.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = int.tryParse(controller.text);

                if (amount == null || amount <= 0) {
                  _showMessage(context, 'Please enter a valid loan amount.');
                  return;
                }

                final success = takeLoan(player, amount);

                Navigator.pop(context);

                _showMessage(
                  context,
                  success
                      ? 'Loan of $amount Mints received.'
                      : 'You already have an active loan.',
                );

                if (success) {
                  onUpdate();
                }
              },
              child: const Text('Confirm Loan'),
            ),
          ],
        );
      },
    );
  }

  /// Creates a new loan.
  ///
  /// Only one active loan is allowed.
  static bool takeLoan(Player player, int amount) {
    if (amount <= 0) {
      return false;
    }

    if (player.loan != null) {
      return false;
    }

    player.loan = LoanData(principal: amount, startYear: 1);

    player.addMoney(amount);

    player.addHistory('Loan Taken', amount);

    return true;
  }

  /// Creates a new investment.
  ///
  /// Investment uses 5% simple interest per year
  /// and matures at the end of Year 3.
  static bool makeInvestment(Player player, int amount) {
    if (amount <= 0) {
      return false;
    }

    if (player.investment != null) {
      return false;
    }

    if (player.balance < amount) {
      return false;
    }

    player.removeMoney(amount);

    player.investment = InvestmentData(principal: amount, startYear: 1);

    player.addHistory('Investment Made', -amount);

    return true;
  }

  /// Processes one year of loan activity.
  ///
  /// Year 1: 10% interest
  /// Year 2: 10% interest
  /// Year 3: 10% interest + principal
  static void processLoanYear(Player player, int year) {
    final loan = player.loan;

    if (loan == null) {
      return;
    }

    final interest = loan.annualInterest;

    if (year < loan.maturityYear) {
      player.removeMoney(interest);

      player.addHistory('Loan Interest - Year $year', -interest);

      return;
    }

    if (year == loan.maturityYear) {
      final totalPayment = loan.principal + interest;

      player.removeMoney(totalPayment);

      player.addHistory('Loan Repaid', -totalPayment);

      player.loan = null;
    }
  }

  /// Processes one year of investment activity.
  ///
  /// Interest is 5% of the original principal.
  /// This is simple interest, not compound interest.
  static void processInvestmentYear(Player player, int year) {
    final investment = player.investment;

    if (investment == null) {
      return;
    }

    if (year < investment.maturityYear) {
      player.addHistory(
        'Investment Interest - Year $year',
        investment.annualInterest,
      );

      return;
    }

    if (year == investment.maturityYear) {
      final maturityAmount = investment.maturityAmount;

      player.addMoney(maturityAmount);

      player.addHistory('Investment Matured', maturityAmount);

      player.investment = null;
    }
  }

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
