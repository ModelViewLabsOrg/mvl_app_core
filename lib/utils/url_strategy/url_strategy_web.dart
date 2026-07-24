import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// Sets the URL strategy of your web app to using paths instead of a leading
/// hash (`#`).
void setPathUrlStrategy() {
  setUrlStrategy(PathUrlStrategy());
}

/// Sets the URL strategy of your web app to using a leading hash (`#`) instead
/// of paths.
void setHashUrlStrategy() {
  setUrlStrategy(const HashUrlStrategy());
}
