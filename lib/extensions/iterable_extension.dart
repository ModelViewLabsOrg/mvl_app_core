extension IterableNullExt<T> on Iterable<T?> {
  Iterable<T> compactMap() {
    final list = List<T>.empty(growable: true);
    for (final item in this) {
      if (item != null) {
        list.add(item);
      }
    }

    return list;
  }
}

extension IterableExt<T> on Iterable<T> {
  Iterable<T> intersperse(T separator) sync* {
    final Iterator<T> iterator = this.iterator;
    if (iterator.moveNext()) {
      yield iterator.current;
      while (iterator.moveNext()) {
        yield separator;
        yield iterator.current;
      }
    }
  }
}
