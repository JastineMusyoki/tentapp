// Import necessary packages
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Model for User
class UserModel {
  final String? id;
  final String? username;
  final String? email;
  final String? firstName;
  final String? lastName;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
  });
}
