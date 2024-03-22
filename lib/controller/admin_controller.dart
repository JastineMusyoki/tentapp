import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mpesa_flutter_plugin/mpesa_flutter_plugin.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../data/oders.dart';
import '../data/products_model.dart';

final userdata = GetStorage();

class AdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final _userEmail = userdata.read('email');
  RxList<Tent> filteredTents = RxList<Tent>([]);

  RxBool isLoading = false.obs;
  RxList<Tent> tents = RxList<Tent>([]);
  RxList<File> selectedImages = RxList<File>([]);
  RxList<RentalOrder> rentalOrders = RxList<RentalOrder>([]);
  RxList<HirePurchaseOrder> hirePurchaseOrders = RxList<HirePurchaseOrder>([]);

  @override
  void onInit() {
    super.onInit();
    fetchTents();
    fetchAllRentalOrders();
    fetchAllHirePurchaseOrders();
  }

  Future<void> addTent({
    required String name,
    required String description,
    required double rentalPrice,
    required double purchasePrice,
    required List<File> images,
  }) async {
    try {
      isLoading(true);

      List<String> imageUrls = [];

      // Upload images to Firebase Storage
      for (File image in images) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference reference = _storage.ref().child('images/$fileName');
        UploadTask uploadTask = reference.putFile(image);
        TaskSnapshot taskSnapshot = await uploadTask;
        String imageUrl = await taskSnapshot.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      // Create a new tent object
      Tent newTent = Tent(
        id: _firestore.collection('tents').doc().id,
        name: name,
        description: description,
        imagePaths: imageUrls,
        rentalPrice: rentalPrice,
        purchasePrice: purchasePrice,
        available: true,
      );

      // Store the tent in Firestore
      await _firestore
          .collection('tents')
          .doc(newTent.id)
          .set(newTent.toJson());

      // Clear selected images after adding the product
      selectedImages.clear();

      fetchTents();

      isLoading(false);
      Get.snackbar('Success', 'Tent added successfully',
          backgroundColor: Colors.green);
    } catch (error) {
      isLoading(false);
      Get.snackbar('Error', 'Failed to add tent: $error');
    }
  }

//rentaal orders by user
  Future<void> fetchAllRentalOrders() async {
    try {
      isLoading(true);
      final querySnapshot = await _firestore.collection('rental_orders').get();
      querySnapshot.docs.forEach((doc) {
        print(
            'Rental Order ID: ${doc.id}, User Email: ${doc['userEmail']}, Tent Name: ${doc['tent']['name']}, Quantity: ${doc['quantity']}, Total Price: ${doc['totalPrice']}, Delivery Info: ${doc['deliveryInfo']}, Created At: ${doc['createdAt']}');
      });
      rentalOrders.assignAll(
        querySnapshot.docs
            .map((doc) => RentalOrder.fromJson(doc.data()))
            .toList(),
      );
      isLoading(false);
    } catch (error) {
      isLoading(false);
      print('Error fetching rental orders: $error');
    }
  }

