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
    // Salary
    if (player.salary > 0) {
      player.addMoney(player.salary);

      player.addHistory('Payday salary', player.salary);
    }

    // Startup income
    processStartupGo(player);
    // GO tax
    final totalAssets = _calculateAssetsBeforeTax(gameState, player);

    final tax = (totalAssets * 0.10).round();

    if (tax > 0) {
      player.removeMoney(tax);

      player.addHistory('GO tax', -tax);
    }
  }

  /// Calculates assets before GO tax.
  static int _calculateAssetsBeforeTax(GameState gameState, Player player) {
    final propertyValue = gameState.propertyValueForPlayer(player);

    final investmentValue = gameState.investmentValueForPlayer(player);

    return player.balance +
        propertyValue +
        investmentValue +
        player.startupFund;
  }

  /// Processes the beginning of a new year.
  static void processNewYear(GameState gameState) {
    final year = gameState.currentYear;

    for (final player in gameState.players) {
      BankingService.processLoanYear(player, year);

      BankingService.processInvestmentYear(player, year);
    }
  }

  /// Buys a property for a player.
  static bool buyProperty(
    GameState gameState,
    Player player,
    String propertyId,
  ) {
    final property = gameState.getPropertyById(propertyId);

    if (property == null) {
      return false;
    }

    // Property is already owned.
    if (property.isOwned) {
      return false;
    }

    // Player cannot afford it.
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

  /// Pays rent when a player lands on another
  /// player's property.
  static bool payPropertyRent(
    GameState gameState,
    Player renter,
    String propertyId,
  ) {
    final property = gameState.getPropertyById(propertyId);

    if (property == null || property.ownerId == null) {
      return false;
    }

    // Player cannot pay rent to themselves.
    if (property.ownerId == renter.id.toString()) {
      return false;
    }

    final owner = gameState.getPropertyOwner(propertyId);

    if (owner == null) {
      return false;
    }

    final rent = property.rent;

    renter.removeMoney(rent);
    owner.addMoney(rent);

    renter.addHistory('Paid rent for ${property.name}', -rent);

    owner.addHistory('Received rent from ${renter.name}', rent);

    return true;
  }

  /// Adds the startup income when a player
  /// passes GO.
  static void processStartupGo(Player player) {
    if (!player.hasStartup) {
      return;
    }

    player.startupFund += 200;

    player.addHistory('Startup received +200 at GO', 200);
  }

  /// Fixed solution for a startup event.
  ///
  /// Player pays 200.
  static bool handleStartupFixedOption(Player player) {
    if (!player.hasStartup) {
      return false;
    }

    if (player.balance < 200) {
      return false;
    }

    player.removeMoney(200);

    player.addHistory('Startup event - Fixed solution', -200);

    return true;
  }

  /// Risk option for a startup event.
  ///
  /// The physical board-game dice result is supplied
  /// manually by the user.
  ///
  /// Loss = dice result × 100
  static bool handleStartupRiskOption(Player player, int diceResult) {
    if (!player.hasStartup) {
      return false;
    }

    if (diceResult < 1 || diceResult > 6) {
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
