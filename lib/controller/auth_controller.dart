// controllers/auth_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../data/users_model.dart';
import '../views/admin_screens/admin_dash.dart';
import '../views/auth_screens/login.dart';
import '../views/user_screens/user_dash.dart';

// controllers/auth_controller.dart

class AuthController extends GetxController {
  Rx<UserModel?> user = Rx<UserModel?>(null);
  RxList<UserModel> userList = RxList<UserModel>([]);
  FirebaseAuth auth = FirebaseAuth.instance;
  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> register(
    String email,
    String password,
    String? username,
    String? firstName,
    String? lastName,
  ) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Assigning ID 2 for regular users
      UserModel newUser = UserModel(
        id: '2',
        username: username!,
        email: email,
        firstName: firstName!,
        lastName: lastName!,
      );

// Save user data to Firebase or your preferred database firestore
      await storeUserInFirestore(newUser);

      // For simplicity, we're just printing the user details here
      Get.snackbar('Success!', 'Registration was successful',
          duration: const Duration(seconds: 5));

      debugPrint(
          "New user registered: ${newUser.id}, ${newUser.username}, ${newUser.email}");

      user.value = newUser;
    } catch (e) {
      Get.snackbar('Error!', e.toString(),
          duration: const Duration(seconds: 5));
      debugPrint("Error during registration: $e");
      // Handle registration error
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);

      // Fetch user data from Firestore
      await fetchUserData();

      // Find the user by email in the userList
      UserModel? loggedInUser = userList.firstWhereOrNull(
        (user) => user.email == email,
      );

      if (loggedInUser != null) {
        storage.write('userId', loggedInUser.id);
        storage.write('username', loggedInUser.username);
        storage.write('email', loggedInUser.email);
        storage.write('firstName', loggedInUser.firstName);
        storage.write('lastName', loggedInUser.lastName);
        // Check if the logged-in user is an admin
        if (loggedInUser.id == '1') {
          // Admin
          Get.off(() => AdminDashboard(authController: this));
        } else {
          // Customer/User
          Get.off(() => UserDashboard(
              //authController: this
              ));
        }
      } else {
        // Handle case where user data is not found
        Get.snackbar('Error!', 'User not found',
            duration: const Duration(seconds: 5));
      }
    } catch (e) {
      Get.snackbar('Error!', e.toString(),
          duration: const Duration(seconds: 5));
      debugPrint("Error during login: $e");
      // Handle login error
    }
  }

  Future<bool> isUserAdmin(String userEmail) async {
    try {
      // Reference to the users collection in Firestore
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      // Check if user email is in Firestore data
      QuerySnapshot<Object?> result =
          await users.where('email', isEqualTo: userEmail).get();

      return result.docs.isNotEmpty && result.docs.first['id'] == '1';
    } catch (e) {
      Get.snackbar('Error!', 'Failed to check user role',
          duration: const Duration(seconds: 5));
      debugPrint("Error checking user role in Firestore: $e");
      return false;
    }
  }

  void logout() async {
    await auth.signOut();
    Get.offAll(() => SignInScreen(authController: this));
  }

  //reset password
  Future<void> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      Get.snackbar('Success!', 'Password reset email sent',
          duration: const Duration(seconds: 5));
    } catch (e) {
      Get.snackbar(
          'Error!', 'Failed to send password reset email: ${e.toString()}',
          duration: const Duration(seconds: 5));
      debugPrint("Error sending password reset email: $e");
    }
  }

// feth users from firebase
  Future<void> fetchUserData() async {
    try {
      // Reference to the users collection in Firestore
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      // Fetch all user data from Firestore
      QuerySnapshot<Object?> userDocs = await users.get();

      // Map each document to UserModel and store in a list
      userList.assignAll(userDocs.docs.map((doc) {
        return UserModel(
          id: doc['id'],
          username: doc['username'],
          email: doc['email'],
          firstName: doc['firstName'],
          lastName: doc['lastName'],
        );
      }).toList());

      // You can also print or use the data as needed
      debugPrint("Fetched all user data: ${userList.toString()}");
    } catch (e) {
      Get.snackbar('Error!', 'Failed to fetch user data',
          duration: const Duration(seconds: 5));
      debugPrint("Error fetching user data from Firestore: $e");
    }
  }

  // function to store new users to firestore
  Future<void> storeUserInFirestore(UserModel user) async {
    try {
      // Reference to the users collection in Firestore
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      // Add the user to the 'users' collection with an automatically generated document ID
      await users.add({
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'firstName': user.firstName,
        'lastName': user.lastName,
      });

      Get.snackbar('Success!', 'User data stored in Firestore',
          duration: const Duration(seconds: 5));
    } catch (e) {
      Get.snackbar(
          'Error!', 'Failed to store user data in Firestore! ${e.toString()}',
          duration: const Duration(seconds: 5));
      debugPrint("Error storing user data in Firestore: $e");
    }
  }

//end
}
