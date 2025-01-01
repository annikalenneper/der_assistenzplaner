import 'package:der_assistenzplaner/data/models/tag.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'assistant.g.dart';

///hive fields for persistence (needs unique type id)
@HiveType(typeId: 0) 
  class Assistant extends HiveObject {
    @HiveField(0)
    String _assistantID;

    @HiveField(1) 
    String _name;

    @HiveField(2)
    double _contractedHours;

    @HiveField(3)
    double _actualHours;

    @HiveField(4)
    final List<double> _surchargeCounter;

    @HiveField(5)
    final List<double> _futureSurchargeCounter;

    @HiveField(6)
    final List<Note> _notes;

    @HiveField(7)
    List<Tag> _tags;


   /// constructor for new assistant, initializes all fields with default values
    Assistant(this._name, this._contractedHours)
      : _assistantID = Uuid().v4().toString(),
        _actualHours = 0.0,
        _surchargeCounter = [],
        _futureSurchargeCounter = [],
        _notes = [],
        _tags = [];

    String get assistantID => _assistantID;
    String get name => _name;
    double get contractedHours => _contractedHours;
    double get actualHours => _actualHours;
    double get deviation => _contractedHours - _actualHours;
    String get formattedDeviation => (deviation >= 0 ? '-' : '+') + deviation.toStringAsFixed(2);
    List<double> get surchargeCounter => List.unmodifiable(_surchargeCounter);
    List<double> get futureSurchargeCounter =>
        List.unmodifiable(_futureSurchargeCounter);
    List<Note> get notes => _notes;
    List<Tag> get tags => List.unmodifiable(_tags);

    set name(String name) => (name.isNotEmpty)
        ? _name = name
        : throw ArgumentError('name darf nicht leer sein.');
    set contractedHours(double contractedHours) =>
        (contractedHours > 0) ? _contractedHours = contractedHours : throw ArgumentError('contractedHours darf nicht negativ sein.');
    set actualHours(double actualHours) =>
        (actualHours > 0) ? _actualHours = actualHours : throw ArgumentError('actualHours darf nicht negativ sein.');
    set tags(List<Tag> tags) => _tags = tags;

    @override
    String toString() {
      return 'Assistant: $name, $contractedHours, $deviation, $tags';
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

