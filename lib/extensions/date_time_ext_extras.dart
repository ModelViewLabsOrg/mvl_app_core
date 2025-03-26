import 'package:clock/clock.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mvl_app_core/extensions/date_time_ext.dart';

Jiffy get jiffyNow => Jiffy.parseFromDateTime(clock.now());

DateTime today() => clock.now().onlyDate();

String nowServer() => dtNow().toServerFormat();

String freezedDateTime(DateTime value) => value.toServerFormat();
String? freezedDateTimeNullable(DateTime? value) => value?.toServerFormat();

DateTime tomorrow() => clock.now().add(const Duration(days: 1)).onlyDate();

DateTime todayEndDay() => today().add(const Duration(hours: 23, minutes: 59, seconds: 59));

DateTime dtNow() => clock.now();

String currentMonth() => today().mmmm();

DateTime? cvvToDate(String cvv) {
  try {
    if (!cvv.contains('/')) return null;

    final split = cvv.split('/');
    if (split.length != 2) return null;

    final month = int.parse(split[0]);
    if (month < 1 || month > 12) return null;
    final year = 2000 + int.parse(split[1]);
    if (year < 2000) return null;

    return DateTime(year, month);
  } catch (_) {
    return null;
  }
}

DateTime durationAgo({int years = 0, int months = 0, int days = 0, int weeks = 0}) {
  return jiffyNow.subtract(years: years, months: months, days: days, weeks: weeks).dateTime;
}

int get secondsEpochNow => clock.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;

int get dayOfYear => int.parse(DateFormat('D').format(clock.now()));

const Map<int, String> months = {
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

const Map<int, String> weekDays = {
  DateTime.monday: 'Segunda-feira',
  DateTime.tuesday: 'Terça-feira',
  DateTime.wednesday: 'Quarta-feira',
  DateTime.thursday: 'Quinta-feira',
  DateTime.friday: 'Sexta-feira',
  DateTime.saturday: 'Sábado',
  DateTime.sunday: 'Domingo',
};

const Map<int, String> weekDaysBusiness = {
  DateTime.monday: 'Segunda-feira',
  DateTime.tuesday: 'Terça-feira',
  DateTime.wednesday: 'Quarta-feira',
  DateTime.thursday: 'Quinta-feira',
  DateTime.friday: 'Sexta-feira',
};

const Map<int, String> weekDaysAbbr = {
  DateTime.monday: 'seg',
  DateTime.tuesday: 'ter',
  DateTime.wednesday: 'qua',
  DateTime.thursday: 'qui',
  DateTime.friday: 'sex',
  DateTime.saturday: 'sáb',
  DateTime.sunday: 'dom',
};

extension StringDateExt on String {
  DateTime fromLocalDate() => DateTime.parse(this);
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
