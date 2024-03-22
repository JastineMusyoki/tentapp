// ignore: must_be_immutable
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tentapp/controller/admin_controller.dart';

import '../../controller/auth_controller.dart';
import 'orders_screen.dart';
import 'user_products.dart';

class UserDashboard extends StatelessWidget {
  final AuthController authController = Get.find();
  final AdminController adminController = Get.put(AdminController());
  final storage = GetStorage();

  @override
  Widget build(BuildContext context) {
    String username = storage.read('username') ?? '';
    String email = storage.read('email') ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0,
        title: Text(
          "Tent App",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                authController.logout();
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Welcome, $username!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildDashboardItem(
              'Explore Our Products',
              'View our latest collection',
              Icons.shopping_basket,
              Colors.deepPurple,
              () {
                Get.to(ProductsScreen());
              },
            ),
            SizedBox(height: 20),
            _buildDashboardItem(
              'View Your Orders',
              'Track your order status',
              Icons.shopping_cart,
              Colors.blueAccent,
              () {
                Get.to(OrdersScreen());
              },
            ),
            SizedBox(height: 20),
            // _buildDashboardItem(
            //   'Account Information',
            //   'View and edit your account details',
            //   Icons.account_circle,
            //   Colors.green,
            //   () {
            //     // Navigate to Account Information screen
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    Function()? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.grey[200],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            Icon(
              icon,
              size: 40,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
