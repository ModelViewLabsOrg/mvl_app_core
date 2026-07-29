import 'package:mvl_app_core/mvl_app_core_view.dart';

Widget withConstraint(Widget child) {
  return Container(
    constraints: const BoxConstraints(maxWidth: AppDimens.kMaxWidth),
    padding: const EdgeInsets.fromLTRB(
      AppDimens.kDefaultPadding,
      0,
      AppDimens.kDefaultPadding,
      AppDimens.kPaddingXL,
    ),
    child: child,
  );
}

Widget withConstraintCenter(Widget child) => Center(child: withConstraint(child));

Widget widgetBottomPadding(BuildContext context, [double adicional = 0]) {
  return SizedBox(height: bottomPadding(context, adicional));
}

double bottomPadding(BuildContext context, [double adicional = 0]) {
  return MediaQuery.of(context).viewInsets.bottom + adicional;
}

void dismissKeyboard(BuildContext context) => context.unfocus();
