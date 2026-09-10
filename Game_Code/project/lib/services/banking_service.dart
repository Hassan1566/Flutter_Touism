import 'package:flutter/material.dart';

import '../models/player_model.dart';

class BankingService {
  // Calculate yearly loan interest (10% of principal)
  static int calculateLoanInterest(int principal) {
    return (principal * 0.10).toInt();
  }

  // Process a loan transaction for the active player
  static void takeLoan(Player player, int amount, VoidCallback onUpdate) {
    player.balance += amount; // Player receives the loan cash
    int annualInterest = calculateLoanInterest(amount);

    player.history.add({
      'title': 'Loan Taken',
      'result': '+$amount Mints (Due: $annualInterest/yr)',
      'timestamp': DateTime.now().toString(),
    });

    onUpdate();
  }

  // Calculate investment return after 3 years (5% simple interest per year)
  static void processInvestment(
    Player player,
    int principal,
    VoidCallback onUpdate,
  ) {
    int totalInterest = (principal * 0.05 * 3).toInt();
    int totalReturn = principal + totalInterest;

    player.balance += totalReturn; // Returns principal + 3 years of 5% interest

    player.history.add({
      'title': 'Investment Matured',
      'result': '+$totalReturn Mints',
      'timestamp': DateTime.now().toString(),
    });

    onUpdate();
  }
}
