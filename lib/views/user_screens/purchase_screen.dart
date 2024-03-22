import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:tentapp/controller/admin_controller.dart';

import '../../data/oders.dart';
import '../../data/products_model.dart';

final userdata = GetStorage();
// Your existing imports

class HirePurchaseScreen extends StatefulWidget {
  final Tent tent;

  HirePurchaseScreen({required this.tent});

  @override
  _HirePurchaseScreenState createState() => _HirePurchaseScreenState();
}

class _HirePurchaseScreenState extends State<HirePurchaseScreen> {
  final AdminController _adminController = Get.find<AdminController>();

  late TextEditingController _deliveryInfoController;
  DateTime? _startDate;
  DateTime? _returnDate;
  int _quantity = 1;
  double _totalPrice = 0;

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
        title: Text('Hire ${widget.tent.name}'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: Obx(() {
        return _adminController.isLoading.value
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Select Start and Return Dates:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(DateTime.now().year + 1),
                                );
                                if (selectedDate != null) {
                                  setState(() {
                                    _startDate = selectedDate;
                                    _calculateTotalPrice();
                                  });
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _startDate != null
                                      ? _startDate!.toString().substring(0, 10)
                                      : 'Select Start Date',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _startDate != null
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: _startDate ?? DateTime.now(),
                                  lastDate: DateTime(DateTime.now().year + 1),
                                );
                                if (selectedDate != null) {
                                  setState(() {
                                    _returnDate = selectedDate;
                                    _calculateTotalPrice();
                                  });
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _returnDate != null
                                      ? _returnDate!.toString().substring(0, 10)
                                      : 'Select Return Date',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _returnDate != null
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Select Quantity:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (_quantity > 1) {
                                  _quantity--;
                                  _calculateTotalPrice();
                                }
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
                                _calculateTotalPrice();
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
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Kes. ${_totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: Text(
                          'Delivery Information:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
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
                            _placeHirePurchaseOrder();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            primary: Colors.amber,
                          ),
                          child: Text(
                            'Place Order',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
      }),
    );
  }

  void _calculateTotalPrice() {
    if (_startDate != null && _returnDate != null && _quantity > 0) {
      final days = _returnDate!.difference(_startDate!).inDays;
      _totalPrice = widget.tent.purchasePrice * _quantity * days;
      setState(() {});
    }
  }

  void _placeHirePurchaseOrder() {
    if (_startDate == null || _returnDate == null) {
      Get.snackbar('Error', 'Please select start and return dates');
      return;
    }

    if (_returnDate!.isBefore(_startDate!)) {
      Get.snackbar('Error', 'Return date cannot be before start date');
      return;
    }

    if (_quantity <= 0) {
      Get.snackbar('Error', 'Quantity must be at least 1');
      return;
    }

    if (_deliveryInfoController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter delivery information');
      return;
    }

    String deliveryInfo = _deliveryInfoController.text.trim();
    String userEmail = userdata.read('email');
    String documentId = generateRandomString(length: 10);

    HirePurchaseOrder hirePurchaseOrder = HirePurchaseOrder(
      id: documentId,
      userEmail: userEmail,
      tent: widget.tent,
      quantity: _quantity,
      totalPrice: _totalPrice,
      deliveryInfo: deliveryInfo,
      startDate: _startDate.toString(),
      returnDate: _returnDate.toString(),
      isDelivered: false,
      isPaid: false,
    );

    _adminController.placeHirePurchaseOrder(hirePurchaseOrder);
    Get.back();
  }

  String generateRandomString({int length = 10}) {
    const charset = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }
}
