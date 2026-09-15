import '../models/game_stat.dart';
import '../models/player_model.dart';
import 'banking_service.dart';

class GameService {
  /// Processes the effects of passing GO.
  ///
  /// MINTED rules:
  /// - Salary is received when passing payday.
  /// - 10% tax is charged when passing GO.
  /// - Startup receives +200 every GO.
  static void processGo(GameState gameState, Player player) {
    if (player.salary > 0) {
      player.addMoney(player.salary);
      player.addHistory('Payday salary', player.salary);
    }

    processStartupGo(player);

    final totalAssets = _calculateAssetsBeforeTax(gameState, player);
    final tax = (totalAssets * 0.10).round();

    if (tax > 0) {
      // Do not allow GO tax to make the cash balance negative.
      final actualTax = tax > player.balance ? player.balance : tax;
      if (actualTax > 0) {
        player.removeMoney(actualTax);
        player.addHistory('GO tax', -actualTax);
      }
    }
  }

  static int _calculateAssetsBeforeTax(GameState gameState, Player player) {
    final propertyValue = gameState.propertyValueForPlayer(player);
    final investmentValue = gameState.investmentValueForPlayer(player);

    return player.balance +
        propertyValue +
        investmentValue +
        player.startupFund;
  }

  /// Processes one complete game year.
  ///
  /// The caller supplies the year being completed. This keeps the final
  /// Year 3 banking processing separate from incrementing the displayed year.
  static void processNewYear(GameState gameState, [int? completedYear]) {
    final year = completedYear ?? gameState.currentYear;

    for (final player in gameState.players) {
      BankingService.processLoanYear(player, year);
      BankingService.processInvestmentYear(player, year);
    }
  }

  static bool buyProperty(
    GameState gameState,
    Player player,
    String propertyId,
  ) {
    final property = gameState.getPropertyById(propertyId);

    if (property == null || property.isOwned) {
      return false;
    }

    if (player.balance < property.price) {
      return false;
    }

    player.removeMoney(property.price);
    property.ownerId = player.id.toString();

    if (!player.propertyIds.contains(property.id)) {
      player.propertyIds.add(property.id);
    }

    player.addHistory('Bought ${property.name}', -property.price);
    return true;
  }

  static bool payPropertyRent(
    GameState gameState,
    Player renter,
    String propertyId,
  ) {
    final property = gameState.getPropertyById(propertyId);

    if (property == null || property.ownerId == null) {
      return false;
    }

    if (property.ownerId == renter.id.toString()) {
      return false;
    }

    final owner = gameState.getPropertyOwner(propertyId);
    if (owner == null) {
      return false;
    }

    final rent = property.rent;
    if (!renter.removeMoney(rent)) {
      return false;
    }

    owner.addMoney(rent);
    renter.addHistory('Paid rent for ${property.name}', -rent);
    owner.addHistory('Received rent from ${renter.name}', rent);

    return true;
  }

  static void processStartupGo(Player player) {
    if (!player.hasStartup) {
      return;
    }

    player.startupFund += 200;
    player.addHistory('Startup received +200 at GO', 200);
  }

  static bool handleStartupFixedOption(Player player) {
    if (!player.hasStartup || player.balance < 200) {
      return false;
    }

    player.removeMoney(200);
    player.addHistory('Startup event - Fixed solution', -200);
    return true;
  }

  static bool handleStartupRiskOption(Player player, int diceResult) {
    if (!player.hasStartup || diceResult < 1 || diceResult > 6) {
      return false;
    }

    final amount = diceResult * 100;
    if (player.balance < amount) {
      return false;
    }

    player.removeMoney(amount);
    player.addHistory('Startup event - Risk ($diceResult x 100)', -amount);
    return true;
  }
}
