import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvl_app_core/widgets/app_dropdown_native.dart';
import 'package:mvl_app_core/widgets/app_text.dart';

class AppDropdownMaterial<T> extends StatelessWidget {
  const AppDropdownMaterial(
    this.params, {
    this.enabled = true,
    this.menuMaxHeight = 300,
    super.key,
  });

  final AppDropdownFieldParams<T> params;
  final bool enabled;
  final double? menuMaxHeight;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      enabled: enabled,
      dropdownMenuEntries: params.items,
      expandedInsets: EdgeInsets.zero,
      // enableFilter: enableSearch,
      // requestFocusOnTap: enableSearch,
      menuHeight: menuMaxHeight,
      initialSelection: params.initialValue,
      label: AppText.bodyMedium(context, params.hintText),
      hintText: params.hintText,
      // errorText: params.validator(params.initialValue),
      onSelected: (value) {
        HapticFeedback.selectionClick().ignore();
        params.onChanged(value as T);
      },
    );
  }
}
