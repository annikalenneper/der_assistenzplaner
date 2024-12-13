import 'dart:developer';
import 'package:der_assistenzplaner/models/tag.dart';
import 'package:der_assistenzplaner/views/shared/small_custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';



class TagModel extends ChangeNotifier {
  Tag? selectedTag;
  late Box<Tag> _tagBox;
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
  

  void selectTag(Tag tag) {
    selectedTag = tag;
  } 

  void addTag(index) {
    personalTags.add(Tag(name, tagSymbol));
  }

  void removeTag(Tag tag) {
    personalTags.remove(tag);
  }

  List<Widget> exampleTagsViewList() => exampleTags.map((tag)=>TagWidget(tag)).toList();
  List<Widget> personalTagsViewList() => personalTags.map((tag)=>TagWidget(tag)).toList();


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