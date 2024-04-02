class Delivery {
  final String id;
  final String orderId;
  final String driverName;
  final String phoneNumber;
  final String vehicleNumberPlate;
  final String vehicleDescription;
  final bool isDelivered;

  Delivery({
    required this.id,
    required this.orderId,
    required this.driverName,
    required this.phoneNumber,
    required this.vehicleNumberPlate,
    required this.vehicleDescription,
    required this.isDelivered,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'driverName': driverName,
      'phoneNumber': phoneNumber,
      'vehicleNumberPlate': vehicleNumberPlate,
      'vehicleDescription': vehicleDescription,
      'isDelivered': isDelivered,
    };
  }

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'],
      orderId: json['orderId'],
      driverName: json['driverName'],
      phoneNumber: json['phoneNumber'],
      vehicleNumberPlate: json['vehicleNumberPlate'],
      vehicleDescription: json['vehicleDescription'],
      isDelivered: json['isDelivered'] ?? false,
    );
  }
}