//mpesa
  // Mpesa Payment
  Future<void> startCheckout(
      {required String userPhone,
      required double amount,
      required dynamic order}) async {
    try {
      isLoading(true);

      dynamic transactionInitialisation =
          await MpesaFlutterPlugin.initializeMpesaSTKPush(
        businessShortCode: '174379', // Replace with your short code
        transactionType: TransactionType.CustomerPayBillOnline,
        amount: 9,
        partyA: userPhone.toString(),
        partyB: '174379', // Replace with your short code
        callBackURL: Uri.parse(
            'https://mydomain.com/path'), // Replace with your callback URL
        accountReference: "order_number",
        phoneNumber: userPhone,
        baseUri: Uri.parse('https://sandbox.safaricom.co.ke'),
        transactionDesc: "purchase",
        passKey:
            "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919", // Replace with your STK password
      );

      print("TRANSACTION RESULT: $transactionInitialisation");
      debugPrint(order.toString());

      if (order is RentalOrder) {
        await FirebaseFirestore.instance
            .collection('rental_orders')
            .doc(order.id)
            .update({'isPaid': true});
      } else if (order is HirePurchaseOrder) {
        await FirebaseFirestore.instance
            .collection('hire_purchase_orders')
            .doc(order.id)
            .update({'isPaid': true});
      }

      // Fetch updated rental and hire purchase orders
      await fetchAllRentalOrders();
      await fetchAllHirePurchaseOrders();
      Get.snackbar('Success', 'Payment processed successfully',
          backgroundColor: Colors.green);

      return transactionInitialisation;
    } catch (e) {
      print("CAUGHT EXCEPTION: $e");
      Get.snackbar('Error', 'Failed to process payment');
    } finally {
      isLoading(false);
    }
  }

  // Future<void> pickImages() async {
  //   try {
  //     List<File> pickedImages = [];
  //     final List<XFile>? images = await _picker.pickMultiImage();
  //     if (images != null) {
  //       for (XFile image in images) {
  //         pickedImages.add(File(image.path));
  //       }
  //       selectedImages.assignAll(pickedImages);
  //     }
  //   } catch (error) {
  //     print('Error picking images: $error');
  //   }
  // }

  Future<List<File>> pickImages() async {
    try {
      List<File> pickedImages = [];
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null) {
        for (XFile image in images) {
          pickedImages.add(File(image.path));
        }
        selectedImages.assignAll(pickedImages);
        return pickedImages;
      }
      return []; // Return an empty list if no images are picked
    } catch (error) {
      print('Error picking images: $error');
      return []; // Handle error gracefully, return an empty list
    }
  }

  // Fetch tent listings
  // Method to fetch tents and filter based on search query
  Future<void> fetchTents({String? searchQuery}) async {
    try {
      isLoading(true);
      final querySnapshot = await _firestore.collection('tents').get();
      final tentsList =
          querySnapshot.docs.map((doc) => Tent.fromJson(doc.data())).toList();

      // If search query is provided, filter tents based on the name
      if (searchQuery != null && searchQuery.isNotEmpty) {
        filteredTents.assignAll(tentsList
            .where((tent) =>
                tent.name.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList());
      } else {
        filteredTents.assignAll(tentsList);
      }
      tents.assignAll(tentsList);

      isLoading(false);
    } catch (error) {
      isLoading(false);
      print('Error fetching tents: $error');
    }
  }

  // Method to perform search and update filtered tents
  void searchTents(String searchText) {
    fetchTents(searchQuery: searchText);
  }

  // Method to edit a tent
  Future<void> editTent(Tent tent) async {
    try {
      isLoading(true);

      // Update the tent in Firestore
      await _firestore.collection('tents').doc(tent.id).update(tent.toJson());

      fetchTents();

      isLoading(false);
      Get.snackbar('Success', 'Tent edited successfully',
          backgroundColor: Colors.green);
    } catch (error) {
      isLoading(false);
      Get.snackbar('Error', 'Failed to edit tent: $error');
    }
  }

  // Method to delete a tent
  Future<void> deleteTent(Tent tent) async {
    try {
      isLoading(true);

      // Delete the tent from Firestore
      await _firestore.collection('tents').doc(tent.id).delete();

      fetchTents();

      isLoading(false);
      Get.snackbar('Success', 'Tent deleted successfully',
          backgroundColor: Colors.green);
    } catch (error) {
      isLoading(false);
      Get.snackbar('Error', 'Failed to delete tent: $error');
    }
  }

// Method to fetch all hire purchase orders
  Future<void> fetchAllHirePurchaseOrders() async {
    try {
      isLoading(true);
      final querySnapshot =
          await _firestore.collection('hire_purchase_orders').get();
      hirePurchaseOrders.assignAll(
        querySnapshot.docs
            .map((doc) => HirePurchaseOrder.fromJson(doc.data()))
            .toList(),
      );
      isLoading(false);
    } catch (error) {
      isLoading(false);
      print('Error fetching hire purchase orders: $error');
    }
  }

  // Method to place a hire purchase order
  Future<void> placeHirePurchaseOrder(
      HirePurchaseOrder hirePurchaseOrder) async {
    try {
      isLoading(true);

      // Store the hire purchase order in Firestore
      await _firestore
          .collection('hire_purchase_orders')
          .doc(hirePurchaseOrder.id)
          .set(hirePurchaseOrder.toJson());

      fetchAllHirePurchaseOrders();

      isLoading(false);
      Get.snackbar('Success', 'Order placed successfully!',
          backgroundColor: Colors.green);
    } catch (error) {
      isLoading(false);
      Get.snackbar('Error', 'Failed to place hire purchase order: $error');
    }
  }

//user place order
  Future<void> placeRentalOrder(RentalOrder rentalOrder) async {
    try {
      isLoading(true);

      // Store the rental order in Firestore
      await _firestore
          .collection('rental_orders')
          .doc(rentalOrder.id)
          .set(rentalOrder.toJson());

      fetchAllRentalOrders();

      isLoading(false);
      Get.snackbar('Success', 'Order placed successfully',
          backgroundColor: Colors.green);
    } catch (error) {
      isLoading(false);
      Get.snackbar('Error', 'Failed to place rental order: $error');
    }
  }

//cancell order
  Future<void> cancelOrder(dynamic order) async {
    try {
      isLoading(true);

      // Determine the collection based on the type of order
      String collection;
      if (order is RentalOrder) {
        collection = 'rental_orders';
      } else if (order is HirePurchaseOrder) {
        collection = 'hire_purchase_orders';
      } else {
        throw Exception('Unknown order type');
      }

      // Delete the order from Firestore
      await _firestore.collection(collection).doc(order.id).delete();

      // Clear reactive lists
      rentalOrders.clear();
      hirePurchaseOrders.clear();

      // Fetch orders again
      await fetchAllRentalOrders();
      await fetchAllHirePurchaseOrders();

      isLoading(false);
      Get.snackbar('Success', 'Order cancelled successfully',
          backgroundColor: Colors.green);
    } catch (error) {
      isLoading(false);
      Get.snackbar('Error', 'Failed to cancel order: $error');
    }
  }

// Method to update the status of an order
  Future<void> updateOrderStatus(
      dynamic order, bool isPaid, bool isDelivered) async {
    try {
      isLoading(true);

      // Determine the collection based on the type of order
      String collection;
      if (order is RentalOrder) {
        collection = 'rental_orders';
      } else if (order is HirePurchaseOrder) {
        collection = 'hire_purchase_orders';
      } else {
        throw Exception('Unknown order type');
      }

      // Update the status in Firestore
      await _firestore.collection(collection).doc(order.id).update({
        'isPaid': isPaid,
        'isDelivered': isDelivered,
      });

      // Fetch all orders again
      if (order is RentalOrder) {
        await fetchAllRentalOrders();
      } else if (order is HirePurchaseOrder) {
        await fetchAllHirePurchaseOrders();
      }

      isLoading(false);
      Get.snackbar('Success', 'Order status updated successfully',
          backgroundColor: Colors.green);
    } catch (error) {
      isLoading(false);
      Get.snackbar('Error', 'Failed to update order status: $error');
    }
  }

  // Method to update the status of a rental order
  Future<void> updateRentalOrderStatus(
      RentalOrder order, bool isPaid, bool isDelivered) async {
    try {
      isLoading(true);

      // Update the status in Firestore
      await _firestore.collection('rental_orders').doc(order.id).update({
        'isPaid': isPaid,
        'isDelivered': isDelivered,
      });

      // Fetch all rental orders again
      await fetchAllRentalOrders();

      isLoading(false);
      Get.snackbar('Success', 'Order placed successfully',
          backgroundColor: Colors.green);
    } catch (error) {
      isLoading(false);
      Get.snackbar('Error', 'Failed to update rental order status: $error');
    }
  }

  // Method to update the status of a hire purchase order
  Future<void> updateHirePurchaseOrderStatus(
      HirePurchaseOrder order, bool isPaid, bool isDelivered) async {
    try {
      isLoading(true);

      // Update the status in Firestore
      await _firestore.collection('hire_purchase_orders').doc(order.id).update({
        'isPaid': isPaid,
        'isDelivered': isDelivered,
      });

      // Fetch all hire purchase orders again
      await fetchAllHirePurchaseOrders();

      isLoading(false);
      Get.snackbar('Success', 'Order status updated successfully',
          backgroundColor: Colors.green);
    } catch (error) {
      isLoading(false);
      Get.snackbar(
          'Error', 'Failed to update hire purchase order status: $error');
    }
  }
}
