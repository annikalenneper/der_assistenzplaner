import 'package:der_assistenzplaner/models/tag.dart';


class Assistant {
  String _name;
  double _contractedHours = 0.0;
  double _actualHours = 0.0;
  final List<double> _surchargeCounter = [];
  final List <double> _futureSurchargeCounter = [];
  final List<Note> _notes = [];
  final List<Tag> _tags = [];

  Assistant(this._name);

  String get name => _name;
  double get contractedHours => _contractedHours;
  double get actualHours => _actualHours;
  List<double> get surchargeCounter => List.unmodifiable(_surchargeCounter);
  List<double> get futureSurchargeCounter => List.unmodifiable(_futureSurchargeCounter);
  List<Note> get notes => List.unmodifiable(_notes);

  //TO-DO: Implement checks for valid name
  set name(String name) => (name.isNotEmpty) ? _name = name : throw ArgumentError('name darf nicht leer sein.');
  set contractedHours(double contractedHours) => (contractedHours > 0) ? _contractedHours = contractedHours : throw ArgumentError('contractedHours darf nicht negativ sein.');
  set actualHours(double actualHours) => (actualHours > 0) ? _actualHours = actualHours : throw ArgumentError('actualHours darf nicht negativ sein.');

<<<<<<< HEAD
  void addNote(String title, String text) => _notes.add(Note(title, text)); //TO-DO: Implement checks for valid values for title and text
  void removeNotebyIndex(int index) => (index < 0 || index >= _notes.length) ? throw RangeError('Index $index out of bounds for notes list.') : _notes.removeAt(index);
  
  ///make check unneccessary by implementing tag assignment UI in a way, that only tags that are not already assigned can be selected 
  void assignTag(Tag tag) => (_tags.contains(tag)) ? throw ArgumentError('Tag $tag bereits zugeordnet.') : _tags.add(tag); 
  void removeTagByIndex(int index) => (index < 0 || index >= _tags.length) ? throw RangeError('Index $index out of bounds for tags list.') : _tags.removeAt(index);
=======
  void addNote(String title, String text) {
    //TO-DO: Implement checks for valid values for title and text
    _notes.add(Note(title, text));
  }

  void removeNoteByIndex(int index) {
    if (index < 0 || index >= _notes.length) {
      throw RangeError('Index $index out of bounds for notes list.');
    }
    _notes.removeAt(index);
  }

  void assignTag(Tag tag) {
    ///make check unneccessary by implementing tag assignment UI in a way, that only tags that are not already assigned can be selected 
    if (_tags.contains(tag)) {
      throw ArgumentError('Tag $tag bereits zugeordnet.');
    }
    _tags.add(tag);
  }

  void removeTagByIndex(int index) {
    if (index < 0 || index >= _tags.length) {
      throw RangeError('Index $index out of bounds for tags list.');
    }
    _tags.removeAt(index);
  }
>>>>>>> 23a9450f28410f6ed07ee2f7365db9ad90d24c34

  @override
  String toString() => 'Assistant: $_name'; //TO-DO: adjust to show all relevant information;
  
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

