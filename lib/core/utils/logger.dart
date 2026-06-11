import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Central logger for the app. 
/// Logs to console in debug, routes to Crashlytics in release.
final class AppLogger {
  AppLogger._();

  static late Logger _logger;
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;

    _logger = Logger(
      filter: kDebugMode ? DevelopmentFilter() : ProductionFilter(),
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: MultiOutput([
        ConsoleOutput(),
        if (!kDebugMode) _CrashlyticsOutput(),
      ]),
    );

    _initialized = true;
  }

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void wtf(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}

/// Routes error logs to Firebase Crashlytics in production.
class _CrashlyticsOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    if (event.level.value >= Level.error.value) {
      // FirebaseCrashlytics.instance.log(event.lines.join('\n'));
    }
  }
}
