import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tentapp/controller/admin_controller.dart';

import '../../data/oders.dart';

class AdminOrdersScreen extends StatelessWidget {
  final AdminController _adminController = Get.find<AdminController>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Orders'),
          centerTitle: true,
          backgroundColor: Colors.amberAccent,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Rental Orders'),
              Tab(text: 'Hire Purchase Orders'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRentalOrdersTab(),
            _buildHirePurchaseOrdersTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildRentalOrdersTab() {
    return Obx(() {
      if (_adminController.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      final rentalOrders = _adminController.rentalOrders;

      if (rentalOrders.isEmpty) {
        return Center(
          child: Text('No rental orders available.'),
        );
      }

      return ListView.builder(
        itemCount: rentalOrders.length,
        itemBuilder: (context, index) {
          final order = rentalOrders[index];
          return _buildOrderItem(context, order);
        },
      );
    });
  }

  Widget _buildHirePurchaseOrdersTab() {
    return Obx(() {
      if (_adminController.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      final hirePurchaseOrders = _adminController.hirePurchaseOrders;

      if (hirePurchaseOrders.isEmpty) {
        return Center(
          child: Text('No hire purchase orders available.'),
        );
      }

      return ListView.builder(
        itemCount: hirePurchaseOrders.length,
        itemBuilder: (context, index) {
          final order = hirePurchaseOrders[index];
          return _buildOrderItem(context, order);
        },
      );
    });
  }

  Widget _buildOrderItem(BuildContext context, dynamic order) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text('Order ID: ${order.id}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User Email: ${order.userEmail}'),
            Text('Total Price: \Kes. ${order.totalPrice.toStringAsFixed(2)}'),
            Text('Paid: ${order.isPaid ? 'Yes' : 'No'}'),
            Text('Delivered: ${order.isDelivered ? 'Yes' : 'No'}'),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            _showUpdateStatusDialog(context, order);
          },
        ),
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context, dynamic order) {
    bool isPaid = order.isPaid;
    bool isDelivered = order.isDelivered;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Mark as Paid'),
            Checkbox(
              value: isPaid,
              onChanged: (value) {
                isPaid = value ?? false;
              },
            ),
            Text('Mark as Delivered'),
            Checkbox(
              value: isDelivered,
              onChanged: (value) {
                isDelivered = value ?? false;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (order is RentalOrder) {
                _adminController.updateRentalOrderStatus(
                    order, isPaid, isDelivered);
              } else if (order is HirePurchaseOrder) {
                _adminController.updateHirePurchaseOrderStatus(
                    order, isPaid, isDelivered);
              }
              Navigator.of(context).pop();
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
}

// class AdminOrdersScreen extends StatelessWidget {
//   final AdminController _adminController = Get.find<AdminController>();

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('Admin Orders'),
//           centerTitle: true,
//           backgroundColor: Colors.amberAccent,
//           bottom: TabBar(
//             tabs: [
//               Tab(text: 'Rental Orders'),
//               Tab(text: 'Hire Purchase Orders'),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             _buildRentalOrdersTab(),
//             _buildHirePurchaseOrdersTab(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRentalOrdersTab() {
//     return Obx(() {
//       if (_adminController.isLoading.value) {
//         return Center(child: CircularProgressIndicator());
//       }

//       final rentalOrders = _adminController.rentalOrders;

//       if (rentalOrders.isEmpty) {
//         return Center(
//           child: Text('No rental orders available.'),
//         );
//       }

//       return ListView.builder(
//         itemCount: rentalOrders.length,
//         itemBuilder: (context, index) {
//           final order = rentalOrders[index];
//           return _buildOrderItem(context, order);
//         },
//       );
//     });
//   }

//   Widget _buildHirePurchaseOrdersTab() {
//     return Obx(() {
//       if (_adminController.isLoading.value) {
//         return Center(child: CircularProgressIndicator());
//       }

//       final hirePurchaseOrders = _adminController.hirePurchaseOrders;

//       if (hirePurchaseOrders.isEmpty) {
//         return Center(
//           child: Text('No hire purchase orders available.'),
//         );
//       }

//       return ListView.builder(
//         itemCount: hirePurchaseOrders.length,
//         itemBuilder: (context, index) {
//           final order = hirePurchaseOrders[index];
//           return _buildOrderItem(context, order);
//         },
//       );
//     });
//   }

//   Widget _buildOrderItem(BuildContext context, dynamic order) {
//     return ListTile(
//       title: Text('Order ID: ${order.id}'),
//       subtitle: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('User Email: ${order.userEmail}'),
//           Text('Total Price: ${order.totalPrice.toStringAsFixed(2)}'),
//           // Add more order details as needed
//         ],
//       ),
//       trailing: IconButton(
//         icon: Icon(Icons.cancel),
//         onPressed: () {
//           _showCancelOrderDialog(context, order);
//         },
//       ),
//     );
//   }

//   void _showCancelOrderDialog(BuildContext context, dynamic order) {
//     showDialog(
//       context: context,
//       builder: (context) => CancelOrderDialog(order: order),
//     );
//   }
// }

class CancelOrderDialog extends StatelessWidget {
  final dynamic order;

  CancelOrderDialog({required this.order});
  AdminController adminController = Get.find();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cancel Order'),
      content: Text('Are you sure you want to cancel this order?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('No'),
        ),
        TextButton(
          onPressed: () {
            // Perform the cancellation logic here
            // For example, you might call a method in your controller
            // to delete the order from the database
            adminController.cancelOrder(order);
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Yes'),
        ),
      ],
    );
  }
}
