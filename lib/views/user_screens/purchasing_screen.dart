import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../controller/admin_controller.dart';
import '../../data/oders.dart';
import '../../data/products_model.dart';

final userdata = GetStorage();

class PurchasingScreen extends StatefulWidget {
  final Tent tent;

  PurchasingScreen({required this.tent});

  @override
  _PurchasingScreenState createState() => _PurchasingScreenState();
}

class _PurchasingScreenState extends State<PurchasingScreen> {
  final AdminController _adminController = Get.find<AdminController>();

  int _quantity = 1;
  late TextEditingController _deliveryInfoController;

  @override
  void initState() {
    super.initState();
    _deliveryInfoController = TextEditingController();
  }

  @override
  void dispose() {
    _deliveryInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase ${widget.tent.name}'),
        backgroundColor: Colors.amber,
      ),
      body: Obx(() {
        return _adminController.isLoading.value
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _buildPurchaseForm();
      }),
    );
  }

  Widget _buildPurchaseForm() {
    double totalPrice = widget.tent.rentalPrice * _quantity;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Quantity:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_quantity > 1) _quantity--;
                    });
                  },
                  icon: Icon(Icons.remove),
                ),
                Text(
                  _quantity.toString(),
                  style: TextStyle(fontSize: 18),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                  icon: Icon(Icons.add),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Total Price:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Kes. ${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Enter Delivery Information:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _deliveryInfoController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter delivery information...',
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _placePurchaseOrder();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.amberAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Place Order',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _placePurchaseOrder() {
    if (_quantity <= 0) {
      Get.snackbar('Error', 'Quantity must be at least 1');
      return;
    }

    double totalPrice = widget.tent.rentalPrice * _quantity;
    String deliveryInfo = _deliveryInfoController.text.trim();
    String userEmail = userdata.read('email');
    String documentId = generateRandomString(length: 10);

    PurchaseOrder purchaseOrder = PurchaseOrder(
        id: documentId,
        userEmail: userEmail,
        tent: widget.tent,
        quantity: _quantity,
        totalPrice: totalPrice,
        deliveryInfo: deliveryInfo,
        isDelivered: false,
        isPaid: false);

    _adminController.placePurchaseOrder(purchaseOrder);

    // Navigate back or show confirmation
    Get.back();
  }

  String generateRandomString({int length = 10}) {
    const charset = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }
}
