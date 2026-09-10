class Player {
  final String id;
  String name;
  String color;
  String pathType;
  String career;
  Map<String, dynamic> appValues;
  List<Map<String, dynamic>> history;

  Player({
    required this.id,
    required this.name,
    required this.color,
    required this.pathType,
    required this.career,
    Map<String, dynamic>? appValues,
    List<Map<String, dynamic>>? history,
  }) : appValues = appValues ?? {},
       history = history ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color,
    'pathType': pathType,
    'career': career,
    'appValues': appValues,
    'history': history,
  };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'],
    name: json['name'],
    color: json['color'],
    pathType: json['pathType'],
    career: json['career'],
    appValues: Map<String, dynamic>.from(json['appValues'] ?? {}),
    history: List<Map<String, dynamic>>.from(json['history'] ?? []),
  );
}
