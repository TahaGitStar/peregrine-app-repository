import 'package:logger/logger.dart';

/// A utility class for logging throughout the application.
/// 
/// This class provides a centralized logging mechanism using the logger package.
/// It offers different log levels (debug, info, warning, error) for different
/// types of messages.
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Logs a debug message.
  /// 
  /// Use for detailed information, typically of interest only when diagnosing problems.
  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an info message.
  /// 
  /// Use for informational messages that highlight the progress of the application.
  static void i(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a warning message.
  /// 
  /// Use for potentially harmful situations.
  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an error message.
  /// 
  /// Use for error events that might still allow the application to continue running.
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}