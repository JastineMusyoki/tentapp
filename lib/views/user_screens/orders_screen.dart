import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tentapp/controller/admin_controller.dart';

class OrdersScreen extends StatelessWidget {
  final AdminController _adminController = Get.find<AdminController>();

  @override
  Widget build(BuildContext context) {
    _adminController.fetchAllHirePurchaseOrders();
    _adminController.fetchAllRentalOrders();
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: Stack(
        children: [
          _buildOrdersContent(),
          Obx(() {
            return _adminController.isLoading.value
                ? Center(child: CircularProgressIndicator())
                : SizedBox(); // Placeholder when not loading
          }),
        ],
      ),
    );
  }

  Widget _buildOrdersContent() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Rental'),
              Tab(text: 'Purchase'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildHirePurchaseOrders(),
                _buildRentalOrders(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHirePurchaseOrders() {
    return Obx(() {
      final userdata = GetStorage();
      final useremail = userdata.read('email');
      final userOrders = _adminController.hirePurchaseOrders
          .where((order) => order.userEmail == useremail)
          .toList();

      if (userOrders.isEmpty) {
        return Center(
          child: Text('No current hire purchase orders'),
        );
      }

      return ListView.builder(
        itemCount: userOrders.length,
        itemBuilder: (context, index) {
          final order = userOrders[index];
          return ListTile(
            title: Text('Order ID: ${order.id}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Price: ${order.totalPrice.toStringAsFixed(2)}'),
                _buildStatusIndicator(order.isDelivered, order.isPaid),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    _showCancelOrderDialog(context, order);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.payment),
                  onPressed: () {
                    _showPaymentDialog(context, order);
                  },
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildRentalOrders() {
    final userdata = GetStorage();
    final _userEmail = userdata.read('email');
    return Obx(() {
      final userOrders = _adminController.rentalOrders
          .where((order) => order.userEmail == _userEmail)
          .toList();

      if (userOrders.isEmpty) {
        return Center(
          child: Text('No current rental orders'),
        );
      }

      return ListView.builder(
        itemCount: userOrders.length,
        itemBuilder: (context, index) {
          final order = userOrders[index];
          return ListTile(
            title: Text('Order ID: ${order.id}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Price: ${order.totalPrice.toStringAsFixed(2)}'),
                _buildStatusIndicator(order.isDelivered, order.isPaid),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    _showCancelOrderDialog(context, order);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.payment),
                  onPressed: () {
                    _showPaymentDialog(context, order);
                  },
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildStatusIndicator(bool isDelivered, bool isPaid) {
    return Row(
      children: [
        Icon(
          isDelivered ? Icons.check_circle : Icons.cancel,
          color: isDelivered ? Colors.green : Colors.red,
        ),
        SizedBox(width: 5),
        Text(
          isDelivered ? 'Delivered' : 'Not Delivered',
          style: TextStyle(color: isDelivered ? Colors.green : Colors.red),
        ),
        SizedBox(width: 10),
        Icon(
          isPaid ? Icons.check_circle : Icons.cancel,
          color: isPaid ? Colors.green : Colors.red,
        ),
        SizedBox(width: 5),
        Text(
          isPaid ? 'Paid' : 'Not Paid',
          style: TextStyle(color: isPaid ? Colors.green : Colors.red),
        ),
      ],
    );
  }

  void _showPaymentDialog(BuildContext context, dynamic order) {
    TextEditingController phoneController = TextEditingController();
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  hintText: '(e.g., 2547********)',
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                phoneController.dispose();
                amountController.dispose();
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String userPhone = phoneController.text;
                double amount = double.tryParse(amountController.text) ?? 0.0;

                if (userPhone.isNotEmpty && amount > 0) {
                  await _adminController.startCheckout(
                      userPhone: userPhone, amount: amount, order: order);
                } else {
                  Get.snackbar(
                    'Error',
                    'Please enter a valid phone number and amount',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
                phoneController.dispose();
                amountController.dispose();
                Navigator.of(context).pop();
              },
              child: Text('Pay'),
            ),
          ],
        );
      },
    );
  }

  void _showCancelOrderDialog(BuildContext context, dynamic order) {
    showDialog(
      context: context,
      builder: (context) => CancelOrderDialog(order: order),
    );
  }
}

//cancel
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
