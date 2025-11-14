import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/organiser_tile.dart';
import '../constants.dart';
import 'pdf_viewer.dart';

class EventDetails extends StatefulWidget {
  final int eventIndex;
  EventDetails(this.eventIndex);

  @override
  _EventDetailsState createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  String fixtureUrl = '';
  String resultUrl = '';
  String eventDescription = '';
  String eventDate = '';
  bool isUrlLoading = true;
  int pageNumber = 0;

  Future<void> fetchEventData() async {
    final _firestore = FirebaseFirestore.instance;
    String eventName = sportsList[widget.eventIndex].name;

    // Fetch event data from the 'events' collection in Firestore
    var eventDoc = await _firestore.collection('events').doc(eventName).get();

    if (eventDoc.exists) {
      setState(() {
        fixtureUrl = eventDoc.data()?['fixtureUrl'] ?? defaultUrl;
        resultUrl = eventDoc.data()?['resultUrl'] ?? defaultUrl;
        eventDescription = eventDoc.data()?['description'] ?? 'No description available';
        eventDate = eventDoc.data()?['eventDate'] ?? 'No date available';
        isUrlLoading = false;
      });
    } else {
      // Handle the case when the event document doesn't exist
      setState(() {
        isUrlLoading = false;
      });
      print("Event document does not exist.");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchEventData();
  }

  @override
  Widget build(BuildContext context) {
    String eventName = sportsList[widget.eventIndex].name;
    final controller = PageController();
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Flexible(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(eventName, style: TextStyle(fontSize: 30)),
              ),
            ),
            Flexible(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  pageNumber == 0 ? 'Fixtures' : pageNumber == 1 ? 'Results' : 'Organisers',
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ),
            Flexible(
              flex: 8,
              child: PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: controller,
                children: <Widget>[
                  isUrlLoading
                      ? CircularProgressIndicator()
                      : PdfShow(pdfUrl: fixtureUrl),
                  isUrlLoading
                      ? CircularProgressIndicator()
                      : PdfShow(pdfUrl: resultUrl),
                  OrganisersList(eventName),
                ],
              ),
            ),
            Flexible(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 6,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(32),
                              bottomRight: Radius.circular(32)),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(18.0),
                        child: Icon(Icons.arrow_back, color: Colors.black),
                      ),
                      onPressed: () {
                        if (pageNumber == 1 || pageNumber == 2) {
                          controller.animateToPage(--pageNumber,
                              duration: Duration(milliseconds: 1500),
                              curve: Curves.linear);
                        }
                        setState(() {});
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 6,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(32),
                              bottomLeft: Radius.circular(32)),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(18.0),
                        child: Icon(Icons.arrow_forward, color: Colors.black),
                      ),
                      onPressed: () {
                        if (pageNumber == 0 || pageNumber == 1) {
                          controller.animateToPage(++pageNumber,
                              duration: Duration(milliseconds: 1500),
                              curve: Curves.linear);
                        }
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class OrganisersList extends StatefulWidget {
  final String eventName;
  OrganisersList(this.eventName);

  @override
  _OrganisersListState createState() => _OrganisersListState();
}

class _OrganisersListState extends State<OrganisersList> {
  bool loadOrganisersList = true;
  List<OrganiserTile> organisersList = [];

  @override
  void initState() {
    super.initState();
    fetchOrganisersData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loadOrganisersList
          ? Center(child: CircularProgressIndicator())
          : organisersList.isEmpty
          ? Center(child: Text("No organisers found"))
          : ListView.builder(
        itemCount: organisersList.length,
        itemBuilder: (BuildContext context, int index) {
          return organisersList[index];
        },
      ),
    );
  }

  void fetchOrganisersData() async {
    try {
      final _firestore = FirebaseFirestore.instance;

      // Access the event document in the "organisers" collection
      var eventDoc = await _firestore.collection('organisers').doc(widget.eventName).get();

      if (!eventDoc.exists) {
        throw Exception("Event document does not exist");
      }

      // Extract organiser data directly from the document
      Map<String, dynamic>? data = eventDoc.data();

      if (data == null || data.isEmpty) {
        throw Exception("No organiser data available");
      }

      // Extract individual organiser details
      String name = data['organiserName'] ?? 'Name Unknown';
      String phone = data['organiserPhone'] ?? 'Phone Unknown';
      String imageUrl = data['organiserImageUrl'] ?? 'Image Unknown';
      String designation = data['organiserDesignation'] ?? 'Designation Unknown';

      organisersList.add(OrganiserTile(
        name: name,
        imageUrl: imageUrl,
        designation: designation,
        phoneNumber: phone,
      ));

      setState(() {
        loadOrganisersList = false;
      });
    } catch (e) {
      print("Error fetching organisers data: $e");
      setState(() {
        loadOrganisersList = false;
      });
    }
  }
}

class OrganiserTile extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String designation;
  final String phoneNumber;

  OrganiserTile({
    required this.name,
    required this.imageUrl,
    required this.designation,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
        child: imageUrl.isEmpty ? Icon(Icons.person) : null,
      ),
      title: Text(name),
      subtitle: Text(designation),
      trailing: Text(phoneNumber),
    );
  }
}
