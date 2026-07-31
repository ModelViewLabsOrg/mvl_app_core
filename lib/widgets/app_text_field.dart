import 'package:flutter/services.dart';
import 'package:mvl_app_core/mvl_app_core_view.dart';

class AppTextField extends StatelessWidget {
  const AppTextField(
    this.label,
    this.controller, {
    this.focusNode,
    this.onChanged,
    this.onTapOutside,
    this.onFieldSubmitted,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.toggleVisibility,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.autoValidateMode = AutovalidateMode.onUserInteraction,
    this.inputFormatters,
    this.hintText,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
    this.prefixText,
    this.prefixIcon,
    this.suffixIcon,
    this.autofocus = false,
    this.style,
    this.autofillHints,
    this.uppercase = false,
    // this.keyboardActions = const [],
    // this.showFocusButtons = false,
    // this.doneButtonLabel,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final void Function()? toggleVisibility;
  final void Function()? onTapOutside;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final AutovalidateMode autoValidateMode;
  final List<TextInputFormatter>? inputFormatters;
  final String? hintText;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final String? prefixText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool autofocus;
  final TextStyle? style;
  final Iterable<String>? autofillHints;
  final bool uppercase;
  // final List<AppTextFieldAction> keyboardActions;
  // final bool showFocusButtons;
  // final String? doneButtonLabel;

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      decoration: _fieldDecoration(context),
      enabled: enabled,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      focusNode: focusNode,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      autovalidateMode: autoValidateMode,
      obscureText: obscureText,
      inputFormatters: _effectiveInputFormatters,
      textCapitalization: uppercase ? TextCapitalization.characters : TextCapitalization.none,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      autofocus: autofocus,
      style: style,
      autofillHints: autofillHints,
      readOnly: readOnly,
      onTapOutside: onTapOutside == null ? null : (e) => onTapOutside?.call(),
    );
    return field;

    // return KeyboardActions(
    //   config: KeyboardActionsConfig(
    //     nextFocus: showFocusButtons,
    //     defaultDoneWidget: _doneButton(context),
    //   ),
    //   tapOutsideBehavior: TapOutsideBehavior.opaqueDismiss,
    //   child: field,
    // );
  }

  // Widget? _doneButton(BuildContext context) {
  //   final doneButtonLabel = this.doneButtonLabel;
  //   if (doneButtonLabel == null) return null;
  //   return TextButton(
  //     child: Text(doneButtonLabel),
  //     onPressed: () => context.pop(),
  //   );
  // }

  List<TextInputFormatter>? get _effectiveInputFormatters {
    if (uppercase) {
      return [
        TextInputFormatter.withFunction(
          (_, newValue) => newValue.copyWith(text: newValue.text.toUpperCase()),
        ),
        ...?inputFormatters,
      ];
    }

    return inputFormatters;
  }

  InputDecoration _fieldDecoration(BuildContext context) {
    Widget? suffixIcon = this.suffixIcon;
    suffixIcon ??= toggleVisibility == null
        ? null
        : GestureDetector(
            onTap: toggleVisibility,
            child: obscureText ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off),
          );

    final bool isMultiline = (maxLines ?? 1) > 1 || (minLines ?? 1) > 1;

    return inputDecoration(context).copyWith(
      alignLabelWithHint: isMultiline,
      labelText: label,
      hintText: hintText,
      prefixText: prefixText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }

  static InputDecoration inputDecoration(BuildContext context) {
    return InputDecoration(
      enabledBorder: enabledBorder(context),
      focusedBorder: defaultBorder(context),
      errorBorder: defaultBorder(context, Theme.of(context).colorScheme.error),
      errorMaxLines: 2,
      focusedErrorBorder: defaultBorder(context, Theme.of(context).colorScheme.error),
      disabledBorder: defaultBorder(context, const Color.fromRGBO(235, 235, 235, 1)),
      filled: false,
      fillColor: const Color.fromRGBO(235, 235, 235, 1),
      isDense: false,
      labelStyle: Theme.of(context).textTheme.labelLarge,
    );
  }

  static OutlineInputBorder enabledBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color.fromRGBO(26, 26, 26, .12), width: 1.5),
    );
  }

  static InputBorder defaultBorder(BuildContext context, [Color? color]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color ?? Theme.of(context).primaryColor, width: 2),
    );
  }
}
