import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'text_utility.dart';

enum LogLevel { debug, info, warning, error }

class LoggerUtility {
  // Private constructor
  LoggerUtility._();

  // Singleton instance
  static final LoggerUtility _instance = LoggerUtility._();

  // Getter to access the singleton instance
  static LoggerUtility get instance => _instance;

  // Static properties
  static bool _isFirstTimeInstall = true;
  static String _latestLogFilePath = '';
  static const String _logFileName = 'hindus_r_us_logs.txt';

  // Public getters
  static String get latestLogFilePath => _latestLogFilePath;

  // Factory constructor
  factory LoggerUtility() {
    if (_isFirstTimeInstall) {
      _isFirstTimeInstall = false;
      _instance._initializeLogger();
    }
    return _instance;
  }

  /// Initialize logger and log device info
  void _initializeLogger() {
    unawaited(_logDeviceInfo());
  }

  /// Get the local file path for logs
  Future<String> _getLocalFilePath() async {
    try {
      Directory appDocumentsDirectory;

      // Try different directory options based on platform
      try {
        appDocumentsDirectory = await getApplicationDocumentsDirectory();
      } catch (e) {
        debugPrint('Failed to get application documents directory: $e');

        // Fallback to application support directory
        try {
          appDocumentsDirectory = await getApplicationSupportDirectory();
        } catch (e2) {
          debugPrint('Failed to get application support directory: $e2');

          // Final fallback to temporary directory
          appDocumentsDirectory = await getTemporaryDirectory();
        }
      }

      String appDocumentsPath = appDocumentsDirectory.path;
      String filePath = '$appDocumentsPath/$_logFileName';
      _latestLogFilePath = filePath;
      return filePath;
    } catch (e) {
      debugPrint('Error getting log file path: $e');
      return '';
    }
  }

  /// Read the entire log file content
  Future<String> readLogFile() async {
    try {
      String filePath = await _getLocalFilePath();
      if (filePath.isEmpty) {
        return 'Log file path not available';
      }

      File file = File(filePath);
      if (await file.exists()) {
        String fileContent = await file.readAsString();
        return fileContent;
      }
      return 'No logs found';
    } catch (e) {
      debugPrint('Error reading log file: $e');
      return 'Error reading logs: $e';
    }
  }

  /// Clear all logs
  Future<void> clearLogs() async {
    try {
      String filePath = await _getLocalFilePath();
      if (filePath.isEmpty) {
        debugPrint('Cannot clear logs: path is empty');
        return;
      }

      File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        _logInfo('Log file cleared');
      }
    } catch (e) {
      debugPrint('Error clearing logs: $e');
    }
  }

  /// Write data to local storage with timestamp
  void _writeToLocalStorage(String data, LogLevel level) async {
    try {
      if (kDebugMode) {
        // Also print to console in debug mode
        debugPrint('${level.name.toUpperCase()}: $data');
      }

      String filePath = await _getLocalFilePath();
      if (filePath.isEmpty) {
        debugPrint('Cannot write to log file: path is empty');
        return;
      }

      File file = File(filePath);
      final DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm:ss a');
      final String timestamp = formatter.format(DateTime.now());
      final String logEntry =
          '[${level.name.toUpperCase()}] $data - $timestamp\n';

      // Ensure directory exists
      await file.parent.create(recursive: true);
      await file.writeAsString(logEntry, mode: FileMode.append);
    } catch (e) {
      debugPrint('Error writing to log file: $e');
    }
  }

  /// Log device information
  Future<void> _logDeviceInfo() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        final deviceData = {
          'brand': androidInfo.brand,
          'model': androidInfo.model,
          'product': androidInfo.product,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
        };
        _logInfo('Android Device Info: $deviceData');
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        final deviceData = {
          'name': iosInfo.name,
          'model': iosInfo.model,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
        };
        _logInfo('iOS Device Info: $deviceData');
      }

      _logInfo('${TextUtility.appName} app started');

      // Add a small delay to ensure logging is completed
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      logError('Failed to get device info: $e');
    }
  }

  /// Log debug messages
  void logDebug(String message) {
    _writeToLocalStorage(message, LogLevel.debug);
  }

  /// Log info messages
  void _logInfo(String message) {
    _writeToLocalStorage(message, LogLevel.info);
  }

  /// Log info messages (public method)
  void logInfo(String message) {
    _writeToLocalStorage(message, LogLevel.info);
  }

  /// Log warning messages
  void logWarning(String message) {
    _writeToLocalStorage(message, LogLevel.warning);
  }

  /// Log error messages
  void logError(String error) {
    _writeToLocalStorage(error, LogLevel.error);
  }

  /// Log authentication events
  void logAuth(String event) {
    logInfo('AUTH: $event');
  }

  /// Log navigation events
  void logNavigation(String route) {
    logInfo('NAVIGATION: Navigated to $route');
  }

  /// Log API calls
  void logApiCall(String endpoint, {String? method, int? statusCode}) {
    final methodStr = method ?? 'GET';
    final statusStr = statusCode != null ? ' - Status: $statusCode' : '';
    logInfo('API: $methodStr $endpoint$statusStr');
  }

  /// Log user actions
  void logUserAction(String action) {
    logInfo('USER_ACTION: $action');
  }

  /// Get log file size in bytes
  Future<int> getLogFileSize() async {
    try {
      String filePath = await _getLocalFilePath();
      if (filePath.isEmpty) {
        return 0;
      }

      File file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      debugPrint('Error getting log file size: $e');
      return 0;
    }
  }

  /// Check if log file exists
  Future<bool> logFileExists() async {
    try {
      String filePath = await _getLocalFilePath();
      if (filePath.isEmpty) {
        return false;
      }

      File file = File(filePath);
      return await file.exists();
    } catch (e) {
      debugPrint('Error checking log file existence: $e');
      return false;
    }
  }
}
