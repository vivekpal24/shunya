import 'package:asmita_flutter/components/column_template.dart';
import 'package:flutter/material.dart';
import '../components/update_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
final _firestore = FirebaseFirestore.instance;


class UpdatesScreen extends StatefulWidget {

  @override
  _UpdatesScreenState createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen> {
  List<UpdateCard> updatesList = [];

  @override
  void initState() {
    // TODO: implement initState
    fetchUpdates();
  }

  void fetchUpdates() async{



    await for (var snapshot in _firestore
        .collection('updates')
        .orderBy('createdAt', descending: true)
        .snapshots()) {
      List<UpdateCard> newUpdatesList = [];

      for (var message in snapshot.docs) {
        String msg, event, displayDate;

        // Access fields using message.data() in the newer API
        var data = message.data() as Map<String, dynamic>;

        msg = data['message'] ?? 'Message Text Unavailable';
        event = data['event'] ?? 'Event Unavailable';

        int timestamp = data['createdAt'] ?? 1580187210337;
        var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        displayDate = DateFormat("dd MMM yyyy hh:mm a").format(date).toString();

        newUpdatesList.add(UpdateCard(event: event, date: displayDate, message: msg));
      }

      setState(() {
        updatesList = newUpdatesList;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ColumnTemplate(
        columnTitle: 'Updates',
        childWidget: Expanded(
          child: Container(
            child: ListView.builder(
            itemCount: updatesList.length,
            itemBuilder: (BuildContext context,int index){
      return updatesList[index];
    },
      ),
          ),
        ),
    ));
  }
}
