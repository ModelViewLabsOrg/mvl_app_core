import 'package:clock/clock.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mvl_app_core/extensions/date_time_ext_extras.dart';
import 'package:mvl_app_core/extensions/string_extension.dart';

extension DateTimeExt on DateTime {
  /// Out
  String mmm() => DateFormat('MMM').format(this).capitalize();

  /// Outubro
  String mmmm() => DateFormat('MMMM').format(this).capitalize();

  /// Seg
  String eee() => DateFormat('EEE').format(this).capitalize();

  /// Segunda-feira
  String eeee() => DateFormat('EEEE').format(this).capitalize();

  // /// 31
  String dd() => DateFormat('dd').format(this);

  // /// 22
  String yy() => DateFormat('yy').format(this);

  // /// 2022
  String yyyy() => DateFormat('yyyy').format(this);

  // / Outubro / 2022
  // String yMMMM() => '${mmmm()} / $year';
  String yMMMM() => DateFormat.yMMMM().format(this).capitalizeFirstLetter();

  / Outubro 2022
  String monthYear() => '${mmmm()} $year';

  // / 31 / Out
  String toDDMM() => '${dd()} / ${mmm()}';

  /// 31 de Outubro
  String mmmmd() => DateFormat.MMMMd().format(this); //'${dd()} de ${mmmm()}';

  /// Seg, 31 de Outubro de 2025
  String dateWithDayAndYear() => '${eee()}, ${mmmmd()} de $year';

  /// Seg, 31 de Out
  String dateWithDay() => DateFormat.MMMEd().format(this).capitalizeFirstLetter();
  String mmmed() => dateWithDay();

  /// 31 / Outubro / 2022
  // String dateFull() => '${dd()} / ${mmmm()} / ${yyyy()}';
  String dateFull() => DateFormat.yMMMd().format(this).capitalizeFirstLetter();
  String yMMMd() => dateFull();

  /// 31/10/22
  // String dateFullShort() => '${dd()}/$month/${yy()}';
  String dateFullShort() => DateFormat.yMd().format(this).capitalizeFirstLetter();
  String yMd() => dateFullShort();

  /// 31/10/22 13:58
  String dateTimeShort() => '${dateFullShort()} ${onlyTime()}';

  /// 31/Outubro/2022 13:58
  // String dateTimeFull() => '${dateFull()} ${onlyTime()}';

  /// 14:58
  String onlyTime() => DateFormat('HH:mm').format(this);

  /// 14:58:09
  String onlyTimeWithSeconds() => DateFormat('HH:mm:ss').format(this);

  /// 14:58:09.123
  String onlyTimeWithFractSeconds() => DateFormat('HH:mm:ss.S').format(this);
  DateTime onlyDate() => DateTime(year, month, day);
  DateTime onlyMonth() => DateTime(year, month);

  bool isWeekend() => weekday == DateTime.saturday || weekday == DateTime.sunday;

  bool isSameDay(DateTime other) => onlyDate().isAtSameMomentAs(other.onlyDate());

  bool isToday() => isSameDay(clock.now());

  bool isSameMonth(DateTime other) => year == other.year && month == other.month;

  bool isFuture() => clock.now().isBefore(this);
  bool isTomorrowOrAfter() => clock.now().add(const Duration(days: 1)).onlyDate().isBefore(this);

  /// 2022-10-31
  String onlyDateToServerFormat() => DateFormat('yyyy-MM-dd').format(this);

  /// 31/10/2022
  String dateBrFormat() => DateFormat('dd/MM/yyyy').format(this);

  /// 2022-10-31T14:58:09.123 or 2022-10-31T14:58:00
  String toServerFormat({bool removeSeconds = false, bool convertUtc = true}) {
    final DateTime date = removeSeconds ? this.removeSeconds() : this;

    return (convertUtc ? date.toUtc() : date).toIso8601String();
  }

  // String toServerDTWithTz({bool removeSeconds = true}) {
  //   final date = removeSeconds ? this.removeSeconds() : this;
  //   // final dateTz = tz.TZDateTime.from(date, tz.local).toLocal();

  //   return date.toLocal().toIso8601String();
  // }

  /// 2022-10-31 14:58:09.123 -> 2022-10-31 14:58:00
  DateTime removeSeconds() => subtract(
    Duration(
      seconds: second,
      milliseconds: millisecond,
      microseconds: microsecond,
    ),
  );

  /// 2022-10-01 -> 2022-09-01
  DateTime previousMonth() => Jiffy.parseFromDateTime(this).subtract(months: 1).dateTime;

  /// 2022-10-01 -> 2022-11-01
  DateTime nextMonth() => Jiffy.parseFromDateTime(this).add(months: 1).dateTime;

  int daysBetween(DateTime otherDate) {
    return (difference(otherDate).inHours / 24).floor();
  }

  int differenceInYearsFromToday() => today().differenceInYears(this);

  int differenceInYears(DateTime date) {
    final Jiffy subtract = Jiffy.parseFromDateTime(
      this,
    ).subtract(years: date.year, months: date.month, days: date.day);

    return subtract.year;
  }

  bool isDateInPast() {
    final int days = onlyDate().difference(today()).inDays;

    return days.isNegative;
  }

  int age() {
    final DateTime dtToday = today();
    final int age = dtToday.year - year;

    if (month > dtToday.month) {
      return age - 1;
    } else if (month == dtToday.month && day > dtToday.day) {
      return age - 1;
    }

    return age;
  }

  String ago() => Jiffy.parseFromDateTime(this).fromNow();

  bool is18yrs() => age() >= 18;

  String toDate() => DateFormat('yyyy-MM-dd').format(this);

  DateTime forceToUtc() => DateTime.utc(year, month, day, hour, minute, second);
}
