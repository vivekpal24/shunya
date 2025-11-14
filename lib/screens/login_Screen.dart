import 'package:asmita_flutter/admin/Admin_events.dart';
import 'package:asmita_flutter/admin/admin_home_screen.dart';
import 'package:asmita_flutter/screens/home_screen.dart';
import 'package:asmita_flutter/screens/registration_screen.dart';
import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter/material.dart';
import 'package:asmita_flutter/screens/RoundedButton.dart';
import 'package:asmita_flutter/screens/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late String email;
  late String password;

  Future<bool> checkIfAdmin(String email) async {
    try {
      // Query the Admin collection to see if the email exists
      final snapshot = await _firestore
          .collection('Admin')
          .where('Email', isEqualTo: email)
          .get();
      return snapshot.docs.isNotEmpty; // If docs are found, the user is an admin
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 48.0,
              ),
              Container(
                height: 150.0,
                child: Image.asset('images/asmita_neww.png'),
              ),

              Center(
                child: Text(
                  'Shunya',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 08.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration:
                kTextFileDecoration.copyWith(hintText: 'Enter your email'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                decoration:
                kTextFileDecoration.copyWith(hintText: 'Enter your password'),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                title: 'Log In',
                colour: Colors.lightBlueAccent,
                onPressed: () async {
                  try {
                    final user = await _auth.signInWithEmailAndPassword(
                        email: email, password: password);

                    if (user != null) {
                      // Check if the user is an admin
                      bool isAdmin = await checkIfAdmin(email);
                      if (isAdmin) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AdminHomeScreen()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeScreen()), // Normal user
                        );
                      }
                    }
                  } catch (e) {
                    print('Error during login: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                },
              ),
              Row(
                children: <Widget>[
                  const Text('Does not have an account?'),
                  TextButton(
                    child: const Text(
                      'Sign up',
                      style: TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                RegistrationScreen()), // Normal user
                      );
                    },
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
