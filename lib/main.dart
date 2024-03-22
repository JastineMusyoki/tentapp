import 'package:tentapp/firebase_options.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:mpesa_flutter_plugin/initializer.dart';

import 'controller/auth_controller.dart';
import 'views/auth_screens/login.dart';
import 'views/auth_screens/register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Load environment variables from the .env file
  await dotenv.load(fileName: ".env");

  // Set the consumer key and consumer secret from the loaded environment variables
  MpesaFlutterPlugin.setConsumerKey(dotenv.env['consumer_key']!);
  MpesaFlutterPlugin.setConsumerSecret(dotenv.env['consumer_secret']!);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'Tent Rental App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SignInScreen(
          authController: authController,
        ));
  }
}
