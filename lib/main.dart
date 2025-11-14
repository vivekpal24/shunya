import 'package:asmita_flutter/screens/home_screen.dart';
import 'package:asmita_flutter/screens/login_Screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter initializes before Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Check if Firebase has been initialized already
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shunya\'20',
      theme: ThemeData(
        primaryColor: Colors.white,
        fontFamily: 'NunitoSans',
      ),
      home: LoginScreen(),
    );
  }
}
