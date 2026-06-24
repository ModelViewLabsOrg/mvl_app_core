import 'package:mvl_app_core/mvl_app_core_view.dart';

class CenterMaxWidth extends StatelessWidget {
  const CenterMaxWidth({
    required this.child,
    this.padding = padDefault,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: Alignment.center,
        constraints: const BoxConstraints(maxWidth: AppDimens.kMaxWidth),
        padding: padding,
        child: child,
      ),
    );
  }
}
