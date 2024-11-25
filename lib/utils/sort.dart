

/// inserts elements sorted into a list
void insertSorted<T>(List<T> list, T element, int Function(T a, T b) compare) {

  /// find index where to insert element
  int index = list.indexWhere((e) => compare(element, e) < 0);
  /// if no element found that is greater than the current element, insert at end
  if (index == -1) {
    list.add(element);
  } else {
    list.insert(index, element);
  }
}


