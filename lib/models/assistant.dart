import 'package:der_assistenzplaner/models/tag.dart';
import 'package:hive/hive.dart';

part 'assistant.g.dart';

///hive fields and type ids for persistence
@HiveType(typeId: 0) 
  class Assistant extends HiveObject {
    @HiveField(0) 
    String _name;

    @HiveField(1)
    double _contractedHours;

    @HiveField(2)
    double _actualHours;

    @HiveField(3)
    final List<double> _surchargeCounter;

    @HiveField(4)
    final List<double> _futureSurchargeCounter;

    @HiveField(5)
    final List<Note> _notes;

    @HiveField(6)
    final List<Tag> _tags;

   /// constructor for new assistant, initializes all fields with default values
    Assistant(this._name, this._contractedHours)
      : _actualHours = 0.0,
        _surchargeCounter = [],
        _futureSurchargeCounter = [],
        _notes = [],
        _tags = [];

    String get name => _name;
    double get contractedHours => _contractedHours;
    double get actualHours => _actualHours;
    double get deviation => _contractedHours - _actualHours;
    List<double> get surchargeCounter => List.unmodifiable(_surchargeCounter);
    List<double> get futureSurchargeCounter =>
        List.unmodifiable(_futureSurchargeCounter);
    List<Note> get notes => List.unmodifiable(_notes);
    List<Tag> get tags => List.unmodifiable(_tags);

    set name(String name) => (name.isNotEmpty)
        ? _name = name
        : throw ArgumentError('name darf nicht leer sein.');
    set contractedHours(double contractedHours) =>
        (contractedHours > 0) ? _contractedHours = contractedHours : throw ArgumentError('contractedHours darf nicht negativ sein.');
    set actualHours(double actualHours) =>
        (actualHours > 0) ? _actualHours = actualHours : throw ArgumentError('actualHours darf nicht negativ sein.');

    void addNote(String title, String text) =>

      _notes.add(Note(title, text)); 

    void removeNotebyIndex(int index) => (index < 0 || index >= _notes.length)
      ? throw RangeError('Index $index out of bounds for notes list.')
      : _notes.removeAt(index);

    void assignTag(Tag tag) => (_tags.contains(tag))
      ? throw ArgumentError('Tag $tag bereits zugeordnet.')
      : _tags.add(tag);

    void removeTagByIndex(int index) => (index < 0 || index >= _tags.length)
      ? throw RangeError('Index $index out of bounds for tags list.')
      : _tags.removeAt(index);

    @override
    String toString() => 'Assistant: $_name'; /// TO-DO: implement toString for all fields
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

