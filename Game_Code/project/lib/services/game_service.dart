import '../models/game_stat.dart';
import '../models/player_model.dart';
import 'banking_service.dart';

class GameService {
  /// MINTED hybrid GO processing:
  /// salary + startup + 10% tax on total assets.
  static void processGo(GameState gameState, Player player) {
    if (player.salary > 0) {
      player.addMoney(player.salary);
      player.addHistory('Payday salary', player.salary);
    }

    processStartupGo(player);

    final totalAssets = _calculateAssetsBeforeTax(gameState, player);
    final tax = (totalAssets * 0.10).round();

    if (tax > 0) {
      final actualTax = tax > player.balance ? player.balance : tax;
      player.removeMoney(actualTax);
      player.addHistory('GO tax', -actualTax);
    }
  }

  static int _calculateAssetsBeforeTax(GameState gameState, Player player) {
    return player.balance +
        gameState.propertyValueForPlayer(player) +
        gameState.investmentValueForPlayer(player) +
        player.startupFund;
  }

  /// Processes the completed game year.
  /// Banking examples from the game rules are represented by the services:
  /// 10% annual loan interest and 5% simple investment interest.
  static void processNewYear(GameState gameState, int year) {
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
    if (property == null || property.isOwned) return false;
    if (player.balance < property.price) return false;

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
    if (property == null || property.ownerId == null) return false;
    if (property.ownerId == renter.id.toString()) return false;

    final owner = gameState.getPropertyOwner(propertyId);
    if (owner == null) return false;
    if (!renter.removeMoney(property.rent)) return false;

    owner.addMoney(property.rent);
    renter.addHistory('Paid rent for ${property.name}', -property.rent);
    owner.addHistory('Received rent from ${renter.name}', property.rent);
    return true;
  }

  static void processStartupGo(Player player) {
    if (!player.hasStartup) return;
    player.startupFund += 200;
    player.addHistory('Startup received +200 at GO', 200);
  }

  static bool handleStartupFixedOption(Player player) {
    if (!player.hasStartup || player.balance < 200) return false;
    player.removeMoney(200);
    player.addHistory('Startup event - Fixed solution', -200);
    return true;
  }

  static bool handleStartupRiskOption(Player player, int diceResult) {
    if (!player.hasStartup || diceResult < 1 || diceResult > 6) return false;

    final amount = diceResult * 100;
    if (player.balance < amount) return false;

    player.removeMoney(amount);
    player.addHistory('Startup event - Risk ($diceResult x 100)', -amount);
    return true;
  }
}
