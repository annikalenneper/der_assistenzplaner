import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class TagWidget extends StatelessWidget {
  final IconData icon;
  final String name;

  TagWidget({required this.icon, required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey, width: 2),
          ),
          child: Center(
            child: FaIcon(
              icon,
              size: 30,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          maxLines: 2, 
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

