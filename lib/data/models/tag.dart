import 'package:der_assistenzplaner/data/models/shift.dart';
import 'package:flutter/material.dart';

class Tag {
  String name;
  IconData tagSymbol;

  Tag(this.name, this.tagSymbol);
}

class ShiftTag {
  final Tag tag;
  final Shift shift;

  const ShiftTag(this.tag, this.shift);
}