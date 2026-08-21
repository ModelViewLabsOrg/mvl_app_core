import 'package:mvl_app_core/mvl_app_core_view.dart';
import 'package:mvl_app_core/widgets/app_text.dart';

const double _kKeyValueMaxExtent = 140;
const double _kKeyValueMainExtent = 56;

class KeyValueCard extends StatelessWidget {
  const KeyValueCard({
    required this.label,
    required this.value,
    this.backgroundColor,
    this.valueColor,
    super.key,
  });

  final String label;
  final String value;
  final Color? backgroundColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? context.theme.colorScheme.secondary,
        borderRadius: AppDimens.defaultBorder(radius: AppDimens.kPaddingM),
      ),
      child: Padding(
        padding: padM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppDimens.kPaddingXS,
          children: [
            AppText.labelSmall(
              context,
              label,
              color: context.theme.colorScheme.onPrimary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AppText.labelLarge(
              context,
              value,
              color: valueColor ?? context.theme.colorScheme.onPrimary,
              bold: true,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class KeyValueGroup extends StatelessWidget {
  const KeyValueGroup({
    required this.children,
    this.maxCrossAxisExtent = _kKeyValueMaxExtent,
    super.key,
  });

  final List<Widget> children;
  final double maxCrossAxisExtent;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return emptyBox;
    }

    return GridView(
      shrinkWrap: true,
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        mainAxisExtent: _kKeyValueMainExtent,
        mainAxisSpacing: AppDimens.kPaddingS,
        crossAxisSpacing: AppDimens.kPaddingS,
      ),
      children: children,
    );
  }
}
