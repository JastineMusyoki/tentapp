import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mpesa_flutter_plugin/mpesa_flutter_plugin.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tentapp/data/deliveries_model.dart';
import 'package:tentapp/views/admin_screens/deliveries_list.dart';

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
  RxList<RentingOrder> rentalOrders = RxList<RentingOrder>([]);
  RxList<PurchaseOrder> purchaseOrders = RxList<PurchaseOrder>([]);
  RxList<Delivery> deliveries = RxList<Delivery>([]);

  @override
  void onInit() {
    super.onInit();
    fetchTents();
    fetchAllRentalOrders();
    fetchAllPurchaseOrders();
    fetchDeliveries();
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

  //search orders
  void searchOrders(String searchText) {
    searchText = searchText.toLowerCase();
    final List<RentingOrder> filteredRentalOrders = rentalOrders
        .where((order) =>
            order.userEmail.toLowerCase().contains(searchText) ||
            order.id.toLowerCase().contains(searchText))
        .toList();
    final List<PurchaseOrder> filteredPurchaseOrders = purchaseOrders
        .where((order) =>
            order.userEmail.toLowerCase().contains(searchText) ||
            order.id.toLowerCase().contains(searchText))
        .toList();

    rentalOrders.assignAll(filteredRentalOrders);
    purchaseOrders.assignAll(filteredPurchaseOrders);
  }

//rentaal orders by user
  Future<void> fetchAllRentalOrders() async {
    try {
      isLoading(true);
      final querySnapshot = await _firestore.collection('renting_orders').get();
      querySnapshot.docs.forEach((doc) {
        print(
            'Rental Order ID: ${doc.id}, User Email: ${doc['userEmail']}, Tent Name: ${doc['tent']['name']}, Quantity: ${doc['quantity']}, Total Price: ${doc['totalPrice']}, Delivery Info: ${doc['deliveryInfo']}}');
      });
      rentalOrders.assignAll(
        querySnapshot.docs
            .map((doc) => RentingOrder.fromJson(doc.data()))
            .toList(),
      );
      isLoading(false);
    } catch (error) {
      isLoading(false);
      print('Error fetching rental orders: $error');
      throw Exception(error);
    }
  }

// Method to create a new delivery
  Future<void> createDelivery(String deliveryId, Delivery delivery) async {
    try {
      isLoading(true);

      // Store the delivery in Firestore with the generated ID
      await _firestore
          .collection('deliveries')
          .doc(deliveryId)
          .set(delivery.toJson());

      isLoading(false);
      await fetchDeliveries();
      Get.snackbar('Success', 'Delivery created successfully',
          backgroundColor: Colors.green);
      Get.off(() => AdminDeliveriesScreen());
    } catch (error) {
      isLoading(false);
      Get.snackbar('Error', 'Failed to create delivery: $error');
    }
  }

  // Method to update the delivery status
  Future<void> updateDeliveryStatus(String deliveryId, bool isDelivered) async {
    try {
      isLoading(true);

      // Update the status in Firestore
      await _firestore.collection('deliveries').doc(deliveryId).update({
        'isDelivered': isDelivered,
      });

      // Fetch all deliveries again
      await fetchDeliveries();

      isLoading(false);
      Get.snackbar('Success', 'Delivery status updated successfully',
          backgroundColor: Colors.green);
    } catch (error) {
      isLoading(false);
      Get.snackbar('Error', 'Failed to update delivery status: $error');
    }
  }

  // Method to fetch all deliveries
  Future<void> fetchDeliveries() async {
    try {
      isLoading(true);
      final querySnapshot = await _firestore.collection('deliveries').get();
      deliveries.assignAll(
        querySnapshot.docs.map((doc) => Delivery.fromJson(doc.data())).toList(),
      );
      isLoading(false);
    } catch (error) {
      isLoading(false);
      print('Error fetching deliveries: $error');
    }
  }

// Method to delete a delivery
  Future<void> deleteDelivery(String deliveryId) async {
    try {
      isLoading(true);

      // Delete the delivery from Firestore
      await _firestore.collection('deliveries').doc(deliveryId).delete();

      // Fetch deliveries again
      await fetchDeliveries();

      isLoading(false);
      Get.snackbar('Success', 'Delivery deleted successfully',
          backgroundColor: Colors.green);
    } catch (error) {
      isLoading(false);
      Get.snackbar('Error', 'Failed to delete delivery: $error');
    }
  }

//send stmp reminder
  Future<void> sendReminder(RentingOrder order, String _message) async {
    isLoading(true); // Set isLoading to true before sending email
    final _email = 'j.n.houdini@gmail.com';

    final smtpServer =
        gmail(_email, 'dpue xniz tlbs zhax'); // Your Gmail credentials

    // Create an email message
    final server_message = Message()
      ..from = Address(_email)
      ..recipients.add(order.userEmail) // Recipient's email
      ..subject =
          'Reminder for Rental Order ${order.id}. Order due for ${order.returnDate}.'
      ..text = _message; // Your reminder message

    try {
      final sendReport = await send(server_message, smtpServer);
      print('Reminder email sent: ${sendReport.toString()}');
    } catch (e) {
      print('Error sending reminder email: $e');
      throw Exception(e);
      // Handle the error accordingly
    } finally {
      isLoading(false); // Set isLoading back to false after operation completes
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
        accountReference: "Tent ative Reference",
        phoneNumber: userPhone,
        baseUri: Uri.parse('https://sandbox.safaricom.co.ke'),
        transactionDesc: "purchase",
        passKey:
            "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919", // Replace with your STK password
      );

      print("TRANSACTION RESULT: $transactionInitialisation");
      debugPrint(order.toString());

      if (order is RentingOrder) {
        await FirebaseFirestore.instance
            .collection('renting_orders')
            .doc(order.id)
            .update({'isPaid': true});
      } else if (order is PurchaseOrder) {
        await FirebaseFirestore.instance
            .collection('purchase_orders') //
            .doc(order.id)
            .update({'isPaid': true});
      }

      // Fetch updated rental and hire purchase orders
      await fetchAllRentalOrders();
      await fetchAllPurchaseOrders();
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
      final tentsList = querySnapshot.docs
          .map((doc) => Tent.fromJson(doc.data()))
          .where((tent) => tentContainsQuery(tent, searchQuery ?? ''))
          .toList();

      filteredTents.assignAll(tentsList);
      tents.assignAll(tentsList);

      isLoading(false);
    } catch (error) {
      isLoading(false);
      print('Error fetching tents: $error');
    }
  }

  bool tentContainsQuery(Tent tent, String query) {
    final lowerCaseQuery = query.toLowerCase();
    return tent.name.toLowerCase().contains(lowerCaseQuery) ||
        tent.description.toLowerCase().contains(lowerCaseQuery) ||
        tent.imagePaths
            .any((path) => path.toLowerCase().contains(lowerCaseQuery));
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
  Future<void> fetchAllPurchaseOrders() async {
    try {
      isLoading(true);
      final querySnapshot =
          await _firestore.collection('purchase_orders').get();
      purchaseOrders.assignAll(
        querySnapshot.docs
            .map((doc) => PurchaseOrder.fromJson(doc.data()))
            .toList(),
      );
      isLoading(false);
    } catch (error) {
      isLoading(false);
      debugPrint('Error fetching purchase orders: $error');
      throw Exception(error);
    }
  }

  // Method to place a hire purchase order
  Future<void> placePurchaseOrder(PurchaseOrder purchaseOrder) async {
    try {
      isLoading(true);

      // Store the hire purchase order in Firestore
      await _firestore
          .collection('purchase_orders')
          .doc(purchaseOrder.id)
          .set(purchaseOrder.toJson());

      fetchAllPurchaseOrders();

      isLoading(false);
      Get.snackbar('Success', 'Order placed successfully!',
          backgroundColor: Colors.green);
    } catch (error) {
      isLoading(false);
      Get.snackbar('Error', 'Failed to place hire purchase order: $error');
    }
  }

//user place order
  Future<void> placeRentalOrder(RentingOrder rentalOrder) async {
    try {
      isLoading(true);

      // Store the rental order in Firestore
      await _firestore
          .collection('renting_orders')
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
      if (order is RentingOrder) {
        collection = 'renting_orders';
      } else if (order is PurchaseOrder) {
        collection = 'purchase_orders';
      } else {
        throw Exception('Order no longer exists!');
      }

      // Delete the order from Firestore
      await _firestore.collection(collection).doc(order.id).delete();

      // Clear reactive lists
      rentalOrders.clear();
      purchaseOrders.clear();

      // Fetch orders again
      await fetchAllRentalOrders();
      await fetchAllPurchaseOrders();

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
      if (order is RentingOrder) {
        collection = 'renting_orders';
      } else if (order is PurchaseOrder) {
        collection = 'purchase_orders';
      } else {
        throw Exception('Unknown order type');
      }

      // Update the status in Firestore
      await _firestore.collection(collection).doc(order.id).update({
        'isPaid': isPaid,
        'isDelivered': isDelivered,
      });

      // Fetch all orders again
      if (order is RentingOrder) {
        await fetchAllRentalOrders();
      } else if (order is PurchaseOrder) {
        await fetchAllPurchaseOrders();
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
      RentingOrder order, bool isPaid, bool isDelivered) async {
    try {
      isLoading(true);

      // Update the status in Firestore
      await _firestore.collection('renting_orders').doc(order.id).update({
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
      Get.snackbar('Error', 'Something went wrong: $error');
    }
  }

  // Method to update the status of a hire purchase order
  Future<void> updatePurchaseOrderStatus(
      PurchaseOrder order, bool isPaid, bool isDelivered) async {
    try {
      isLoading(true);

      // Update the status in Firestore
      await _firestore.collection('purchase_orders').doc(order.id).update({
        'isPaid': isPaid,
        'isDelivered': isDelivered,
      });

      // Fetch all hire purchase orders again
      await fetchAllPurchaseOrders();

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
