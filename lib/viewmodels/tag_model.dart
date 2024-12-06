import 'dart:developer';

import 'package:der_assistenzplaner/models/tag.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';



class TagModel extends ChangeNotifier {
  Tag? selectedTag;
  late Box<Tag> _tagBox;
  late List<Tag> personalTags = [];

  TagModel();
  
  /// list of all tagSymbols
  /// selection of tag examples
  
  final List<IconData> availableIcons = [
    FontAwesomeIcons.car,
    FontAwesomeIcons.shower,
    FontAwesomeIcons.bed,
    FontAwesomeIcons.bath,
    FontAwesomeIcons.baby,
    FontAwesomeIcons.book,
    FontAwesomeIcons.dog,
    FontAwesomeIcons.cat,
    FontAwesomeIcons.suitcase,
    FontAwesomeIcons.briefcase,
    FontAwesomeIcons.moon,
    FontAwesomeIcons.campground,
    FontAwesomeIcons.basketShopping,
    FontAwesomeIcons.train,
    FontAwesomeIcons.umbrellaBeach,
    FontAwesomeIcons.gamepad,
    FontAwesomeIcons.leaf,
    FontAwesomeIcons.bicycle,
    FontAwesomeIcons.bus,
    FontAwesomeIcons.guitar,
  ];

  final List<Tag> exampleTags = [
    Tag('Urlaub', Icon(FontAwesomeIcons.umbrella)),
    Tag('Krankenhaus', Icon(FontAwesomeIcons.hospital)),
    Tag('Führerschein', Icon(FontAwesomeIcons.car)),
    Tag('Langer Abend', Icon(FontAwesomeIcons.moon)),
    Tag('Arbeit', Icon(FontAwesomeIcons.briefcase)),
    Tag('Duschen', Icon(FontAwesomeIcons.shower)),
    Tag('Baden', Icon(FontAwesomeIcons.bath)),
    Tag('Hund', Icon(FontAwesomeIcons.dog)),
    Tag('Doppeldienst', Icon(FontAwesomeIcons.checkDouble)),
    Tag('Schwimmen', Icon(FontAwesomeIcons.water)),
    Tag('Kino', Icon(FontAwesomeIcons.film)),
    Tag('Handwerk', Icon(FontAwesomeIcons.hammer)),
    Tag('Essen gehen', Icon(FontAwesomeIcons.utensils)),
    Tag('Gartenarbeit', Icon(FontAwesomeIcons.leaf)),
    Tag('Konzert', Icon(FontAwesomeIcons.music)),
    Tag('Ausgehen', Icon(FontAwesomeIcons.wineGlass)),
    Tag('Draußen in der Natur', Icon(FontAwesomeIcons.tree)),
    Tag('Arzttermin', Icon(FontAwesomeIcons.stethoscope)),

  ];


  //----------------- User interaction methods -----------------
  

  void selectTag(Tag tag) {
    selectedTag = tag;
  } 

  void addTag(String name, Icon tagSymbol) {
    personalTags.add(Tag(name, tagSymbol));
  }

  void removeTag(Tag tag) {
    personalTags.remove(tag);
  }


  //----------------- Database methods -----------------

  Future<void> initialize() async {
    _tagBox = await Hive.openBox<Tag>('tagBox');
  
    personalTags = getAllTags();
  
  /// listen to changes in database and update tag list accordingly
    _tagBox.watch().listen((event) {
      personalTags = getAllTags();
      notifyListeners(); 
      log('TagModel: tag list updated');
    });
  }

  Future<void> saveCurrentAssistant() async {
    if (selectedTag == null) {
      log('AssistantModel: currentAssistant is null');
      return;
    } 
    if (personalTags.contains(selectedTag)) {
      log('AssistantModel: currentAssistant already exists in database');
      return;
    } 
    await _tagBox.add(selectedTag!);
    notifyListeners(); 
  }

  List<Tag> getAllTags() {
    return _tagBox.values.toList();
  }

  Future<void> deleteTag(int index) async {
    await _tagBox.deleteAt(index);
    notifyListeners(); 
  }


  
}