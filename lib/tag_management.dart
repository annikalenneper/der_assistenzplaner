

import 'package:der_assistenzplaner/workschedules.dart';

class Tag {
  String name = '';
  String emoji = '';
  String description = '';

  Tag(this.name, this.emoji, this.description);

  void assignTag(){
    //TO-DO: Implement this method
  }
}

class ShiftTag {
  final Tag tag;
  final Shift shift;

  const ShiftTag(this.tag, this.shift);
}