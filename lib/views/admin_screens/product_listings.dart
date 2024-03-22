import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/admin_controller.dart';

import 'package:carousel_slider/carousel_slider.dart';

import '../../data/products_model.dart';

class ManageListingsPage extends StatelessWidget {
  final AdminController _adminController = Get.find<AdminController>();

  @override
  Widget build(BuildContext context) {
    _adminController.fetchTents();
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Listings'),
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
      child: ListView.builder(
        itemCount: _adminController.tents.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4.0,
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(
                _adminController.tents[index].name,
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
                    items: _adminController.tents[index].imagePaths
                        .map((imageUrl) {
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
                  Text(
                      'Description: ${_adminController.tents[index].description}'),
                  SizedBox(height: 5),
                  Text(
                      'Rental Price: ${_adminController.tents[index].rentalPrice.toStringAsFixed(2)}'),
                  Text(
                      'Purchase Price: ${_adminController.tents[index].purchasePrice.toStringAsFixed(2)}'),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _showEditDialog(
                              context, _adminController.tents[index]);
                        },
                        child: Text('Edit'),
                      ),
                      TextButton(
                        onPressed: () {
                          _showDeleteDialog(
                              context, _adminController.tents[index]);
                        },
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Function to show edit dialog
  void _showEditDialog(BuildContext context, Tent tent) {
    TextEditingController nameController =
        TextEditingController(text: tent.name);
    TextEditingController descriptionController =
        TextEditingController(text: tent.description);
    TextEditingController rentalPriceController =
        TextEditingController(text: tent.rentalPrice.toString());
    TextEditingController purchasePriceController =
        TextEditingController(text: tent.purchasePrice.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Tent'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextFormField(
                  controller: rentalPriceController,
                  decoration: InputDecoration(labelText: 'Rental Price'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: purchasePriceController,
                  decoration: InputDecoration(labelText: 'Purchase Price'),
                  keyboardType: TextInputType.number,
                ),
              ],
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
                Tent updatedTent = Tent(
                    id: tent.id,
                    name: nameController.text,
                    description: descriptionController.text,
                    rentalPrice: double.parse(rentalPriceController.text),
                    purchasePrice: double.parse(purchasePriceController.text),
                    imagePaths: tent.imagePaths,
                    available: true);
                _adminController.editTent(updatedTent);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to show delete dialog
  void _showDeleteDialog(BuildContext context, Tent tent) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Tent'),
          content: Text('Are you sure you want to delete this tent?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _adminController.deleteTent(tent);
                Navigator.pop(context);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
