import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';

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
      lastDate: DateTime.now().add(Duration(days: -365 * minAge)),
      initialPickerDateTime: DateTime.now(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
