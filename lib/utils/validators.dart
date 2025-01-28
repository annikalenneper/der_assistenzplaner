

//------------------------- Validators -------------------------

String? validateTime(String? value) {
  final RegExp timeRegExp = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
  if (value == null || value.isEmpty) {
    return 'Bitte gib eine Uhrzeit ein';
  }
  if (!timeRegExp.hasMatch(value)) {
    return 'Bitte gib eine gültige Uhrzeit im Format HH:MM ein';
  }
  return null;
}

String? validateDate(String? value) {
  final RegExp dateRegExp = RegExp(r'^\d{2}\.\d{2}\.\d{4}$');
  if (value == null || value.isEmpty) {
    return 'Bitte gib ein Datum ein';
  }
  if (!dateRegExp.hasMatch(value)) {
    return 'Bitte gib ein gültiges Datum im Format TT.MM.JJJJ ein';
  }
  return null;
}

String? startBeforeEnd(DateTime start, DateTime end) {
  if (start.isAfter(end)) {
    return 'Startzeit muss vor Endzeit liegen';
  }
  return null;
}
