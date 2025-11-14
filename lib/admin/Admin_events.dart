import 'package:asmita_flutter/admin/Admin_Event_Detail_Screen.dart';
import 'package:asmita_flutter/components/column_template.dart';
import 'package:asmita_flutter/components/sport_tile.dart';
import 'package:asmita_flutter/constants.dart';
import 'package:flutter/material.dart';

class AdminEvents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ColumnTemplate(
        columnTitle: 'Events',
        childWidget: Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemCount: sportsList.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => _onTileClicked(index, context),
                child: SportWidget(
                  name: sportsList[index].name,
                  image: sportsList[index].image,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Function to handle tile click
  void _onTileClicked(int index, BuildContext context) {
    final eventName = sportsList[index].name;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminEventDetailForm(eventName: eventName),
      ),
    );
  }
}
