import 'package:asmita_flutter/screens/home_screen.dart';
import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter/material.dart';
import 'package:asmita_flutter/screens/RoundedButton.dart';
import 'package:asmita_flutter/screens/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  late String email, name, phoneNumber, rollNumber, password, confirmPassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                height: 200.0,
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
                keyboardType: TextInputType.text,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  name = value;
                },
                decoration: kTextFileDecoration.copyWith(hintText: 'Enter your full name'),
              ),
              SizedBox(height: 8.0),
              TextField(
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  phoneNumber = value;
                },
                decoration: kTextFileDecoration.copyWith(hintText: 'Enter your phone number'),
              ),
              SizedBox(height: 8.0),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration: kTextFileDecoration.copyWith(hintText: 'Enter your email'),
              ),
              SizedBox(height: 8.0),
              TextField(
                keyboardType: TextInputType.text,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  rollNumber = value;
                },
                decoration: kTextFileDecoration.copyWith(hintText: 'Enter your roll number'),
              ),
              SizedBox(height: 8.0),
              TextField(
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFileDecoration.copyWith(hintText: 'Enter password'),
              ),
              SizedBox(height: 8.0),
              TextField(
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  confirmPassword = value;
                },
                decoration: kTextFileDecoration.copyWith(hintText: 'Confirm password'),
              ),
              SizedBox(height: 24.0),
              RoundedButton(
                title: 'Register',
                colour: Colors.blueAccent,
                onPressed: () async {
                  if (password == confirmPassword) {
                    try {
                      final newUser = await _auth.createUserWithEmailAndPassword(
                          email: email, password: password);
                      if (newUser != null) {
                        await addUserToFirestore(name, email, phoneNumber, rollNumber);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      }
                    } catch (e) {
                      print(e);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Passwords do not match')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addUserToFirestore(String name, String email, String phoneNumber, String rollNumber) async {
    try {
      await firestore.collection('users').doc(email).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'rollNumber': rollNumber,
      });
      print('User data added to Firestore');
    } catch (e) {
      print('Error adding user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add user data to Firestore')),
      );
    }
  }
}
