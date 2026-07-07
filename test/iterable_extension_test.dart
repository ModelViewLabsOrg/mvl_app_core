import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/extensions/iterable_extension.dart';

void main() {
  group('IterableNullExt.compactMap', () {
    test('removes null values', () {
      final List<int> result = [1, null, 2, null, 3].compactMap().toList();
      expect(result, [1, 2, 3]);
    });

    test('returns empty iterable when all values are null', () {
      final List<int> result = <int?>[null, null].compactMap().toList();
      expect(result, isEmpty);
    });

    test('returns all values when none are null', () {
      final List<int> result = [1, 2, 3].compactMap().toList();
      expect(result, [1, 2, 3]);
    });

    test('works with empty iterable', () {
      final List<int> result = <int?>[].compactMap().toList();
      expect(result, isEmpty);
    });
  });

  group('IterableExt.intersperse', () {
    test('inserts separator between elements', () {
      expect([1, 2, 3].intersperse(0).toList(), [1, 0, 2, 0, 3]);
    });

    test('returns single element with no separator for single-element list', () {
      expect([1].intersperse(0).toList(), [1]);
    });

    test('returns empty iterable for empty iterable', () {
      expect(<int>[].intersperse(0).toList(), isEmpty);
    });

    test('works with string separator', () {
      expect(['a', 'b', 'c'].intersperse('-').toList(), ['a', '-', 'b', '-', 'c']);
    });
  });
}
