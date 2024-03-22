import 'products_model.dart';

class RentalOrder {
  final String id;
  final String userEmail;
  final Tent tent;
  final int quantity;
  final double totalPrice;
  final String deliveryInfo;
  final DateTime createdAt;
  final bool isPaid;
  final bool isDelivered;

  RentalOrder({
    required this.id,
    required this.userEmail,
    required this.tent,
    required this.quantity,
    required this.totalPrice,
    required this.deliveryInfo,
    required this.createdAt,
    this.isPaid = false,
    this.isDelivered = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userEmail': userEmail,
      'tent': tent.toJson(),
      'quantity': quantity,
      'totalPrice': totalPrice,
      'deliveryInfo': deliveryInfo,
      'createdAt': createdAt.toIso8601String(),
      'isPaid': isPaid,
      'isDelivered': isDelivered,
    };
  }

  factory RentalOrder.fromJson(Map<String, dynamic> json) {
    return RentalOrder(
      id: json['id'],
      userEmail: json['userEmail'],
      tent: Tent.fromJson(json['tent']),
      quantity: json['quantity'],
      totalPrice: json['totalPrice'],
      deliveryInfo: json['deliveryInfo'],
      createdAt: DateTime.parse(json['createdAt']),
      isPaid: json['isPaid'] ?? false,
      isDelivered: json['isDelivered'] ?? false,
    );
  }
}

class HirePurchaseOrder {
  final String id;
  final String userEmail;
  final Tent tent;
  final int quantity;
  final double totalPrice;
  final String deliveryInfo;
  final String startDate;
  final String returnDate;
  final bool isPaid;
  final bool isDelivered;

  HirePurchaseOrder({
    required this.id,
    required this.userEmail,
    required this.tent,
    required this.quantity,
    required this.totalPrice,
    required this.deliveryInfo,
    required this.startDate,
    required this.returnDate,
    this.isPaid = false,
    this.isDelivered = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userEmail': userEmail,
      'tent': tent.toJson(),
      'quantity': quantity,
      'totalPrice': totalPrice,
      'deliveryInfo': deliveryInfo,
      'startDate': startDate,
      'returnDate': returnDate,
      'isPaid': isPaid,
      'isDelivered': isDelivered,
    };
  }

  factory HirePurchaseOrder.fromJson(Map<String, dynamic> json) {
    return HirePurchaseOrder(
      id: json['id'],
      userEmail: json['userEmail'],
      tent: Tent.fromJson(json['tent']),
      quantity: json['quantity'],
      totalPrice: json['totalPrice'],
      deliveryInfo: json['deliveryInfo'],
      startDate: json['startDate'],
      returnDate: json['returnDate'],
      isPaid: json['isPaid'] ?? false,
      isDelivered: json['isDelivered'] ?? false,
    );
  }
}
