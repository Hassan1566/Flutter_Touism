import 'player_model.dart';
import 'property_model.dart';

class GameState {
  /// All players in the current game.
  List<Player> players;

  /// All properties available in MINTED.
  List<Property> properties;

  /// Index of the player whose turn it currently is.
  int activePlayerIndex;

  /// Current game year.
  int currentYear;

  /// Maximum number of years in the game.
  final int maxYears;

  /// Whether the game has started.
  bool isGameStarted;

  /// Whether the game has finished.
  bool isGameFinished;

  GameState({
    List<Player>? players,
    List<Property>? properties,
    this.activePlayerIndex = 0,
    this.currentYear = 1,
    this.maxYears = 3,
    this.isGameStarted = true,
    this.isGameFinished = false,
  }) : players = players ?? [],
       properties = properties ?? [];

  /// Returns the player whose turn it currently is.
  Player get activePlayer {
    return players[activePlayerIndex];
  }

  /// Number of players.
  int get playerCount {
    return players.length;
  }

  /// Move to the next player.
  ///
  /// When the last player finishes their turn,
  /// a new year begins.
  bool nextTurn() {
    if (players.isEmpty || isGameFinished) {
      return false;
    }

    if (activePlayerIndex < players.length - 1) {
      activePlayerIndex++;
      return false;
    }

    // Last player completed the round.
    activePlayerIndex = 0;

    advanceYear();

    return true;
  }

  /// Advance the game by one year.
  void advanceYear() {
    if (currentYear >= maxYears) {
      isGameFinished = true;
      return;
    }

    currentYear++;
  }

  /// Find a player by ID.
  Player? getPlayerById(int playerId) {
    for (final player in players) {
      if (player.id == playerId) {
        return player;
      }
    }

    return null;
  }

  /// Find a property by ID.
  Property? getPropertyById(String propertyId) {
    for (final property in properties) {
      if (property.id == propertyId) {
        return property;
      }
    }

    return null;
  }

  /// Find the player who owns a property.
  Player? getPropertyOwner(String propertyId) {
    final property = getPropertyById(propertyId);

    if (property == null || property.ownerId == null) {
      return null;
    }

    return getPlayerById(int.tryParse(property.ownerId!) ?? -1);
  }

  /// Purchase a property for a player.
  ///
  /// Returns false if:
  /// - player doesn't exist
  /// - property doesn't exist
  /// - property is already owned
  /// - player cannot afford it
  bool purchaseProperty(int playerId, String propertyId) {
    final player = getPlayerById(playerId);
    final property = getPropertyById(propertyId);

    if (player == null || property == null) {
      return false;
    }

    if (property.isOwned) {
      return false;
    }

    if (!player.removeMoney(property.price)) {
      return false;
    }

    property.ownerId = player.id.toString();

    if (!player.propertyIds.contains(property.id)) {
      player.propertyIds.add(property.id);
    }

    player.addHistory('Purchased ${property.name}', -property.price);

    return true;
  }

  /// Charge rent when a player lands on another
  /// player's property.
  ///
  /// Returns false if rent cannot be charged.
  bool payRent(int renterId, String propertyId) {
    final renter = getPlayerById(renterId);
    final property = getPropertyById(propertyId);

    if (renter == null || property == null) {
      return false;
    }

    if (!property.isOwned) {
      return false;
    }

    if (property.ownerId == renter.id.toString()) {
      return false;
    }

    final owner = getPropertyOwner(propertyId);

    if (owner == null) {
      return false;
    }

    if (!renter.removeMoney(property.rent)) {
      return false;
    }

    owner.addMoney(property.rent);

    renter.addHistory('Paid rent for ${property.name}', -property.rent);

    owner.addHistory('Received rent from ${renter.name}', property.rent);

    return true;
  }

  /// Calculate the value of properties owned by a player.
  int propertyValueForPlayer(Player player) {
    int total = 0;

    for (final property in properties) {
      if (property.ownerId == player.id.toString()) {
        total += property.price;
      }
    }

    return total;
  }

  /// Calculate the current investment value.
  int investmentValueForPlayer(Player player) {
    if (player.investment == null) {
      return 0;
    }

    return player.investment!.principal;
  }

  /// Calculate a player's net worth.
  ///
  /// Cash + property value + investment value - loan liability.
  int calculateNetWorth(Player player) {
    final propertyValue = propertyValueForPlayer(player);
    final investmentValue = investmentValueForPlayer(player);
    final loanAmount = player.loan?.principal ?? 0;

    return player.balance + propertyValue + investmentValue - loanAmount;
  }

  /// Find the current richest player.
  Player? getWinner() {
    if (players.isEmpty) {
      return null;
    }

    Player winner = players.first;

    for (final player in players.skip(1)) {
      if (calculateNetWorth(player) > calculateNetWorth(winner)) {
        winner = player;
      }
    }

    return winner;
  }

  /// Convert the complete game state to JSON.
  Map<String, dynamic> toJson() {
    return {
      'players': players.map((player) => player.toJson()).toList(),
      'properties': properties.map((property) => property.toJson()).toList(),
      'activePlayerIndex': activePlayerIndex,
      'currentYear': currentYear,
      'maxYears': maxYears,
      'isGameStarted': isGameStarted,
      'isGameFinished': isGameFinished,
    };
  }

  /// Restore a game state from JSON.
  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      players: (json['players'] as List? ?? [])
          .map((player) => Player.fromJson(Map<String, dynamic>.from(player)))
          .toList(),
      properties: (json['properties'] as List? ?? [])
          .map(
            (property) =>
                Property.fromJson(Map<String, dynamic>.from(property)),
          )
          .toList(),
      activePlayerIndex: json['activePlayerIndex'] ?? 0,
      currentYear: json['currentYear'] ?? 1,
      maxYears: json['maxYears'] ?? 3,
      isGameStarted: json['isGameStarted'] ?? true,
      isGameFinished: json['isGameFinished'] ?? false,
    );
  }
}
