import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/viewmodels/tag_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

///SettingsScreen
class SettingsScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: Text('Tags'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TagSettings()),
          );
        },
      )
    );
  }
}

class TagSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var tagModel = Provider.of<TagModel>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Tags')),
      body: Center(
        child: ListView.builder(
          itemCount: tagModel.exampleTags.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: FaIcon(tagModel.exampleTags[index].tagSymbol.icon, size: 40),
              title: Text(tagModel.exampleTags[index].name),
            );
          },
        ),
      ),
    );
  }
}

