import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tentapp/controller/admin_controller.dart';
import 'package:tentapp/views/admin_screens/deliveries.dart';

import '../../data/oders.dart';

class AdminOrdersScreen extends StatefulWidget {
  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final AdminController _adminController = Get.find<AdminController>();

  void onInit() {
    super.initState();
    _adminController.fetchAllPurchaseOrders();
    _adminController.fetchAllRentalOrders();
  }

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
              Tab(text: 'Purchase Orders'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRentalOrdersTab(),
            _buildPurchaseOrdersTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildRentalOrdersTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              _adminController.searchOrders(value);
            },
            decoration: InputDecoration(
              labelText: 'Search',
              hintText: 'Search rental orders...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
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
          }),
        ),
      ],
    );
  }

  Widget _buildPurchaseOrdersTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              _adminController.searchOrders(value);
            },
            decoration: InputDecoration(
              labelText: 'Search',
              hintText: 'Search purchase orders...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (_adminController.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }

            final purchaseOrders = _adminController.purchaseOrders;

            if (purchaseOrders.isEmpty) {
              return Center(
                child: Text('No purchase orders available.'),
              );
            }

            return ListView.builder(
              itemCount: purchaseOrders.length,
              itemBuilder: (context, index) {
                final order = purchaseOrders[index];
                return _buildOrderItem(context, order);
              },
            );
          }),
        ),
      ],
    );
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
        trailing: DropdownButton<String>(
          onChanged: (String? value) {
            if (value == 'reminder') {
              _setReminder(context, order);
            } else if (value == 'delivery') {
              Get.to(() => DeliveryScreen(
                    order: order,
                  ));
              // _goToDelivery(context, order);
            } else if (value == 'mark_paid') {
              //  _markAsPaid(context, order);
              _adminController.updateOrderStatus(order, true, false);
            }
          },
          items: [
            if (order is RentingOrder)
              DropdownMenuItem(
                value: 'reminder',
                child: Row(
                  children: [
                    Icon(Icons.notifications, color: Colors.orange),
                    SizedBox(width: 5),
                    Text('Send Reminder'),
                  ],
                ),
              ),
            DropdownMenuItem(
              value: 'delivery',
              child: Row(
                children: [
                  Icon(Icons.delivery_dining, color: Colors.blue),
                  SizedBox(width: 5),
                  Text('Go to Delivery'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'mark_paid',
              child: Row(
                children: [
                  Icon(Icons.payment, color: Colors.green),
                  SizedBox(width: 5),
                  Text('Mark as Paid'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderActionsDropdown(BuildContext context, dynamic order) {
    return DropdownButton<String>(
      onChanged: (String? value) {
        if (value == 'reminder') {
          _setReminder(context, order);
        }
      },
      items: [
        DropdownMenuItem(
          value: 'reminder',
          child: Row(
            children: [
              Icon(Icons.notifications, color: Colors.orange),
              SizedBox(width: 5),
              Text('Send Reminder'),
            ],
          ),
        ),
      ],
    );
  }

  void _setReminder(BuildContext context, dynamic order) {
    final TextEditingController messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Send Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: 'Enter reminder message...',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String message = messageController.text.trim();
                if (message.isNotEmpty) {
                  await _adminController.sendReminder(order, message);
                  // You might want to show a success message or update the UI after sending the reminder
                  Get.snackbar(
                    'Reminder Sent',
                    'Reminder email sent successfully',
                  );
                } else {
                  Get.snackbar('Error', 'Please enter a reminder message');
                }
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Send Reminder'),
            ),
          ],
        );
      },
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
            TextButton(
              child: Text('Got to delivery'),
              onPressed: () {
                Get.to(() => DeliveryScreen(
                      order: order,
                    ));
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
              if (isDelivered) {
                // Navigate to DeliveryScreen with the selected order
                //Get.to(DeliveryScreen(order: order));
              } else {
                // Update the order status (mark as paid)
                if (order is RentingOrder) {
                  _adminController.updateRentalOrderStatus(
                      order, isPaid, isDelivered);
                } else if (order is PurchaseOrder) {
                  _adminController.updatePurchaseOrderStatus(
                      order, isPaid, isDelivered);
                }
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

/*
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
              Tab(text: 'Purchase Orders'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRentalOrdersTab(),
            _buildPurchaseOrdersTab(),
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

  Widget _buildPurchaseOrdersTab() {
    return Obx(() {
      if (_adminController.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      final hirePurchaseOrders = _adminController.purchaseOrders;

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

  void _setReminder(BuildContext context, dynamic order) {
    final TextEditingController messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Send Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: 'Enter reminder message...',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String message = messageController.text.trim();
                if (message.isNotEmpty) {
                  await _adminController.sendReminder(order, message);
                  // You might want to show a success message or update the UI after sending the reminder
                  Get.snackbar(
                      'Reminder Sent', 'Reminder email sent successfully');
                } else {
                  Get.snackbar('Error', 'Please enter a reminder message');
                }
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Send Reminder'),
            ),
          ],
        );
      },
    );
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
            TextButton(
              child: Text('Got to delivery'),
              onPressed: () {
                Get.to(() => DeliveryScreen(
                      order: order,
                    ));
              },
            ),
            // Checkbox(
            //   value: isDelivered,
            //   onChanged: (value) {
            //     isDelivered = value ?? false;
            //   },
            // ),
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
              if (isDelivered) {
                // Navigate to DeliveryScreen with the selected order
                //Get.to(DeliveryScreen(order: order));
              } else {
                // Update the order status (mark as paid)
                if (order is RentingOrder) {
                  _adminController.updateRentalOrderStatus(
                      order, isPaid, isDelivered);
                } else if (order is PurchaseOrder) {
                  _adminController.updatePurchaseOrderStatus(
                      order, isPaid, isDelivered);
                }
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



*/

class ReturnedDialogue extends StatelessWidget {
  final dynamic order;

  ReturnedDialogue({required this.order});
  AdminController adminController = Get.find();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Rented orders'),
      content: Text(
          'You are about to mark this order as returned. Do you wish to proceed?'),
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
