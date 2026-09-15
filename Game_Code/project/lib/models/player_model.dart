class Player {
  final int id;
  String name;
  String color;
  String pathType;
  String career;
  int salary;

  // Money currently available to spend.
  int balance;

  // Startup information.
  bool hasStartup;
  int startupFund;

  // Board/game information.
  int boardPosition;

  // Properties owned by this player.
  List<String> propertyIds;

  // Active financial products.
  LoanData? loan;
  InvestmentData? investment;

  // Player-specific history.
  List<HistoryEntry> history;

  Player({
    required this.id,
    required this.name,
    required this.color,
    required this.pathType,
    required this.career,
    required this.salary,
    required this.balance,
    this.hasStartup = true,
    this.startupFund = 0,
    this.boardPosition = 0,
    List<String>? propertyIds,
    this.loan,
    this.investment,
    List<HistoryEntry>? history,
  }) : propertyIds = propertyIds ?? [],
       history = history ?? [];

  /// Total value of this player's liquid assets plus supplied property/investment values.
  int calculateTotalAssets({int propertyValue = 0, int investmentValue = 0}) {
    return balance + propertyValue + investmentValue + startupFund;
  }

  void addMoney(int amount) {
    if (amount > 0) balance += amount;
  }

  bool removeMoney(int amount) {
    if (amount < 0 || amount > balance) {
      return false;
    }

    balance -= amount;
    return true;
  }

  void addHistory(String action, int amount) {
    history.add(
      HistoryEntry(action: action, amount: amount, date: DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'pathType': pathType,
      'career': career,
      'salary': salary,
      'balance': balance,
      'hasStartup': hasStartup,
      'startupFund': startupFund,
      'boardPosition': boardPosition,
      'propertyIds': propertyIds,
      'loan': loan?.toJson(),
      'investment': investment?.toJson(),
      'history': history.map((item) => item.toJson()).toList(),
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      color: json['color'] ?? '',
      pathType: json['pathType'] ?? '',
      career: json['career'] ?? '',
      salary: json['salary'] ?? 0,
      balance: json['balance'] ?? 0,
      hasStartup: json['hasStartup'] ?? true,
      startupFund: json['startupFund'] ?? 0,
      boardPosition: json['boardPosition'] ?? 0,
      propertyIds: List<String>.from(json['propertyIds'] ?? []),
      loan: json['loan'] != null
          ? LoanData.fromJson(Map<String, dynamic>.from(json['loan']))
          : null,
      investment: json['investment'] != null
          ? InvestmentData.fromJson(
              Map<String, dynamic>.from(json['investment']),
            )
          : null,
      history: (json['history'] as List? ?? [])
          .map((item) => HistoryEntry.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

/// Loan information.
///
/// MINTED rules:
/// - 10% annual interest
/// - Interest is charged yearly
/// - Principal is repaid at the end of Year 3
class LoanData {
  final int principal;
  final int startYear;

  LoanData({required this.principal, required this.startYear});

  int get annualInterest => (principal * 10 / 100).round();

  // A loan taken in Year 1 is settled at the end of Year 3.
  int get maturityYear => startYear + 2;

  Map<String, dynamic> toJson() => {
        'principal': principal,
        'startYear': startYear,
      };

  factory LoanData.fromJson(Map<String, dynamic> json) {
    return LoanData(
      principal: json['principal'] ?? 0,
      startYear: json['startYear'] ?? 1,
    );
  }
}

/// Investment information.
///
/// MINTED rules:
/// - 5% simple interest
/// - Interest is calculated yearly
/// - Principal + interest is returned at the end of Year 3
class InvestmentData {
  final int principal;
  final int startYear;

  InvestmentData({required this.principal, required this.startYear});

  int get annualInterest => (principal * 5 / 100).round();

  // An investment made in Year 1 matures at the end of Year 3.
  int get maturityYear => startYear + 2;

  int get maturityAmount => principal + (annualInterest * 3);

  Map<String, dynamic> toJson() => {
        'principal': principal,
        'startYear': startYear,
      };

  factory InvestmentData.fromJson(Map<String, dynamic> json) {
    return InvestmentData(
      principal: json['principal'] ?? 0,
      startYear: json['startYear'] ?? 1,
    );
  }
}

class HistoryEntry {
  final String action;
  final int amount;
  final DateTime date;

  HistoryEntry({
    required this.action,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'action': action,
        'amount': amount,
        'date': date.toIso8601String(),
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      action: json['action'] ?? '',
      amount: json['amount'] ?? 0,
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }
}
