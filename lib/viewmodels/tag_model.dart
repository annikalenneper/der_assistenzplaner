import 'dart:developer';
import 'package:der_assistenzplaner/models/tag.dart';
import 'package:der_assistenzplaner/views/shared/cards_and_markers.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TagModel extends ChangeNotifier {
  Tag? selectedTag;
  late List<Tag> personalTags = [];

  get name => selectedTag?.name;
  get tagSymbol => selectedTag?.tagSymbol;
  
  List<Tag> exampleTags = [
    Tag('Urlaub', FontAwesomeIcons.umbrellaBeach),
    Tag('Krankenhaus', FontAwesomeIcons.hospital),
    Tag('Führerschein', FontAwesomeIcons.car),
    Tag('Langer Abend', FontAwesomeIcons.moon),
    Tag('Arbeit', FontAwesomeIcons.briefcase),
    Tag('Duschen', FontAwesomeIcons.shower),
    Tag('Baden', FontAwesomeIcons.bath),
    Tag('Hund', FontAwesomeIcons.dog),
    Tag('Doppeldienst', FontAwesomeIcons.checkDouble),
    Tag('Schwimmen', FontAwesomeIcons.water),
    Tag('Kino', FontAwesomeIcons.film),
    Tag('Handwerk', FontAwesomeIcons.hammer),
    Tag('Essen gehen', FontAwesomeIcons.utensils),
    Tag('Gartenarbeit', FontAwesomeIcons.leaf),
    Tag('Konzert', FontAwesomeIcons.music),
    Tag('Ausgehen', FontAwesomeIcons.wineGlass),
    Tag('In der Natur', FontAwesomeIcons.tree),
    Tag('Arzttermin', FontAwesomeIcons.stethoscope),
  ];

  set tag(Tag tag) {
      selectedTag = tag;
      log('TagModel: currentTag set to $tag');
  }

  //----------------- User interaction methods -----------------
  

  void addToPersonalTags(index) {
    personalTags.add(Tag(name, tagSymbol));
  }

  void removeFromPersonalTags(Tag tag) {
    personalTags.remove(tag);
  }

  List<Widget> exampleTagsViewList() => exampleTags.map((tag)=>TagWidget(tag)).toList();
  List<Widget> personalTagsViewList() => personalTags.map((tag)=>TagWidget(tag)).toList();

}