import 'package:asmita_flutter/screens/events.dart';
import 'package:asmita_flutter/screens/sponsers.dart';
import 'package:asmita_flutter/screens/team.dart';
import 'package:asmita_flutter/screens/updates.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late FirebaseMessaging firebaseMessaging;

  // Subscribe to notifications
  void fcmSubscribe() {
    firebaseMessaging.subscribeToTopic('notifications');
  }

  // Unsubscribe from notifications
  void fcmUnSubscribe() {
    firebaseMessaging.unsubscribeFromTopic('notifications');
  }

  List<Widget> _widgetOptions = <Widget>[
    EventsScreen(),
    UpdatesScreen(),
    SponserScreen(),
    TeamScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState(); // Call super method first
    firebaseMessaging = FirebaseMessaging.instance; // Use the named constructor
    fcmSubscribe(); // Subscribe to topic
  }

  @override
  void dispose() {
    // Unsubscribe when disposing the widget
    fcmUnSubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          iconSize: 30,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_alert),
              label: 'Updates',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wc),
              label: 'Sponsers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Team',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
