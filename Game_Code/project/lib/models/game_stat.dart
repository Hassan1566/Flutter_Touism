import '../models/player_model.dart';
import '../models/property_model.dart';
import '../services/game_service.dart';

class GameState {
  List<Player> players;
  List<Property> properties;
  int activePlayerIndex;
  int currentYear;
  final int maxYears;
  bool isGameStarted;
  bool isGameFinished;

  GameState({
    List<Player>? players,
    List<Property>? properties,
    this.activePlayerIndex = 0,
    this.currentYear = 1,
    this.maxYears = 3,
    this.isGameStarted = true,
    this.isGameFinished = false,
  }) : players = players ?? [], properties = properties ?? [];

  Player get activePlayer => players[activePlayerIndex];
  int get playerCount => players.length;

  bool nextTurn() {
    if (players.isEmpty || isGameFinished) return false;

    if (activePlayerIndex < players.length - 1) {
      activePlayerIndex++;
      return false;
    }

    activePlayerIndex = 0;
    advanceYear();
    return true;
  }

  /// Completes the current year, processes yearly banking, then either
  /// starts the next year or finishes the game after Year 3.
  void advanceYear() {
    if (currentYear >= maxYears) {
      GameService.processNewYear(this, currentYear);
      isGameFinished = true;
      return;
    }

    GameService.processNewYear(this, currentYear);
    currentYear++;
  }

  Player? getPlayerById(int playerId) {
    for (final player in players) {
      if (player.id == playerId) return player;
    }
    return null;
  }

  Property? getPropertyById(String propertyId) {
    for (final property in properties) {
      if (property.id == propertyId) return property;
    }
    return null;
  }

  Player? getPropertyOwner(String propertyId) {
    final property = getPropertyById(propertyId);
    if (property == null || property.ownerId == null) return null;
    return getPlayerById(int.tryParse(property.ownerId!) ?? -1);
  }

  bool purchaseProperty(int playerId, String propertyId) {
    final player = getPlayerById(playerId);
    final property = getPropertyById(propertyId);
    if (player == null || property == null || property.isOwned) return false;
    if (!player.removeMoney(property.price)) return false;

    property.ownerId = player.id.toString();
    if (!player.propertyIds.contains(property.id)) {
      player.propertyIds.add(property.id);
    }
    player.addHistory('Purchased ${property.name}', -property.price);
    return true;
  }

  bool payRent(int renterId, String propertyId) {
    final renter = getPlayerById(renterId);
    final property = getPropertyById(propertyId);
    if (renter == null || property == null || !property.isOwned) return false;
    if (property.ownerId == renter.id.toString()) return false;

    final owner = getPropertyOwner(propertyId);
    if (owner == null || !renter.removeMoney(property.rent)) return false;

    owner.addMoney(property.rent);
    renter.addHistory('Paid rent for ${property.name}', -property.rent);
    owner.addHistory('Received rent from ${renter.name}', property.rent);
    return true;
  }

  int propertyValueForPlayer(Player player) {
    int total = 0;
    for (final property in properties) {
      if (property.ownerId == player.id.toString()) total += property.price;
    }
    return total;
  }

  int investmentValueForPlayer(Player player) {
    return player.investment?.principal ?? 0;
  }

  /// Net worth includes cash, property, active investment principal and
  /// startup funds, less outstanding loan principal.
  int calculateNetWorth(Player player) {
    return player.balance +
        propertyValueForPlayer(player) +
        investmentValueForPlayer(player) +
        player.startupFund -
        (player.loan?.principal ?? 0);
  }

  Player? getWinner() {
    if (players.isEmpty) return null;
    Player winner = players.first;
    for (final player in players.skip(1)) {
      if (calculateNetWorth(player) > calculateNetWorth(winner)) {
        winner = player;
      }
    }
    return winner;
  }

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

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      players: (json['players'] as List? ?? [])
          .map((player) => Player.fromJson(Map<String, dynamic>.from(player)))
          .toList(),
      properties: (json['properties'] as List? ?? [])
          .map((property) => Property.fromJson(Map<String, dynamic>.from(property)))
          .toList(),
      activePlayerIndex: json['activePlayerIndex'] ?? 0,
      currentYear: json['currentYear'] ?? 1,
      maxYears: json['maxYears'] ?? 3,
      isGameStarted: json['isGameStarted'] ?? true,
      isGameFinished: json['isGameFinished'] ?? false,
    );
  }
}
