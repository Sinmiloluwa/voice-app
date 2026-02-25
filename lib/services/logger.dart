import 'package:sentry_flutter/sentry_flutter.dart';

class AppLogger {
  static void debug(String message, {dynamic data}) {
    Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      level: SentryLevel.debug,
      data: data != null ? {'value': data.toString()} : null,
    ));
  }

  static void info(String message, {dynamic data}) {
    Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      level: SentryLevel.info,
      data: data != null ? {'value': data.toString()} : null,
    ));
  }

  static void warning(String message, {dynamic data}) {
    Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      level: SentryLevel.warning,
      data: data != null ? {'value': data.toString()} : null,
    ));
  }

  static void error(String message, {dynamic exception, StackTrace? stackTrace}) {
    Sentry.captureException(
      exception ?? message,
      stackTrace: stackTrace,
      hint: Hint.withMap({'message': message}),
    );
  }
}
