import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/admin_controller.dart';

import 'dart:io';

class AddProductPage extends StatelessWidget {
  final AdminController _adminController = Get.find<AdminController>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController rentalPriceController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();
  List<File> _pickedImages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
        centerTitle: true,
        backgroundColor: Colors.amberAccent,
      ),
      body: Obx(() {
        return _adminController.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : _buildForm();
      }),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: FloatingActionButton(
              onPressed: () async {
                List<File> images = await _adminController.pickImages();
                _pickedImages = images;
                // Do something with the picked images
              },
              child: Icon(Icons.cloud_upload),
              backgroundColor: Colors.blue,
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          SizedBox(height: 10),
          // Display the count of picked images
          Center(
            child: Text(
              'Picked Images: ${_pickedImages.length}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the product name';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the product description';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: rentalPriceController,
            decoration: InputDecoration(labelText: 'Rental Price'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the rental price';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: purchasePriceController,
            decoration: InputDecoration(labelText: 'Purchase Price'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the purchase price';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await _addProduct();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text('Add Product', style: TextStyle(fontSize: 18)),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.amberAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              minimumSize: Size(double.infinity, 0),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addProduct() async {
    List<File> images = _pickedImages;
    //_adminController.selectedImages.toList();
    if (images.isEmpty) {
      Get.snackbar('Error', 'Please pick at least one image');
      return;
    }

    if (_validateFields()) {
      try {
        await _adminController.addTent(
          name: nameController.text,
          description: descriptionController.text,
          rentalPrice: double.parse(rentalPriceController.text),
          purchasePrice: double.parse(purchasePriceController.text),
          images: images,
        );

        Get.snackbar('Success', 'Product added successfully');

        // Clear the form fields after adding the product
        nameController.clear();
        descriptionController.clear();
        rentalPriceController.clear();
        purchasePriceController.clear();
        _pickedImages.clear();
      } catch (error) {
        Get.snackbar('Error', 'Failed to add product: $error');
      }
    }
  }

  bool _validateFields() {
    if (nameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        rentalPriceController.text.isEmpty ||
        purchasePriceController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all the fields');
      return false;
    }
    return true;
  }
}




// class AddProductPage extends StatelessWidget {
//   final AdminController _adminController = Get.find<AdminController>();

//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   final TextEditingController rentalPriceController = TextEditingController();
//   final TextEditingController purchasePriceController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Product'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Obx(() {
//           if (_adminController.isLoading.value) {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           } else {
//             return SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   TextFormField(
//                     controller: nameController,
//                     decoration: InputDecoration(labelText: 'Name'),
//                   ),
//                   SizedBox(height: 20),
//                   TextFormField(
//                     controller: descriptionController,
//                     decoration: InputDecoration(labelText: 'Description'),
//                     maxLines: null,
//                   ),
//                   SizedBox(height: 20),
//                   TextFormField(
//                     controller: rentalPriceController,
//                     decoration: InputDecoration(labelText: 'Rental Price'),
//                     keyboardType: TextInputType.number,
//                   ),
//                   SizedBox(height: 20),
//                   TextFormField(
//                     controller: purchasePriceController,
//                     decoration: InputDecoration(labelText: 'Purchase Price'),
//                     keyboardType: TextInputType.number,
//                   ),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () async {
//                       await _addProduct();
//                     },
//                     child: Text('Add Product'),
//                   ),
//                 ],
//               ),
//             );
//           }
//         }),
//       ),
//     );
//   }

//   Future<void> _addProduct() async {
//     final String name = nameController.text.trim();
//     final String description = descriptionController.text.trim();
//     final double rentalPrice = double.parse(rentalPriceController.text.trim());
//     final double purchasePrice = double.parse(purchasePriceController.text.trim());

//     if (name.isEmpty || description.isEmpty) {
//       Get.snackbar('Error', 'Name and description cannot be empty');
//       return;
//     }

//     try {
//       await _adminController.addTent(
//         name: name,
//         description: description,
//         rentalPrice: rentalPrice,
//         purchasePrice: purchasePrice,
//         // Pass images if needed
//       );

//       // Clear text fields after successful addition
//       nameController.clear();
//       descriptionController.clear();
//       rentalPriceController.clear();
//       purchasePriceController.clear();
//     } catch (error) {
//       print('Error adding product: $error');
//     }
//   }
// }
