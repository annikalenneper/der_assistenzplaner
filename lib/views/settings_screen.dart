import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/viewmodels/tag_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:der_assistenzplaner/views/shared/tag_widget.dart';

///SettingsScreen
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
        children: [
          ElevatedButton(
            child: Text('Schichten'),
            onPressed: () {
              
            },
          ),
          ElevatedButton(
            child: Text('Besondere Anforderungen'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TagView()),
              );
            },
          ), 
          ElevatedButton(
            child: Text('Dienstpläne'),
            onPressed: () {
              
            },
          ),
          ElevatedButton(
            child: Text('Weitere Einstellungen'),
            onPressed: () {
              
            },
          ),
        ],
    );
  }
}


class TagView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var tagModel = Provider.of<TagModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Besondere Anforderungen')),
      body: Padding(
        padding: const EdgeInsets.all(80),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            
          ),
          itemCount: tagModel.exampleTags.length,
          itemBuilder: (context, index) {
            final tag = tagModel.exampleTags[index];
            return TagWidget(
              icon: tag.tagSymbol,
              name: tag.name,
            );
          },
        ),
      ),
    );
  }
}

