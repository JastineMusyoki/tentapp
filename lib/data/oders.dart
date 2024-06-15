import 'products_model.dart';

class PurchaseOrder {
  final String id;
  final String userEmail;
  final Tent tent;
  final int quantity;
  final double totalPrice;
  final String deliveryInfo;

  final bool isPaid;
  final bool isDelivered;

  PurchaseOrder({
    required this.id,
    required this.userEmail,
    required this.tent,
    required this.quantity,
    required this.totalPrice,
    required this.deliveryInfo,
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
      'isPaid': isPaid,
      'isDelivered': isDelivered,
    };
  }

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'],
      userEmail: json['userEmail'],
      tent: Tent.fromJson(json['tent']),
      quantity: json['quantity'],
      totalPrice: json['totalPrice'],
      deliveryInfo: json['deliveryInfo'],
      isPaid: json['isPaid'] ?? false,
      isDelivered: json['isDelivered'] ?? false,
    );
  }
}

class RentingOrder {
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
  final bool? returned;

  RentingOrder(
      {required this.id,
      required this.userEmail,
      required this.tent,
      required this.quantity,
      required this.totalPrice,
      required this.deliveryInfo,
      required this.startDate,
      required this.returnDate,
      this.isPaid = false,
      this.isDelivered = false,
      this.returned = false});

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
      'returned': returned
    };
  }

  factory RentingOrder.fromJson(Map<String, dynamic> json) {
    return RentingOrder(
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
      returned: json['returned'] ?? false,
    );
  }
}
