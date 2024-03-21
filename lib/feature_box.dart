import 'package:flutter/material.dart';
import 'package:talkit/pallete.dart';

class FeatureBox extends StatelessWidget {
  final Color color;
  final String headerText;
  final String descriptionText;
  const FeatureBox({super.key,required this.color,required this.headerText,required this.descriptionText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20,left: 15,bottom: 20),
      margin: EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 10,

      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(headerText,style: TextStyle(
              fontFamily: 'Cera Pro',
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            ),
          ),
          SizedBox(
            height: 3,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Text(descriptionText,style: TextStyle(
              fontFamily: 'Cera Pro',
              color: Colors.black,

              fontSize: 14,
            ),),
          )
        ],
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
    );
  }
}
