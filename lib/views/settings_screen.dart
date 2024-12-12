import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/viewmodels/tag_model.dart';
import 'package:provider/provider.dart';


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
                MaterialPageRoute(builder: (context) => TagScreen()),
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


class TagScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Besondere Anforderungen')),
      body: TagView(false)
    );
  }
}

class TagView extends StatelessWidget {
  final bool selectable;
  TagView(this.selectable);

  @override
  Widget build(BuildContext context) {
    var tags = Provider.of<TagModel>(context).exampleTagsViewList();
    return Padding(
      padding: const EdgeInsets.all(80),
      child: GridView.count(
        crossAxisCount: 6,
        children: tags,        
      ),   
    );
  }
}