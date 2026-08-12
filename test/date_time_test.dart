import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mvl_app_core/extensions/date_time_ext.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt-br');
    Intl.defaultLocale = 'pt-br';
    await Jiffy.setLocale('pt-br');
  });

  final dt = DateTime(2024, 3, 15, 14, 30, 45);

  group('date components', () {
    test('dd returns zero-padded day', () {
      expect(dt.dd(), '15');
      expect(DateTime(2024, 1, 5).dd(), '05');
    });

    test('yy returns 2-digit year', () {
      expect(dt.yy(), '24');
    });

    test('yyyy returns 4-digit year', () {
      expect(dt.yyyy(), '2024');
    });
  });

  group('onlyTime', () {
    test('returns HH:mm format', () {
      expect(dt.onlyTime(), '14:30');
    });
  });

  group('onlyTimeWithSeconds', () {
    test('returns HH:mm:ss format', () {
      expect(dt.onlyTimeWithSeconds(), '14:30:45');
    });
  });

  group('onlyDate', () {
    test('strips time component', () {
      expect(dt.onlyDate(), DateTime(2024, 3, 15));
    });
  });

  group('onlyMonth', () {
    test('strips day and time component', () {
      expect(dt.onlyMonth(), DateTime(2024, 3));
    });
  });

  group('isWeekend', () {
    test('returns true for Saturday', () {
      expect(DateTime(2024, 3, 16).isWeekend(), isTrue);
    });

    test('returns true for Sunday', () {
      expect(DateTime(2024, 3, 17).isWeekend(), isTrue);
    });

    test('returns false for weekdays', () {
      expect(DateTime(2024, 3, 15).isWeekend(), isFalse);
      expect(DateTime(2024, 3, 11).isWeekend(), isFalse);
    });
  });

  group('isSameDay', () {
    test('returns true for same date regardless of time', () {
      expect(dt.isSameDay(DateTime(2024, 3, 15, 23, 59)), isTrue);
    });

    test('returns false for different dates', () {
      expect(dt.isSameDay(DateTime(2024, 3, 16)), isFalse);
    });
  });

  group('isSameMonth', () {
    test('returns true for same year and month', () {
      expect(dt.isSameMonth(DateTime(2024, 3, 28)), isTrue);
    });

    test('returns false for different month', () {
      expect(dt.isSameMonth(DateTime(2024, 4)), isFalse);
    });

    test('returns false for same month but different year', () {
      expect(dt.isSameMonth(DateTime(2023, 3)), isFalse);
    });
  });

  group('isToday', () {
    test('returns true when date matches current clock date', () {
      withClock(Clock.fixed(DateTime(2024, 3, 15, 10)), () {
        expect(dt.isToday(), isTrue);
      });
    });

    test('returns false for a different date', () {
      withClock(Clock.fixed(DateTime(2024, 3, 16)), () {
        expect(dt.isToday(), isFalse);
      });
    });
  });

  group('isFuture', () {
    test('returns true when date is after clock now', () {
      withClock(Clock.fixed(DateTime(2024, 3, 14)), () {
        expect(dt.isFuture(), isTrue);
      });
    });

    test('returns false when date is before clock now', () {
      withClock(Clock.fixed(DateTime(2024, 3, 16)), () {
        expect(dt.isFuture(), isFalse);
      });
    });
  });

  group('isTomorrowOrAfter', () {
    test('returns true for date after tomorrow', () {
      withClock(Clock.fixed(DateTime(2024, 3, 13)), () {
        expect(dt.isTomorrowOrAfter(), isTrue);
      });
    });

    test('returns false for today', () {
      withClock(Clock.fixed(DateTime(2024, 3, 15)), () {
        expect(dt.isTomorrowOrAfter(), isFalse);
      });
    });
  });

  group('isDateInPast', () {
    test('returns true for past date', () {
      withClock(Clock.fixed(DateTime(2024, 3, 16)), () {
        expect(dt.isDateInPast(), isTrue);
      });
    });

    test('returns false for today', () {
      withClock(Clock.fixed(DateTime(2024, 3, 15)), () {
        expect(dt.isDateInPast(), isFalse);
      });
    });
  });

  group('age', () {
    test('calculates correct age', () {
      withClock(Clock.fixed(DateTime(2024, 6, 15)), () {
        expect(DateTime(2000, 6, 15).age(), 24);
        expect(DateTime(2000, 6, 16).age(), 23);
        expect(DateTime(2000, 6, 14).age(), 24);
      });
    });
  });

  group('is18yrs', () {
    test('returns true when age >= 18', () {
      withClock(Clock.fixed(DateTime(2024)), () {
        expect(DateTime(2006).is18yrs(), isTrue);
        expect(DateTime(2005).is18yrs(), isTrue);
      });
    });

    test('returns false when age < 18', () {
      withClock(Clock.fixed(DateTime(2024)), () {
        expect(DateTime(2007).is18yrs(), isFalse);
      });
    });
  });

  group('removeSeconds', () {
    test('zeros out seconds, milliseconds and microseconds', () {
      final DateTime removed = dt.removeSeconds();
      expect(removed.second, 0);
      expect(removed.millisecond, 0);
      expect(removed.microsecond, 0);
      expect(removed.minute, 30);
      expect(removed.hour, 14);
    });
  });

  group('daysBetween', () {
    test('calculates positive difference', () {
      expect(dt.daysBetween(DateTime(2024, 3, 10)), 5);
    });

    test('calculates negative difference', () {
      expect(dt.daysBetween(DateTime(2024, 3, 20)), -5);
    });
  });

  group('onlyDateToServerFormat', () {
    test('returns yyyy-MM-dd format', () {
      expect(dt.onlyDateToServerFormat(), '2024-03-15');
    });
  });

  group('dateBrFormat', () {
    test('returns dd/MM/yyyy format', () {
      expect(dt.dateBrFormat(), '15/03/2024');
    });
  });

  group('forceToUtc', () {
    test('creates UTC datetime with same components', () {
      final DateTime utc = dt.forceToUtc();
      expect(utc.isUtc, isTrue);
      expect(utc.year, 2024);
      expect(utc.month, 3);
      expect(utc.day, 15);
      expect(utc.hour, 14);
      expect(utc.minute, 30);
    });
  });

  group('monthYear', () {
    test('returns month name and year', () {
      final String result = dt.monthYear();
      expect(result, contains('2024'));
    });
  });

  group('toDDMM', () {
    test('returns day and abbreviated month', () {
      final String result = dt.toDDMM();
      expect(result, contains('15'));
    });
  });

  group('dateWithDayAndYear', () {
    test('returns weekday, day, month and year', () {
      final String result = dt.dateWithDayAndYear();
      expect(result, contains('2024'));
    });
  });

  group('yMMMd', () {
    test('returns locale-formatted date', () {
      expect(dt.yMMMd(), isNotEmpty);
    });
  });

  group('yMd', () {
    test('returns locale-formatted short date', () {
      expect(dt.yMd(), isNotEmpty);
    });
  });

  group('dateTimeShort', () {
    test('returns date and time combined', () {
      final String result = dt.dateTimeShort();
      expect(result, contains('14:30'));
    });
  });

  group('onlyTimeWithFractSeconds', () {
    test('returns HH:mm:ss.S format', () {
      expect(dt.onlyTimeWithFractSeconds(), startsWith('14:30:45'));
    });
  });

  group('toServerFormat', () {
    test('returns UTC ISO 8601 string by default', () {
      final String result = DateTime.utc(2024, 3, 15, 14, 30, 45).toServerFormat();
      expect(result, '2024-03-15T14:30:45.000Z');
    });

    test('removeSeconds zeroes out seconds', () {
      final String result = DateTime.utc(
        2024,
        3,
        15,
        14,
        30,
        45,
      ).toServerFormat(removeSeconds: true);
      expect(result, '2024-03-15T14:30:00.000Z');
    });

    test('convertUtc false does not append Z', () {
      final dt2 = DateTime(2024, 3, 15, 14, 30);
      final String result = dt2.toServerFormat(convertUtc: false);
      expect(result, isNot(endsWith('Z')));
    });
  });

  group('previousMonth', () {
    test('returns one month earlier', () {
      final DateTime prev = DateTime(2024, 3, 15).previousMonth();
      expect(prev.month, 2);
      expect(prev.year, 2024);
    });

    test('handles January correctly', () {
      final DateTime prev = DateTime(2024).previousMonth();
      expect(prev.month, 12);
      expect(prev.year, 2023);
    });
  });

  group('nextMonth', () {
    test('returns one month later', () {
      final DateTime next = DateTime(2024, 3, 15).nextMonth();
      expect(next.month, 4);
      expect(next.year, 2024);
    });

    test('handles December correctly', () {
      final DateTime next = DateTime(2024, 12).nextMonth();
      expect(next.month, 1);
      expect(next.year, 2025);
    });
  });

  group('ago', () {
    test('returns a non-empty string', () {
      expect(DateTime(2020).ago(), isNotEmpty);
    });
  });

  group('toDate', () {
    test('formats as yyyy-MM-dd', () {
      expect(DateTime(2024, 3, 15).toDate(), '2024-03-15');
    });
  });

  group('nextBirthday', () {
    final birthDate = DateTime(1995, 8, 20);

    test('returns occurrence in the current year if it has not occurred yet', () {
      withClock(Clock.fixed(DateTime(2026, 5, 10)), () {
        expect(birthDate.nextBirthday(), DateTime(2026, 8, 20));
      });
    });

    test('returns occurrence today at midnight when today is the birthday', () {
      withClock(Clock.fixed(DateTime(2026, 8, 20)), () {
        expect(birthDate.nextBirthday(), DateTime(2026, 8, 20));
      });
    });

    test('returns occurrence today in the afternoon when today is the birthday', () {
      withClock(Clock.fixed(DateTime(2026, 8, 20, 15, 30)), () {
        expect(birthDate.nextBirthday(), DateTime(2026, 8, 20));
      });
    });

    test('returns next year if birthday has already passed', () {
      withClock(Clock.fixed(DateTime(2026, 9)), () {
        expect(birthDate.nextBirthday(), DateTime(2027, 8, 20));
      });
    });

    test('returns next year when birthday is after year wrap from December', () {
      withClock(Clock.fixed(DateTime(2026, 12, 20)), () {
        expect(DateTime(1995, 1, 5).nextBirthday(), DateTime(2027, 1, 5));
      });
    });

    test('returns same year when birthday is still upcoming in December', () {
      withClock(Clock.fixed(DateTime(2026, 12, 20)), () {
        expect(DateTime(1995, 12, 25).nextBirthday(), DateTime(2026, 12, 25));
      });
    });
  });
}
