import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tentapp/controller/admin_controller.dart';
import 'package:tentapp/data/deliveries_model.dart';

import '../../data/oders.dart';

class DeliveryScreen extends StatelessWidget {
  final dynamic order; // Dynamic type for accepting any order type
  final AdminController _adminController = Get.find<AdminController>();

  // Controllers for form fields
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController vehicleNumberPlateController =
      TextEditingController();
  final TextEditingController vehicleDescriptionController =
      TextEditingController();

  DeliveryScreen({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Details'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: Obx(() {
        if (_adminController.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text('Processing'),
              ],
            ),
          );
        } else {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildOrderDetails(),
                SizedBox(height: 20),
                _buildDeliveryForm(context),
              ],
            ),
          );
        }
      }),
    );
  }

  Widget _buildOrderDetails() {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Number: ${order.id}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text('Delivery for: ${order.userEmail}'),
            SizedBox(height: 8.0),
            // Show additional order details based on the order type (RentalOrder or HirePurchaseOrder)
            if (order is RentalOrder) ...[
              Text('Tent Name: ${order.tent.name}'),
              SizedBox(height: 8.0),
              Text('Quantity: ${order.quantity}'),
              SizedBox(height: 8.0),
              Text('Total Price: KES ${order.totalPrice.toStringAsFixed(2)}'),
            ] else if (order is HirePurchaseOrder) ...[
              Text('Tent Name: ${order.tent.name}'),
              SizedBox(height: 8.0),
              Text('Quantity: ${order.quantity}'),
              SizedBox(height: 8.0),
              Text('Total Price: KES ${order.totalPrice.toStringAsFixed(2)}'),
              SizedBox(height: 8.0),
              Text('Start Date: ${order.startDate}'),
              SizedBox(height: 8.0),
              Text('Return Date: ${order.returnDate}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryForm(BuildContext context) {
    // Implement a form to collect delivery details
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.0),
            _buildInputField(
              context: context,
              labelText: 'Driver Name',
              controller: driverNameController,
              suffixIcon: Icons.person,
            ),
            SizedBox(height: 12.0),
            _buildInputField(
              context: context,
              labelText: 'Phone Number',
              controller: phoneNumberController,
              keyboardType: TextInputType.phone,
              suffixIcon: Icons.phone,
            ),
            SizedBox(height: 12.0),
            _buildInputField(
              context: context,
              labelText: 'Vehicle Number Plate',
              controller: vehicleNumberPlateController,
              suffixIcon: Icons.directions_car,
            ),
            SizedBox(height: 12.0),
            _buildInputField(
              context: context,
              labelText: 'Vehicle Description',
              controller: vehicleDescriptionController,
              suffixIcon: Icons.description,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Handle form submission
                String deliveryId = Random()
                    .nextInt(1000000)
                    .toString(); // Example random ID generation

                // Create the Delivery object with the generated ID and delivery details
                Delivery delivery = Delivery(
                  id: deliveryId,
                  orderId: order.id,
                  driverName: driverNameController.text,
                  phoneNumber: phoneNumberController.text,
                  vehicleNumberPlate: vehicleNumberPlateController.text,
                  vehicleDescription: vehicleDescriptionController.text,
                  isDelivered: false, // Default value for isDelivered
                );

                // Handle form submission by calling the createDelivery method in the AdminController
                _adminController.createDelivery(deliveryId, delivery);
              },
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(4.0),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                shadowColor: MaterialStateProperty.all(Colors.grey),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Submit',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required String labelText,
    required TextEditingController controller,
    IconData? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.5),
              width: 1.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.5),
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
