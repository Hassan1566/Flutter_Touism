import '../models/game_stat.dart';
import '../models/player_model.dart';

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
    if (player.hasStartup) {
      player.startupFund += 200;

      player.addHistory('Startup income', 200);
    }

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

  /// Charges yearly loan interest.
  ///
  /// MINTED:
  /// Loan interest = 10% annually.
  /// Principal is returned at the end of Year 3.
  static void processLoanYear(Player player, int year) {
    final loan = player.loan;

    if (loan == null) return;

    if (year <= loan.maturityYear) {
      final interest = loan.annualInterest;

      player.removeMoney(interest);

      player.addHistory('Loan interest - Year $year', -interest);
    }

    // Principal is paid at maturity.
    if (year == loan.maturityYear) {
      final principal = loan.principal;

      player.removeMoney(principal);

      player.addHistory('Loan principal repayment', -principal);

      player.loan = null;
    }
  }

  /// Processes yearly investment growth.
  ///
  /// Investment uses simple interest:
  /// 5% per year.
  static void processInvestmentYear(Player player, int year) {
    final investment = player.investment;

    if (investment == null) return;

    if (year < investment.maturityYear) {
      player.addHistory(
        'Investment interest - Year $year',
        investment.annualInterest,
      );
    }

    // Return principal + total interest at maturity.
    if (year == investment.maturityYear) {
      final maturityAmount = investment.maturityAmount;

      player.addMoney(maturityAmount);

      player.addHistory('Investment matured', maturityAmount);

      player.investment = null;
    }
  }

  /// Processes the beginning of a new year.
  static void processNewYear(GameState gameState) {
    final year = gameState.currentYear;

    for (final player in gameState.players) {
      processLoanYear(player, year);
      processInvestmentYear(player, year);
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
}
