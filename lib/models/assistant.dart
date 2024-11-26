import 'package:der_assistenzplaner/models/tag.dart';


class Assistant {
  String name;
  double contractedHours = 0.0;
  double actualHours = 0.0;
  final List<double> surchargeCounter = [];
  final List <double> futureSurchargeCounter = [];
  final List<Note> notes = [];
  final List<Tag> tags = [];

  Assistant(this.name);

  void editName(String name) {
    //TO-DO: Implement checks for valid name
    this.name = name;
  }

  void setContractedHours(double contractedHours) {
    //TO-DO: Implement checks for valid contractedHours
    if (contractedHours < 0) {
      throw ArgumentError('contractedHours darf nicht negativ sein.');
    }
    this.contractedHours = contractedHours;
  }

  void setActualHours(double actualHours) {
    //TO-DO: Implement checks for valid actualHours
    if (contractedHours < 0) {
      throw ArgumentError('contractedHours darf nicht negativ sein.');
    }
    this.actualHours = actualHours;
  }

  void addNote(String title, String text) {
    //TO-DO: Implement checks for valid values for title and text
    notes.add(Note(title, text));
  }

  void removeNoteByIndex(int index) {
    if (index < 0 || index >= notes.length) {
      throw RangeError('Index $index out of bounds for notes list.');
    }
    notes.removeAt(index);
  }

  void assignTag(Tag tag) {
    ///make check unneccessary by implementing tag assignment UI in a way, that only tags that are not already assigned can be selected 
    if (tags.contains(tag)) {
      throw ArgumentError('Tag $tag bereits zugeordnet.');
    }
    tags.add(tag);
  }

  void removeTagByIndex(int index) {
    if (index < 0 || index >= tags.length) {
      throw RangeError('Index $index out of bounds for tags list.');
    }
    tags.removeAt(index);
  }

  @override
  String toString() {
    //TODO: Implement this method
    return super.toString();
  }
}


///move to other file?
class Note {
  var title = 'Notiz';
  var text = '';
  var date = DateTime.now();

  Note(this.title, this.text);

  //TO-DO: implement checks for valid values for all edit-methods
  void editTitle(String title) {
    this.title = title;
  }

  void editText(String text) {
    this.text = text;
  }

  void editDate(DateTime date) {
    this.date = date;
  }
}

