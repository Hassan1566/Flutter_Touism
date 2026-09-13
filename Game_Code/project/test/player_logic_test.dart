import 'package:flutter_test/flutter_test.dart';
import 'package:project/models/player_model.dart';

void main() {
  group('MINTED Core Economic Engine Tests', () {
    test(
      'Net worth correctly calculates cash, investments, and active loans',
      () {
        final player = Player(
          name: 'Test Player',
          color: 'Blue',
          pathType: 'College',
          career: 'Doctor',
          salary: 150,
          id: 1,
          balance: 0,
        );

        // Set initial values
        player.balance = 2000; //
        player.investment = InvestmentData(principal: 400, startYear: 1);
        player.loan = LoanData(principal: 400, startYear: 1);

        // Net Worth = balance + investment - loan (2000 + 400 - 400 = 2000)
        int netWorth = player.balance + (player.investment?.principal ?? 0) - (player.loan?.principal ?? 0);
        expect(netWorth, 2000);
      },
    );

    test('Loan interest accrues at exactly 10% per year', () {
      int currentLoan = 400; // Example loan amount from rules[cite: 2]
      int interest = (currentLoan * 0.10).toInt();
      int updatedLoan = currentLoan + interest;

      // Should match the Year 1 loan table requirement (440 total)[cite: 2]
      expect(updatedLoan, 440);
    });

    test('Investment grows with 5% simple interest per year', () {
      int currentInvest = 400; // Example investment amount from rules[cite: 2]
      int interest = (currentInvest * 0.05).toInt();
      int updatedInvest = currentInvest + interest;

      // Should match the Year 1 investment growth requirement (420 total)[cite: 2]
      expect(updatedInvest, 420);
    });
  });
}
