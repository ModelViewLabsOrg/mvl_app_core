import 'package:clock/clock.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mvl_app_core/extensions/date_time_ext.dart';

enum WeekDays {
  monday(DateTime.monday, 'Segunda-feira', 'seg'),
  tuesday(DateTime.tuesday, 'Terça-feira', 'ter'),
  wednesday(DateTime.wednesday, 'Quarta-feira', 'qua'),
  thursday(DateTime.thursday, 'Quinta-feira', 'qui'),
  friday(DateTime.friday, 'Sexta-feira', 'sex'),
  saturday(DateTime.saturday, 'Sábado', 'sáb', isBusiness: false),
  sunday(DateTime.sunday, 'Domingo', 'dom', isBusiness: false);

  const WeekDays(this.value, this.name, this.nameAbbr, {this.isBusiness = true});

  final int value;
  final String name;
  final String nameAbbr;
  final bool isBusiness;
}

class Dt {
  const Dt._();

  static Jiffy get jiffyNow => Jiffy.parseFromDateTime(clock.now());

  static DateTime today() => clock.now().onlyDate();

  static String nowServer() => dtNow().toServerFormat();

  static String freezedDateTime(DateTime value) => value.toServerFormat();
  static String? freezedDateTimeNullable(DateTime? value) => value?.toServerFormat();

  static DateTime tomorrow() => clock.now().add(const Duration(days: 1)).onlyDate();

  static DateTime todayEndDay() => today().add(const Duration(hours: 23, minutes: 59, seconds: 59));

  static DateTime dtNow() => clock.now();

  static String currentMonth() => today().mmmm();

  static DateTime? cvvToDate(String cvv) {
    try {
      if (!cvv.contains('/')) {
        return null;
      }

      final List<String> split = cvv.split('/');
      if (split.length != 2) {
        return null;
      }

      final int month = int.parse(split[0]);
      if (month < 1 || month > 12) {
        return null;
      }
      final int year = 2000 + int.parse(split[1]);
      if (year < 2000) {
        return null;
      }

      return DateTime(year, month);
    } catch (_) {
      return null;
    }
  }

  static DateTime durationAgo({int years = 0, int months = 0, int days = 0, int weeks = 0}) {
    return jiffyNow.subtract(years: years, months: months, days: days, weeks: weeks).dateTime;
  }

  static DateTime dayTodayOrTomorrowBefore18h() => clock.now().hour >= 18 ? tomorrow() : today();

  static int get secondsEpochNow =>
      clock.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;

  static int get dayOfYear => int.parse(DateFormat('D').format(clock.now()));

  static const months = <int, String>{
    1: 'Janeiro',
    2: 'Fevereiro',
    3: 'Março',
    4: 'Abril',
    5: 'Maio',
    6: 'Junho',
    7: 'Julho',
    8: 'Agosto',
    9: 'Setembro',
    10: 'Outubro',
    11: 'Novembro',
    12: 'Dezembro',
  };

  static List<WeekDays> get weekDaysBusiness => WeekDays.values.where((w) => w.isBusiness).toList();
}

extension StringDateExt on String {
  DateTime fromLocalDate() => DateTime.parse(this);
  DateTime fromTzToLocalDate() => DateTime.parse(this).toLocal();

  DateTime fromUtcToLocalDate() => DateTime.parse(this).toUtc().toLocal();

  DateTime? toUtcDateNullable() => DateTime.tryParse(this)?.toUtc().toLocal();

  DateTime? parseBrFormat([String char = '-']) {
    try {
      return DateFormat('dd${char}MM${char}yyyy').parse(this).toUtc().toLocal();
    } catch (_) {
      return null;
    }
  }
}

extension DateExtensionNull on DateTime? {
  String? toDate() => this?.toDate();
  bool? is18yrs() => this?.is18yrs();
}
