import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mvl_app_core/extensions/date_time_ext_extras.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt-br');
    Intl.defaultLocale = 'pt-br';
    await Jiffy.setLocale('pt-br');
  });

  group('jiffyNow', () {
    test('returns Jiffy from current clock time', () {
      withClock(Clock.fixed(DateTime(2024, 3, 15)), () {
        final Jiffy j = Dt.jiffyNow;
        expect(j.year, 2024);
        expect(j.month, 3);
      });
    });
  });

  group('nowServer', () {
    test('returns ISO string of current time', () {
      withClock(Clock.fixed(DateTime.utc(2024, 3, 15)), () {
        final String result = Dt.nowServer();
        expect(result, contains('2024-03-15'));
      });
    });
  });

  group('freezedDateTime', () {
    test('returns ISO string for given DateTime', () {
      final String result = Dt.freezedDateTime(DateTime.utc(2024, 3, 15));
      expect(result, contains('2024-03-15'));
    });
  });

  group('freezedDateTimeNullable', () {
    test('returns ISO string for non-null DateTime', () {
      final String? result = Dt.freezedDateTimeNullable(DateTime.utc(2024, 3, 15));
      expect(result, isNotNull);
      expect(result, contains('2024-03-15'));
    });

    test('returns null for null DateTime', () {
      expect(Dt.freezedDateTimeNullable(null), isNull);
    });
  });

  group('dtNow', () {
    test('returns current clock time', () {
      withClock(Clock.fixed(DateTime(2024, 3, 15, 12)), () {
        expect(Dt.dtNow().year, 2024);
        expect(Dt.dtNow().hour, 12);
      });
    });
  });

  group('currentMonth', () {
    test('returns the name of the current month', () {
      withClock(Clock.fixed(DateTime(2024, 3, 15)), () {
        expect(Dt.currentMonth(), isNotEmpty);
      });
    });
  });

  group('durationAgo', () {
    test('subtracts given duration from now', () {
      withClock(Clock.fixed(DateTime(2024, 3, 15)), () {
        final DateTime result = Dt.durationAgo(days: 5);
        expect(result.isBefore(DateTime(2024, 3, 15)), isTrue);
      });
    });

    test('subtracts years', () {
      withClock(Clock.fixed(DateTime(2024, 3, 15)), () {
        final DateTime result = Dt.durationAgo(years: 1);
        expect(result.year, 2023);
      });
    });
  });

  group('secondsEpochNow', () {
    test('returns seconds since epoch', () {
      withClock(Clock.fixed(DateTime.utc(2024, 3, 15)), () {
        expect(Dt.secondsEpochNow, isA<int>());
        expect(Dt.secondsEpochNow, greaterThan(0));
      });
    });
  });

  group('dayOfYear', () {
    test('returns day number within year', () {
      withClock(Clock.fixed(DateTime(2024)), () {
        expect(Dt.dayOfYear, 1);
      });
    });

    test('returns correct day for end of year', () {
      withClock(Clock.fixed(DateTime(2024, 12, 31)), () {
        expect(Dt.dayOfYear, greaterThan(360));
      });
    });
  });

  group('today', () {
    test('returns current date with no time component', () {
      withClock(Clock.fixed(DateTime(2024, 3, 15, 12, 30)), () {
        expect(Dt.today(), DateTime(2024, 3, 15));
      });
    });
  });

  group('tomorrow', () {
    test('returns next day with no time component', () {
      withClock(Clock.fixed(DateTime(2024, 3, 15)), () {
        expect(Dt.tomorrow(), DateTime(2024, 3, 16));
      });
    });
  });

  group('todayEndDay', () {
    test('returns today at 23:59:59', () {
      withClock(Clock.fixed(DateTime(2024, 3, 15)), () {
        final DateTime end = Dt.todayEndDay();
        expect(end.day, 15);
        expect(end.hour, 23);
        expect(end.minute, 59);
        expect(end.second, 59);
      });
    });
  });

  group('cvvToDate', () {
    test('parses valid MM/YY card expiry', () {
      final DateTime? date = Dt.cvvToDate('12/25');
      expect(date, isNotNull);
      expect(date!.month, 12);
      expect(date.year, 2025);
    });

    test('returns null when no slash present', () {
      expect(Dt.cvvToDate('1225'), isNull);
    });

    test('returns null for invalid month', () {
      expect(Dt.cvvToDate('13/25'), isNull);
      expect(Dt.cvvToDate('00/25'), isNull);
    });

    test('returns null for malformed string', () {
      expect(Dt.cvvToDate('abc'), isNull);
      expect(Dt.cvvToDate('12/25/99'), isNull);
    });
  });

  group('months', () {
    test('contains all 12 months in Portuguese', () {
      expect(Dt.months[1], 'Janeiro');
      expect(Dt.months[6], 'Junho');
      expect(Dt.months[12], 'Dezembro');
      expect(Dt.months.length, 12);
    });
  });

  group('weekDays', () {
    test('contains all 7 weekdays in Portuguese', () {
      expect(WeekDays.monday.name, 'Segunda-feira');
      expect(WeekDays.monday.nameAbbr, 'seg');
      expect(WeekDays.monday.isBusiness, isTrue);
      expect(WeekDays.tuesday.name, 'Terça-feira');
      expect(WeekDays.tuesday.nameAbbr, 'ter');
      expect(WeekDays.tuesday.isBusiness, isTrue);
      expect(WeekDays.wednesday.name, 'Quarta-feira');
      expect(WeekDays.wednesday.nameAbbr, 'qua');
      expect(WeekDays.wednesday.isBusiness, isTrue);
      expect(WeekDays.thursday.name, 'Quinta-feira');
      expect(WeekDays.thursday.nameAbbr, 'qui');
      expect(WeekDays.thursday.isBusiness, isTrue);
      expect(WeekDays.friday.name, 'Sexta-feira');
      expect(WeekDays.friday.nameAbbr, 'sex');
      expect(WeekDays.friday.isBusiness, isTrue);
      expect(WeekDays.saturday.name, 'Sábado');
      expect(WeekDays.saturday.nameAbbr, 'sáb');
      expect(WeekDays.saturday.isBusiness, isFalse);
      expect(WeekDays.sunday.name, 'Domingo');
      expect(WeekDays.sunday.nameAbbr, 'dom');
      expect(WeekDays.sunday.isBusiness, isFalse);

      expect(WeekDays.values.length, 7);
    });
  });

  group('weekDaysBusiness', () {
    test('contains weekdays Monday through Friday', () {
      final List<WeekDays> businessDays = WeekDays.values.where((w) => w.isBusiness).toList();
      expect(businessDays.length, 5);
      expect(businessDays.contains(WeekDays.saturday), isFalse);
      expect(businessDays.contains(WeekDays.monday), isTrue);
      expect(businessDays.contains(WeekDays.tuesday), isTrue);
      expect(businessDays.contains(WeekDays.wednesday), isTrue);
      expect(businessDays.contains(WeekDays.thursday), isTrue);
      expect(businessDays.contains(WeekDays.friday), isTrue);
      expect(businessDays.contains(WeekDays.saturday), isFalse);
      expect(businessDays.contains(WeekDays.sunday), isFalse);
    });
  });

  group('StringDateExt', () {
    group('fromLocalDate', () {
      test('parses ISO 8601 string to DateTime', () {
        expect('2024-03-15'.fromLocalDate(), DateTime(2024, 3, 15));
      });
    });

    group('fromUtcToLocalDate', () {
      test('parses UTC ISO string to local DateTime', () {
        final DateTime result = '2024-03-15T00:00:00.000Z'.fromUtcToLocalDate();
        expect(result.year, 2024);
        expect(result.month, 3);
        expect(result.day, 15);
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

  group('DateExtensionNull', () {
    test('toDate returns formatted string for non-null DateTime', () {
      final DateTime? dt;
      dt = DateTime(2024, 3, 15);
      expect(dt.toDate(), '2024-03-15');
    });

    test('toDate returns null for null DateTime', () {
      const DateTime? dt = null;
      expect(dt.toDate(), isNull);
    });

    test('is18yrs returns true for adult non-null DateTime', () {
      withClock(Clock.fixed(DateTime(2024)), () {
        DateTime? dt;
        dt = DateTime(2000);
        expect(dt.is18yrs(), isTrue);
      });
    });

    test('is18yrs returns null for null DateTime', () {
      const DateTime? dt = null;
      expect(dt.is18yrs(), isNull);
    });
  });
}
