import 'package:der_assistenzplaner/models/shift.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'tag.g.dart'; 

@HiveType(typeId: 4) 
class Tag {
  @HiveField(0)
  String name;

  @HiveField(1)
  IconData tagSymbol;

  Tag(this.name, this.tagSymbol);
}


class ShiftTag {
  final Tag tag;
  final Shift shift;

  const ShiftTag(this.tag, this.shift);
}