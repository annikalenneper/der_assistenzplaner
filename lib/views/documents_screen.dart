import 'package:flutter/material.dart';


class DocumentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dokumente')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Monatliche Dienstpläne'),
            Text('Schichtpläne pro Assistenzkraft'),
            Text('Arbeitszeitaufschlüsselung pro Assistenzkraft'),
          ],
        ),
      ),
    );   
  }
}