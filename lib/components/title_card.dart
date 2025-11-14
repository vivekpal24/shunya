import 'package:asmita_flutter/screens/login_Screen.dart';
import 'package:flutter/material.dart';

class TitleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double _screenHeight = MediaQuery.of(context).size.height;
    return Card(

      elevation: 4,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 8, 0),
                child: Image(
                  height: _screenHeight / 690 * 130,
                  image: AssetImage('images/asmita_neww.png'),
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(42, 0, 20, 8),
                child: Text(
                  'SHUNYA',
                  style: TextStyle(
                    fontSize: _screenHeight / 672 * 18,
                  ),
                ),
              ),
            ],
          ),
          // Logout Button
          Padding(
            padding: EdgeInsets.fromLTRB(5, 70, 20, 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                elevation: 4,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                // Add your logout functionality here
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Logout'),
                    content: Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                          // Add actual logout logic here, e.g., FirebaseAuth.instance.signOut()
                        },
                        child: Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.logout, color: Colors.black),
              label: Text('Logout', style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}
