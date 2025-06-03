import 'package:flutter/material.dart';

extension TimeOfDayExt on TimeOfDay {
  static TimeOfDay fromJson(String value) {
    final DateTime dateTime = DateTime.parse(value);
    return TimeOfDay.fromDateTime(dateTime);
  }

  String toJson() {
    return DateTime(0, 0, 0, hour, minute).toIso8601String();
  }
}
