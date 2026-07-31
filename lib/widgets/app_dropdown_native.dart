// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:mvl_app_core/mvl_app_core_view.dart';
// import 'package:mvl_app_core/widgets/app_dropdown.dart';

// class NativeSelectorField<T> extends StatelessWidget {
//   const NativeSelectorField({
//     super.key,
//     required this.items,
//     required this.onChanged,
//     this.initialValue,
//     this.validator,
//     this.hint,
//     this.hintText,
//     this.focusNode,
//   });

//   final List<DropdownMenuEntry<T>> items;
//   final T? initialValue;
//   final ValueChanged<T?> onChanged;
//   final String? Function(T?)? validator;
//   final Widget? hint;
//   final String? hintText;
//   final FocusNode? focusNode;

//   @override
//   Widget build(BuildContext context) {
//     if (DeviceInfo.isApple) {
//       return CupertinoPicker(
//         itemExtent: 32,
//         onSelectedItemChanged: (index) {

//           onChanged.call(items.elementAt(index).value);
//         },
//         children: items.map((e) => Text(e.label)).toList(),
//       );
//     }

//     return AppDropdownFormField<T>(
//       items: items,
//       initialValue: initialValue,
//       onChanged: onChanged,
//       validator: validator,
//       hint: hint,
//       hintText: hintText,
//       focusNode: focusNode,
//     );
//   }
// }

import 'package:mvl_app_core/mvl_app_core_view.dart';
import 'package:mvl_app_core/widgets/app_dropdown_cuppertino.dart';
import 'package:mvl_app_core/widgets/app_dropdown_material.dart';

class AppDropdownFieldParams<T> {
  const AppDropdownFieldParams({
    required this.label,
    required this.hintText,
    required this.initialValue,
    required this.items,
    required this.onChanged,
    required this.validator,
    required this.controller,
    required this.focusNode,
    this.enabled = true,
    this.menuMaxHeight = 300,
  });

  final String label;
  final String hintText;
  final T? initialValue;
  final FormFieldValidator<T> validator;
  final List<DropdownMenuEntry<T>> items;
  final void Function(T) onChanged;

  final bool enabled;
  final double? menuMaxHeight;
  final TextEditingController controller;
  final FocusNode? focusNode;
}

class AppDropdownNative<T> extends StatelessWidget {
  const AppDropdownNative(this.params, {super.key = const ValueKey('Estado')});

  final AppDropdownFieldParams<T> params;

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: params.initialValue,
      validator: params.validator,
      enabled: params.enabled,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (_) =>
          DeviceInfo.isApple ? AppDropdownFieldCupertino(params) : AppDropdownMaterial(params),
    );
  }
}
