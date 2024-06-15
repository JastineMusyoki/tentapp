// screens/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tentapp/controller/admin_controller.dart';
import 'package:tentapp/controller/auth_controller.dart';
import 'package:tentapp/views/admin_screens/admin_orders.dart';
import 'package:tentapp/views/admin_screens/create_product.dart';
import 'package:tentapp/views/admin_screens/deliveries_list.dart';

import 'product_listings.dart';

// screens/admin_dashboard.dart

class AdminDashboard extends StatelessWidget {
  AuthController authController = Get.find();
  AdminController controller = Get.put(AdminController());
  
  AdminDashboard({required this.authController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => authController.logout(),
          child: Icon(Icons.logout_rounded),
        ),
        title: Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.amberAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigate to the Orders screen
              //  Get.to(OrdersScreen());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, Admin!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the Orders screen
                Get.to(AdminOrdersScreen());
              },
              child: Text(
                'View Orders',
                style: TextStyle(color: Colors.amber),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.deepPurple,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the CreateProductsScreen
                Get.to(AddProductPage());
              },
              child: Text('Add Product'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the ProductListScreen
                Get.to(ManageListingsPage());
              },
              child: Text('Product List'),
              style: ElevatedButton.styleFrom(
                primary: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the ProductListScreen
                Get.to(AdminDeliveriesScreen());
              },
              child: Text('Deliveries', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                primary: Colors.blueGrey,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                authController.logout();
              },
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
