import 'package:flutter/material.dart';
import 'package:mvl_app_core/extensions/flutter_ext/context_extension.dart';

class AppText extends Text {
  const AppText._(super.data, {super.style, super.maxLines, super.textAlign, super.overflow, super.key});

  factory AppText._internal(
    String data,
    TextStyle? textStyle, {
    Color? color,
    bool bold = false,
    bool underline = false,
    TextOverflow? overflow,
    TextAlign? textAlign,
    int? maxLines,
    Key? key,
  }) {
    var style = textStyle?.copyWith(color: color) ?? TextStyle(color: color);

    if (bold) style = style.copyWith(fontWeight: FontWeight.w700);

    if (underline) {
      style = style.copyWith(decorationStyle: TextDecorationStyle.solid);
    }

    return AppText._(data, style: style, maxLines: maxLines, textAlign: textAlign, overflow: overflow, key: key);
  }

  factory AppText.headlineLarge(
    BuildContext context,
    String text, {
    Color? color,
    TextAlign textAlign = TextAlign.left,
    int maxLines = 999,
  }) => AppText._(
    text,
    style: context.textTheme.headlineLarge?.copyWith(color: color),
    textAlign: textAlign,
    maxLines: maxLines,
  );

  factory AppText.headlineMedium(
    BuildContext context,
    String text, {
    Color? color,
    bool bold = false,
    bool underline = false,
    TextAlign textAlign = TextAlign.left,
    int maxLines = 999,
  }) {
    return AppText._internal(
      text,
      context.textTheme.headlineMedium,
      bold: bold,
      color: color,
      underline: underline,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
  factory AppText.headlineSmall(
    BuildContext context,
    String text, {
    Color? color,
    TextAlign textAlign = TextAlign.left,
  }) {
    return AppText._(text, style: context.textTheme.headlineSmall?.copyWith(color: color), textAlign: textAlign);
  }

  factory AppText.titleLarge(
    BuildContext context,
    String text, {
    Color? color,
    bool bold = false,
    bool underline = false,
    TextAlign textAlign = TextAlign.left,
    int maxLines = 999,
  }) {
    return AppText._internal(
      text,
      context.textTheme.titleLarge,
      bold: bold,
      color: color,
      underline: underline,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }

  factory AppText.titleMedium(
    BuildContext context,
    String text, {
    Color? color,
    TextAlign textAlign = TextAlign.left,
    int maxLines = 999,
  }) => AppText._(
    text,
    style: context.textTheme.titleMedium?.copyWith(color: color),
    textAlign: textAlign,
    maxLines: maxLines,
  );

  factory AppText.titleSmall(
    BuildContext context,
    String text, {
    Color? color,
    TextAlign textAlign = TextAlign.left,
    int maxLines = 999,
  }) => AppText._(
    text,
    style: context.textTheme.titleSmall?.copyWith(color: color),
    textAlign: textAlign,
    maxLines: maxLines,
  );

  factory AppText.labelLarge(
    BuildContext context,
    String text, {
    Color? color,
    bool bold = false,
    bool underline = false,
    TextAlign textAlign = TextAlign.left,
    int maxLines = 999,
    TextOverflow? overflow,
    Key? key,
  }) {
    return AppText._internal(
      text,
      context.textTheme.labelLarge,
      bold: bold,
      color: color,
      underline: underline,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      key: key,
    );
  }

  factory AppText.labelMedium(
    BuildContext context,
    String text, {
    Color? color,
    bool bold = false,
    bool underline = false,
    TextAlign textAlign = TextAlign.left,
    int maxLines = 999,
    TextOverflow? overflow,
  }) {
    return AppText._internal(
      text,
      context.textTheme.labelMedium,
      bold: bold,
      color: color,
      underline: underline,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppText.labelSmall(
    BuildContext context,
    String text, {
    Color? color,
    TextAlign textAlign = TextAlign.left,
    int maxLines = 999,
    bool bold = false,
    bool underline = false,
  }) {
    return AppText._internal(
      text,
      context.textTheme.labelMedium,
      bold: bold,
      color: color,
      underline: underline,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }

  factory AppText.bodyLarge(
    BuildContext context,
    String text, {
    Color? color,
    TextAlign textAlign = TextAlign.left,
    bool bold = false,
    bool underline = false,
    int? maxLines,
  }) {
    return AppText._internal(
      text,
      context.textTheme.bodyLarge,
      bold: bold,
      color: color,
      underline: underline,
      maxLines: maxLines,
      textAlign: textAlign,
    );
  }

  factory AppText.bodyMedium(
    BuildContext context,
    String text, {
    Color? color,
    bool bold = false,
    bool underline = false,
    int? maxLines,
    TextAlign textAlign = TextAlign.left,
  }) {
    return AppText._internal(
      text,
      context.textTheme.bodyMedium,
      bold: bold,
      color: color,
      underline: underline,
      maxLines: maxLines,
      textAlign: textAlign,
    );
  }

  factory AppText.bodySmall(BuildContext context, String text, {Color? color}) {
    return AppText._internal(text, context.textTheme.bodySmall, color: color);
  }

  /// Alias for Body Small
  factory AppText.caption(BuildContext context, String text, {Color? color}) =>
      AppText.bodySmall(context, text, color: color);
}
