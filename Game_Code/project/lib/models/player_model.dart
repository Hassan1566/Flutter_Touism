class Player {
  final String id;
  String name;
  String color;
  String pathType; // "College" or "Non-College"
  String career;
  int salary;
  int balance; // Starts at 2500 minus college fee if applicable
  int startupFund;
  Map<String, dynamic> activeLoan;
  Map<String, dynamic> activeInvestment;
  List<Map<String, dynamic>> history;

  Player({
    required this.id,
    required this.name,
    required this.color,
    required this.pathType,
    required this.career,
    required this.salary,
    required this.balance,
    this.startupFund = 0,
    Map<String, dynamic>? activeLoan,
    Map<String, dynamic>? activeInvestment,
    List<Map<String, dynamic>>? history,
  }) : activeLoan = activeLoan ?? {},
       activeInvestment = activeInvestment ?? {},
       history = history ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color,
    'pathType': pathType,
    'career': career,
    'salary': salary,
    'balance': balance,
    'startupFund': startupFund,
    'activeLoan': activeLoan,
    'activeInvestment': activeInvestment,
    'history': history,
  };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'],
    name: json['name'],
    color: json['color'],
    pathType: json['pathType'],
    career: json['career'],
    salary: json['salary'],
    balance: json['balance'],
    startupFund: json['startupFund'],
    activeLoan: Map<String, dynamic>.from(json['activeLoan'] ?? {}),
    activeInvestment: Map<String, dynamic>.from(json['activeInvestment'] ?? {}),
    history: List<Map<String, dynamic>>.from(json['history'] ?? []),
  );
}
