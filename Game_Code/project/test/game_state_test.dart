import 'package:flutter_test/flutter_test.dart';
import 'package:project/models/game_stat.dart';
import 'package:project/models/player_model.dart';
import 'package:project/models/property_model.dart';

Player makePlayer({
  required int id,
  int balance = 2500,
  LoanData? loan,
  InvestmentData? investment,
  int startupFund = 0,
}) {
  return Player(
    id: id,
    name: 'Player $id',
    color: id == 1 ? 'Red' : 'Blue',
    pathType: 'Non-College',
    career: 'Artist',
    salary: 80,
    balance: balance,
    loan: loan,
    investment: investment,
    startupFund: startupFund,
  );
}

void main() {
  group('MINTED final integration rules', () {
    test('game advances through Year 3 and finishes after final round', () {
      final game = GameState(
        players: [makePlayer(id: 1), makePlayer(id: 2)],
      );

      expect(game.currentYear, 1);
      expect(game.isGameFinished, false);

      game.nextTurn();
      game.nextTurn();
      expect(game.currentYear, 2);
      expect(game.isGameFinished, false);

      game.nextTurn();
      game.nextTurn();
      expect(game.currentYear, 3);
      expect(game.isGameFinished, false);

      game.nextTurn();
      game.nextTurn();
      expect(game.currentYear, 3);
      expect(game.isGameFinished, true);
    });

    test(
      'Year 3 loan is settled after Year 1 and Year 2 interest',
      () {
        final player = makePlayer(
          id: 1,
          balance: 2000,
          loan: LoanData(principal: 400, startYear: 1),
        );
        final game = GameState(players: [player]);

        game.nextTurn();
        game.nextTurn();
        game.nextTurn();

        // 2000 - 40 - 40 - (400 + 40) = 1480.
        expect(player.loan, isNull);
        expect(player.balance, 1480);
        expect(
          player.history.map((entry) => entry.action),
          contains('Loan Repaid'),
        );
      },
    );

    test(
      'Year 3 investment returns principal plus three years of simple interest',
      () {
        final player = makePlayer(
          id: 1,
          balance: 2100,
          investment: InvestmentData(principal: 400, startYear: 1),
        );
        final game = GameState(players: [player]);

        game.nextTurn();
        game.nextTurn();
        game.nextTurn();

        // 2100 + (400 + 20 + 20 + 20) = 2560? No: the 400
        // principal was already deducted when the investment was created.
        // Here balance is deliberately represented after that deduction,
        // so maturity adds 460 to produce 2560.
        expect(player.investment, isNull);
        expect(player.balance, 2560);
        expect(
          player.history.map((entry) => entry.action),
          contains('Investment Matured'),
        );
      },
    );

    test('net worth includes startup funds and property value', () {
      final player = makePlayer(id: 1, balance: 2000, startupFund: 400);
      final property = Property(
        id: 'p1',
        name: 'Cottage',
        category: 'Residential',
        price: 500,
        rent: 50,
        ownerId: '1',
      );
      final game = GameState(
        players: [player],
        properties: [property],
      );

      expect(game.calculateNetWorth(player), 2900);
      expect(game.getWinner(), player);
    });

    test('player state survives JSON round trip', () {
      final player = makePlayer(
        id: 1,
        balance: 2300,
        startupFund: 200,
        loan: LoanData(principal: 800, startYear: 1),
        investment: InvestmentData(principal: 400, startYear: 1),
      );
      player.addHistory('Test Action', 50);

      final original = GameState(players: [player]);
      final restored = GameState.fromJson(original.toJson());
      final restoredPlayer = restored.players.first;

      expect(restoredPlayer.name, player.name);
      expect(restoredPlayer.balance, 2300);
      expect(restoredPlayer.startupFund, 200);
      expect(restoredPlayer.loan?.principal, 800);
      expect(restoredPlayer.investment?.principal, 400);
      expect(restoredPlayer.history.single.action, 'Test Action');
    });
  });
}
