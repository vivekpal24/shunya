import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;

class AdminAddUpdate extends StatefulWidget {
  @override
  _AdminAddUpdateState createState() => _AdminAddUpdateState();
}

class _AdminAddUpdateState extends State<AdminAddUpdate> {
  final _formKey = GlobalKey<FormState>();
  String message = '';
  String event = '';

  void uploadUpdate() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore.collection('updates').add({
          'message': message,
          'event': event,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update added successfully!')),
        );

        // Reset form
        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding update: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Update'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Event',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event name';
                  }
                  return null;
                },
                onChanged: (value) {
                  event = value;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
                onChanged: (value) {
                  message = value;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: uploadUpdate,
                child: Text('Submit Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
