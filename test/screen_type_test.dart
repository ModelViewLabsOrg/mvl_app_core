import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/widgets/app_dimens.dart';
import 'package:mvl_app_core/widgets/screen_type.dart';

void main() {
  group('ScreenType Enum Tests', () {
    test('ScreenType.fromWidth categoriza corretamente as larguras', () {
      // Mobile (< 650)
      expect(ScreenType.fromWidth(320), ScreenType.mobile);
      expect(ScreenType.fromWidth(649.9), ScreenType.mobile);
      expect(375.0.screenType, ScreenType.mobile);

      // Tablet (650 <= width < 900)
      expect(ScreenType.fromWidth(AppDimens.kBreakpointTablet), ScreenType.tablet);
      expect(ScreenType.fromWidth(768), ScreenType.tablet);
      expect(ScreenType.fromWidth(899.9), ScreenType.tablet);
      expect(800.0.screenType, ScreenType.tablet);

      // Desktop (>= 900)
      expect(ScreenType.fromWidth(AppDimens.kBreakpointDesktop), ScreenType.desktop);
      expect(ScreenType.fromWidth(1200), ScreenType.desktop);
      expect(1920.0.screenType, ScreenType.desktop);
    });

    test('Getters booleanos funcionam conforme o esperado', () {
      expect(ScreenType.mobile.isMobile, isTrue);
      expect(ScreenType.mobile.isTablet, isFalse);
      expect(ScreenType.mobile.isDesktop, isFalse);
      expect(ScreenType.mobile.isTabletOrDesktop, isFalse);
      expect(ScreenType.mobile.isMobileOrTablet, isTrue);

      expect(ScreenType.tablet.isMobile, isFalse);
      expect(ScreenType.tablet.isTablet, isTrue);
      expect(ScreenType.tablet.isDesktop, isFalse);
      expect(ScreenType.tablet.isTabletOrDesktop, isTrue);
      expect(ScreenType.tablet.isMobileOrTablet, isTrue);

      expect(ScreenType.desktop.isMobile, isFalse);
      expect(ScreenType.desktop.isTablet, isFalse);
      expect(ScreenType.desktop.isDesktop, isTrue);
      expect(ScreenType.desktop.isTabletOrDesktop, isTrue);
      expect(ScreenType.desktop.isMobileOrTablet, isFalse);
    });

    test('ScreenType.fromConstraints resolve corretamente', () {
      const mobileConstraints = BoxConstraints(maxWidth: 500);
      const tabletConstraints = BoxConstraints(maxWidth: 700);
      const desktopConstraints = BoxConstraints(maxWidth: 1000);

      expect(ScreenType.fromConstraints(mobileConstraints), ScreenType.mobile);
      expect(ScreenType.fromConstraints(tabletConstraints), ScreenType.tablet);
      expect(ScreenType.fromConstraints(desktopConstraints), ScreenType.desktop);

      expect(mobileConstraints.screenType, ScreenType.mobile);
      expect(tabletConstraints.screenType, ScreenType.tablet);
      expect(desktopConstraints.screenType, ScreenType.desktop);
    });

    test('resolve() suporta fallbacks em cascata', () {
      expect(ScreenType.mobile.resolve(mobile: 1, tablet: 2, desktop: 3), 1);
      expect(ScreenType.tablet.resolve(mobile: 1, tablet: 2, desktop: 3), 2);
      expect(ScreenType.desktop.resolve(mobile: 1, tablet: 2, desktop: 3), 3);

      // Tablet omitido -> cai para mobile
      expect(ScreenType.tablet.resolve(mobile: 1, desktop: 3), 1);

      // Desktop omitido -> cai para tablet, depois mobile
      expect(ScreenType.desktop.resolve(mobile: 1, tablet: 2), 2);
      expect(ScreenType.desktop.resolve(mobile: 1), 1);
    });

    test('when() executa o branch correto', () {
      final String result = ScreenType.tablet.when(
        mobile: () => 'mobile',
        tablet: () => 'tablet',
        desktop: () => 'desktop',
      );
      expect(result, 'tablet');

      final String fallbackResult = ScreenType.desktop.when(
        mobile: () => 'mobile',
      );
      expect(fallbackResult, 'mobile');
    });

    testWidgets('Extensões em BuildContext e BoxConstraints funcionam em widgets', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      late ScreenType buildContextScreenType;
      late int columns;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              buildContextScreenType = context.screenType;
              return LayoutBuilder(
                builder: (context, constraints) {
                  columns = constraints.responsive(mobile: 1, tablet: 2, desktop: 3);
                  return const SizedBox.shrink();
                },
              );
            },
          ),
        ),
      );

      expect(buildContextScreenType, ScreenType.desktop);
      expect(columns, 3);
    });
  });
}
