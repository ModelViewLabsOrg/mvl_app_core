import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:mvl_app_core/extensions/date_time_ext.dart';

export 'package:date_field/date_field.dart';

class AppBirthdayField extends StatelessWidget {
  const AppBirthdayField({
    required this.onChanged,
    this.label = 'Data de nascimento',
    this.minAge = 0,
    super.key,
  });

  final String label;
  final int minAge;
  final void Function(DateTime) onChanged;

  @override
  Widget build(BuildContext context) {
    return DateTimeFormField(
      decoration: InputDecoration(labelText: label),
      firstDate: DateTime(1900),
      lastDate: Dt.today().previousYear(minAge),
      initialPickerDateTime: Dt.dtNow(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}
