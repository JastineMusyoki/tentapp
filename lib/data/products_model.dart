import 'dart:convert';

class Tent {
  final String id;
  final String name;
  final String description;
  final List<String> imagePaths;
  final double rentalPrice;
  final double purchasePrice;
  final bool available;

  Tent({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePaths,
    required this.rentalPrice,
    required this.purchasePrice,
    required this.available,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imagePaths': imagePaths,
      'rentalPrice': rentalPrice,
      'purchasePrice': purchasePrice,
      'available': available,
    };
  }

  factory Tent.fromJson(Map<String, dynamic> json) {
    return Tent(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imagePaths: List<String>.from(json['imagePaths']),
      rentalPrice: json['rentalPrice'],
      purchasePrice: json['purchasePrice'],
      available: json['available'],
    );
  }
}
