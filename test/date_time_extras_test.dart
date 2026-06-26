import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mvl_app_core/extensions/date_time_ext.dart';
import 'package:mvl_app_core/extensions/date_time_ext_extras.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt-br');
    Intl.defaultLocale = 'pt-br';
    await Jiffy.setLocale('pt-br');
  });

  group('DateTimeExt', () {
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
  });

  group('DateTimeExtExtras functions', () {
    group('today', () {
      test('returns current date with no time component', () {
        withClock(Clock.fixed(DateTime(2024, 3, 15, 12, 30)), () {
          expect(today(), DateTime(2024, 3, 15));
        });
      });
    });

    group('tomorrow', () {
      test('returns next day with no time component', () {
        withClock(Clock.fixed(DateTime(2024, 3, 15)), () {
          expect(tomorrow(), DateTime(2024, 3, 16));
        });
      });
    });

    group('todayEndDay', () {
      test('returns today at 23:59:59', () {
        withClock(Clock.fixed(DateTime(2024, 3, 15)), () {
          final DateTime end = todayEndDay();
          expect(end.day, 15);
          expect(end.hour, 23);
          expect(end.minute, 59);
          expect(end.second, 59);
        });
      });
    });

    group('cvvToDate', () {
      test('parses valid MM/YY card expiry', () {
        final DateTime? date = cvvToDate('12/25');
        expect(date, isNotNull);
        expect(date!.month, 12);
        expect(date.year, 2025);
      });

      test('returns null when no slash present', () {
        expect(cvvToDate('1225'), isNull);
      });

      test('returns null for invalid month', () {
        expect(cvvToDate('13/25'), isNull);
        expect(cvvToDate('00/25'), isNull);
      });

      test('returns null for malformed string', () {
        expect(cvvToDate('abc'), isNull);
        expect(cvvToDate('12/25/99'), isNull);
      });
    });
  });

  group('StringDateExt', () {
    group('fromLocalDate', () {
      test('parses ISO 8601 string to DateTime', () {
        expect('2024-03-15'.fromLocalDate(), DateTime(2024, 3, 15));
      });
    });

    group('parseBrFormat', () {
      test('parses Brazilian date format dd/MM/yyyy', () {
        final DateTime? date = '15/03/2024'.parseBrFormat('/');
        expect(date, isNotNull);
        expect(date!.day, 15);
        expect(date.month, 3);
        expect(date.year, 2024);
      });

      test('returns null for invalid date string', () {
        expect('not-a-date'.parseBrFormat('/'), isNull);
      });
    });

    group('toUtcDateNullable', () {
      test('returns UTC DateTime for valid ISO string', () {
        final DateTime? date = '2024-03-15T12:00:00Z'.toUtcDateNullable();
        expect(date, isNotNull);
      });

      test('returns null for invalid string', () {
        expect('not-a-date'.toUtcDateNullable(), isNull);
      });
    });
  });

  group('months constant', () {
    test('contains all 12 months in Portuguese', () {
      expect(months[1], 'Janeiro');
      expect(months[6], 'Junho');
      expect(months[12], 'Dezembro');
      expect(months.length, 12);
    });
  });

  group('weekDays constant', () {
    test('contains all 7 weekdays in Portuguese', () {
      expect(weekDays[DateTime.monday], 'Segunda-feira');
      expect(weekDays[DateTime.sunday], 'Domingo');
      expect(weekDays.length, 7);
    });
  });
}
