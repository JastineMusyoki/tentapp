import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tentapp/views/user_screens/rental_screen.dart';

import '../../controller/admin_controller.dart';
import '../../data/products_model.dart';
import 'purchase_screen.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tentapp/controller/admin_controller.dart';
import 'package:tentapp/views/user_screens/purchase_screen.dart';
import 'package:tentapp/views/user_screens/rental_screen.dart';

class ProductsScreen extends StatelessWidget {
  final AdminController _adminController = Get.find<AdminController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Fetch all tents when the screen is first loaded
    _adminController.fetchTents();

    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: Obx(() {
        return _adminController.isLoading.value
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _buildListingsUI();
      }),
    );
  }

  Widget _buildListingsUI() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name...',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  _startSearch();
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _adminController.filteredTents.length,
              itemBuilder: (context, index) {
                return _buildProductCard(_adminController.filteredTents[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Tent tent) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          tent.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 200.0,
                aspectRatio: 16 / 9,
                viewportFraction: 0.9,
                enableInfiniteScroll: false,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 1200),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
              ),
              items: tent.imagePaths.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            Text('Description: ${tent.description}'),
            SizedBox(height: 5),
            Text('Rental Price: ${tent.rentalPrice.toStringAsFixed(2)}'),
            Text('Purchase Price: ${tent.purchasePrice.toStringAsFixed(2)}'),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle rent button click
                    Get.to(RentScreen(tent: tent));
                  },
                  child: Text('Purchase'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle purchase button click
                    Get.to(HirePurchaseScreen(tent: tent));
                  },
                  child: Text('Rent'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startSearch() {
    _adminController.searchTents(_searchController.text);
  }
}





/*
class ProductsScreen extends StatelessWidget {
  final AdminController _adminController = Get.find<AdminController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Fetch all tents when the screen is first loaded
    _adminController.fetchTents();

    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        centerTitle: true,
        backgroundColor: Colors.amber,
        
      ),
      body: Obx(() {
        return _adminController.isLoading.value
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _buildListingsUI();
      }),
    );
  }

  Widget _buildListingsUI() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name...',
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                },
              ),
            ),
            onChanged: (value) {
              // Perform search based on the entered text
              _adminController.searchTents(value);
            },
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _adminController.filteredTents.length,
              itemBuilder: (context, index) {
                return _buildProductCard(_adminController.filteredTents[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Tent tent) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          tent.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 200.0,
                aspectRatio: 16 / 9,
                viewportFraction: 0.9,
                enableInfiniteScroll: false,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 1200),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
              ),
              items: tent.imagePaths.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            Text('Description: ${tent.description}'),
            SizedBox(height: 5),
            Text('Rental Price: ${tent.rentalPrice.toStringAsFixed(2)}'),
            Text('Purchase Price: ${tent.purchasePrice.toStringAsFixed(2)}'),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle rent button click
                    Get.to(RentScreen(tent: tent));
                  },
                  child: Text('Purchase'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle purchase button click
                    Get.to(HirePurchaseScreen(tent: tent));
                  },
                  child: Text('Rent'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search by Product Name'),
        content: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Enter product name...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Perform search based on the entered text
              _adminController.searchTents(_searchController.text);
              Navigator.pop(context);
            },
            child: Text('Search'),
          ),
        ],
      ),
    );
  }
}
*/