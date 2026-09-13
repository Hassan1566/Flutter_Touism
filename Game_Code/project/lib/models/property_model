class Property {
  final String id;
  final String name;
  final String category;
  final int price;
  final int rent;
  String? ownerId;

  Property({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rent,
    this.ownerId,
  });

  bool get isOwned => ownerId != null;

  bool get isResidential => category == 'Residential';

  bool get isCommercial => category == 'Commercial';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'rent': rent,
      'ownerId': ownerId,
    };
  }

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: json['price'] ?? 0,
      rent: json['rent'] ?? 0,
      ownerId: json['ownerId'],
    );
  }
}