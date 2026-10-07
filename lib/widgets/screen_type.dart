import 'package:flutter/widgets.dart';
import 'package:mvl_app_core/widgets/app_dimens.dart';

/// Enum representando os 3 tipos de layout baseados nos breakpoints padrão do MVL:
/// - [mobile]: largura < [AppDimens.kBreakpointTablet] (650px)
/// - [tablet]: [AppDimens.kBreakpointTablet] <= largura < [AppDimens.kBreakpointDesktop] (650px - 900px)
/// - [desktop]: largura >= [AppDimens.kBreakpointDesktop] (900px+)
enum ScreenType {
  mobile,
  tablet,
  desktop;

  bool get isMobile => this == ScreenType.mobile;
  bool get isTablet => this == ScreenType.tablet;
  bool get isDesktop => this == ScreenType.desktop;

  /// Retorna true para tablet ou desktop (telas a partir de [AppDimens.kBreakpointTablet]).
  bool get isTabletOrDesktop => isTablet || isDesktop;

  /// Retorna true para mobile ou tablet (telas abaixo de [AppDimens.kBreakpointDesktop]).
  bool get isMobileOrTablet => isMobile || isTablet;

  /// Converte uma largura (width) em [ScreenType] baseado nos breakpoints de [AppDimens].
  static ScreenType fromWidth(double width) {
    if (width >= AppDimens.kBreakpointDesktop) {
      return ScreenType.desktop;
    }
    if (width >= AppDimens.kBreakpointTablet) {
      return ScreenType.tablet;
    }
    return ScreenType.mobile;
  }

  /// Converte um [BoxConstraints] em [ScreenType] baseado na largura máxima (maxWidth).
  static ScreenType fromConstraints(BoxConstraints constraints) =>
      fromWidth(constraints.maxWidth);

  /// Converte um [BuildContext] em [ScreenType] baseado no MediaQuery (size.width).
  static ScreenType fromContext(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  /// Retorna um valor de acordo com o tipo de tela atual.
  /// Se [tablet] ou [desktop] não forem especificados, utiliza fallback em cascata:
  /// - desktop -> tablet ?? mobile
  /// - tablet -> mobile
  T resolve<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    return switch (this) {
      ScreenType.desktop => desktop ?? tablet ?? mobile,
      ScreenType.tablet => tablet ?? mobile,
      ScreenType.mobile => mobile,
    };
  }

  /// Executa uma função específica de acordo com o tipo de tela atual.
  T when<T>({
    required T Function() mobile,
    T Function()? tablet,
    T Function()? desktop,
  }) {
    return switch (this) {
      ScreenType.desktop => (desktop ?? tablet ?? mobile)(),
      ScreenType.tablet => (tablet ?? mobile)(),
      ScreenType.mobile => mobile(),
    };
  }
}

/// Extensão em [BuildContext] para facilitar o acesso às medições de tela.
extension ScreenTypeContextExtension on BuildContext {
  ScreenType get screenType => ScreenType.fromContext(this);

  bool get isMobileScreen => screenType.isMobile;
  bool get isTabletScreen => screenType.isTablet;
  bool get isDesktopScreen => screenType.isDesktop;
  bool get isTabletOrDesktop => screenType.isTabletOrDesktop;

  /// Retorna um valor responsivo baseado no tamanho da tela do contexto.
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) => screenType.resolve(
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
  );
}

/// Extensão em [BoxConstraints] para uso direto em [LayoutBuilder].
extension ScreenTypeConstraintsExtension on BoxConstraints {
  ScreenType get screenType => ScreenType.fromConstraints(this);

  bool get isMobileScreen => screenType.isMobile;
  bool get isTabletScreen => screenType.isTablet;
  bool get isDesktopScreen => screenType.isDesktop;
  bool get isTabletOrDesktop => screenType.isTabletOrDesktop;

  /// Retorna um valor responsivo baseado na largura máxima das constraints.
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) => screenType.resolve(
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
  );
}

/// Extensão em [double] (largura) para conversão direta em [ScreenType].
extension ScreenTypeDoubleExtension on double {
  ScreenType get screenType => ScreenType.fromWidth(this);
}
