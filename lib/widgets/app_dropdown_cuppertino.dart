import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mvl_app_core/widgets/app_dropdown_native.dart';
import 'package:mvl_app_core/widgets/app_text.dart';
import 'package:mvl_app_core/widgets/app_text_field.dart';

class AppDropdownFieldCupertino<T> extends StatelessWidget {
  const AppDropdownFieldCupertino(this.params, {super.key});

  final AppDropdownFieldParams<T> params;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: params.enabled ? () => _showPicker(context) : null,
      child: AppTextField(
        params.label,
        params.controller,
        validator: (value) => params.validator(value as T), //params.validator,
        // enabled: params.enabled,
        hintText: params.hintText,
        // readOnly: false,
        enabled: false,
      ),
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    int? initialIndex = params.items.indexWhere((e) => e.value == params.initialValue);
    if (initialIndex == -1) {
      initialIndex = null;
    }

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        height: params.menuMaxHeight,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancelar'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text('OK'),
                    onPressed: () {
                      HapticFeedback.lightImpact().ignore();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  magnification: 1.35,
                  scrollController: initialIndex == null
                      ? null
                      : FixedExtentScrollController(initialItem: initialIndex),
                  onSelectedItemChanged: (index) {
                    HapticFeedback.selectionClick().ignore();

                    params.controller.text = params.items.elementAt(index).label;

                    params.onChanged(params.items.elementAt(index).value);
                  },
                  children: params.items
                      .map(
                        (e) => Center(
                          child: AppText.bodyMedium(context, e.label),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
