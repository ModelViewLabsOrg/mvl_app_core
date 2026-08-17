// import 'dart:async';

// import 'package:mvl_app_core/app_logger.dart';
// import 'package:mvl_app_core/app_setup.dart';
// import 'package:mvl_app_core/widgets/app_error_handler.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';

// Future<void> appMain(AppSetupBase setup, void Function() run) async {
//   await runZonedGuarded(
//     () async {
//       // WidgetsFlutterBinding.ensureInitialized();
//       SentryWidgetsFlutterBinding.ensureInitialized();

//       AppErrorHandler.registerErrorHandler();
//       await setup.initialize();

//       run.call();
//     },
//     (error, stackTrace) {
//       appLogger.error('main error', error, stackTrace);
//     },
//   );
// }
