import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;

class AdminAddSponser extends StatefulWidget {
  @override
  _AdminAddSponserState createState() => _AdminAddSponserState();
}

class _AdminAddSponserState extends State<AdminAddSponser> {
  final _formKey = GlobalKey<FormState>();
  String sponsorName = '';
  String logoUrl = '';
  int priority = 0;

  void uploadSponser() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore.collection('sponsers').add({
          'name': sponsorName,
          'logoUrl': logoUrl.isNotEmpty ? logoUrl : null,
          'priority': priority,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sponsor uploaded successfully!')),
        );

        // Reset form
        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading sponsor: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Sponsor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Sponsor Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter sponsor name';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      sponsorName = value;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Logo URL',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      logoUrl = value;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter priority';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Priority must be a number';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      priority = int.parse(value);
                    },
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: uploadSponser,
                    child: Text('Upload Sponsor'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('sponsers')
                    .orderBy('priority', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final sponsers = snapshot.data!.docs;
                  if (sponsers.isEmpty) {
                    return Center(child: Text('No sponsors uploaded yet.'));
                  }

                  return ListView.builder(
                    itemCount: sponsers.length,
                    itemBuilder: (context, index) {
                      var sponsorData = sponsers[index].data() as Map<String, dynamic>;

                      return Card(
                        child: ListTile(
                          leading: sponsorData['logoUrl'] != null
                              ? Image.network(
                            sponsorData['logoUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                              : Icon(Icons.image_not_supported),
                          title: Text(sponsorData['name'] ?? 'No Name'),
                          subtitle: Text('Priority: ${sponsorData['priority']}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
