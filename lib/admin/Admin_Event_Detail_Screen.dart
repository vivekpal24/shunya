import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AdminEventDetailForm extends StatefulWidget {
  final String eventName;

  // Constructor to receive the event name
  AdminEventDetailForm({required this.eventName});

  @override
  _AdminEventDetailFormState createState() => _AdminEventDetailFormState();
}

class _AdminEventDetailFormState extends State<AdminEventDetailForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _organiserNameController = TextEditingController();
  final TextEditingController _organiserPhoneController = TextEditingController();
  final TextEditingController _organiserDesignationController = TextEditingController();

  File? _fixtureFile;
  File? _resultFile;
  File? _organiserImageFile;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Set the event name in the controller to pre-fill the form
    _eventNameController.text = widget.eventName;
  }

  // Upload files to Firebase Storage
  Future<String?> uploadFile(File file, String path) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(path);
      await storageRef.putFile(file);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print("Error uploading file: $e");
      return null;
    }
  }

  // Save event and organiser details to Firestore
  void saveEventDetails(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      String eventName = _eventNameController.text.trim();
      String eventDate = _eventDateController.text.trim();
      String description = _descriptionController.text.trim();
      String organiserName = _organiserNameController.text.trim();
      String organiserPhone = _organiserPhoneController.text.trim();
      String organiserDesignation = _organiserDesignationController.text.trim();

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploading details...')),
      );

      try {
        String? fixtureUrl;
        String? resultUrl;
        String? organiserImageUrl;

        // Upload files if selected
        if (_fixtureFile != null) {
          fixtureUrl = await uploadFile(
            _fixtureFile!,
            'event_pdfs/$eventName/fixture_${_fixtureFile!.path.split('/').last}',
          );
        }
        if (_resultFile != null) {
          resultUrl = await uploadFile(
            _resultFile!,
            'event_pdfs/$eventName/result_${_resultFile!.path.split('/').last}',
          );
        }
        if (_organiserImageFile != null) {
          organiserImageUrl = await uploadFile(
            _organiserImageFile!,
            'event_images/$eventName/organiser_${_organiserImageFile!.path.split('/').last}',
          );
        }

        // Save event metadata to Firestore
        await FirebaseFirestore.instance.collection('events').doc(eventName).set({
          'eventName': eventName,
          'eventDate': eventDate,
          'description': description,
          'fixtureUrl': fixtureUrl ?? '',
          'resultUrl': resultUrl ?? '',
          'updatedAt': DateTime.now(),
        });

        // Save organiser data to Firestore
        await FirebaseFirestore.instance.collection('organisers').doc(eventName).set({
          'organiserName': organiserName,
          'organiserPhone': organiserPhone,
          'organiserDesignation': organiserDesignation,
          'organiserImageUrl': organiserImageUrl ?? '',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event and organiser details uploaded successfully!')),
        );

        // Clear the form
        _formKey.currentState!.reset();
        _fixtureFile = null;
        _resultFile = null;
        _organiserImageFile = null;
        setState(() {});
      } catch (e) {
        print("Error saving event details: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading details. Please try again.')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _organiserImageFile = File(pickedFile.path);
      });
    } else {
      print("No image selected.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Event Details')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _eventNameController,
                decoration: InputDecoration(labelText: 'Event Name'),
                validator: (value) => value!.isEmpty ? 'Event name is required' : null,
              ),
              TextFormField(
                controller: _eventDateController,
                decoration: InputDecoration(labelText: 'Event Date (e.g., YYYY-MM-DD)'),
                validator: (value) => value!.isEmpty ? 'Event date is required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Event Description'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Event description is required' : null,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _organiserNameController,
                decoration: InputDecoration(labelText: 'Organiser Name'),
                validator: (value) => value!.isEmpty ? 'Organiser name is required' : null,
              ),
              TextFormField(
                controller: _organiserPhoneController,
                decoration: InputDecoration(labelText: 'Organiser Phone'),
                validator: (value) => value!.isEmpty ? 'Organiser phone is required' : null,
              ),
              TextFormField(
                controller: _organiserDesignationController,
                decoration: InputDecoration(labelText: 'Organiser Designation'),
                validator: (value) => value!.isEmpty ? 'Organiser designation is required' : null,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text(_organiserImageFile == null ? 'Select Organiser Image' : 'Organiser Image Selected'),
              ),
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );
                  if (result != null) {
                    setState(() {
                      _fixtureFile = File(result.files.single.path!);
                    });
                  }
                },
                child: Text(_fixtureFile == null ? 'Select Fixture PDF' : 'Fixture Selected'),
              ),
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );
                  if (result != null) {
                    setState(() {
                      _resultFile = File(result.files.single.path!);
                    });
                  }
                },
                child: Text(_resultFile == null ? 'Select Result PDF' : 'Result Selected'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => saveEventDetails(context),
                child: Text('Upload Event and Organiser Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
