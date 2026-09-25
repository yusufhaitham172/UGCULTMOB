import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../constants/app_constants.dart';

/// Sentry Crash Reporting & Error Telemetry Service
abstract final class SentryService {
  static bool _isInitialized = false;

  static Future<void> initialize(AppRunner appRunner) async {
    final dsn = AppConstants.sentryDsn;
    if (dsn.isEmpty) {
      if (kDebugMode) {
        debugPrint('[SentryService] Sentry DSN not provided. Running app without Sentry.');
      }
      appRunner();
      return;
    }

    try {
      await SentryFlutter.init(
        (options) {
          options.dsn = dsn;
          options.tracesSampleRate = 1.0;
          options.enableAutoPerformanceTracing = true;
          options.environment = kReleaseMode ? 'production' : 'development';
        },
        appRunner: appRunner,
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('[SentryService] Failed to initialize Sentry: $e');
      appRunner();
    }
  }

  static void captureException(
    dynamic exception, {
    dynamic stackTrace,
    String? hint,
  }) {
    if (kDebugMode) {
      debugPrint('[Error] $exception\n$stackTrace');
    }
    if (_isInitialized) {
      Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        hint: hint != null ? Hint.withMap({'info': hint}) : null,
      );
    }
  }
}
