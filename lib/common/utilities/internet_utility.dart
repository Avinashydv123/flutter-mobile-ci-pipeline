import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'logger_utility.dart';

enum ConnectionType { none, wifi, mobile, ethernet, bluetooth, vpn, other }

class InternetUtility {
  // Private constructor
  InternetUtility._();

  // Singleton instance
  static final InternetUtility _instance = InternetUtility._();

  // Getter to access the singleton instance
  static InternetUtility get instance => _instance;

  // Stream subscription for connectivity changes
  static StreamSubscription<List<ConnectivityResult>>?
  _connectivitySubscription;

  /// Check if internet is available
  static Future<bool> isInternetAvailable() async {
    try {
      final bool status = await _checkNetworkStatus();
      LoggerUtility.instance.logDebug('Internet availability check: $status');
      return status;
    } catch (e) {
      LoggerUtility.instance.logError(
        'Internet availability check exception: ${e.toString()}',
      );
      return false;
    }
  }

  /// Check if internet is available with callback
  static void checkInternetAvailability(Function(bool) completionHandler) {
    try {
      isInternetAvailable()
          .then((bool status) {
            completionHandler(status);
          })
          .catchError((error) {
            LoggerUtility.instance.logError(
              'Internet availability callback exception: ${error.toString()}',
            );
            completionHandler(false);
          });
    } catch (e) {
      LoggerUtility.instance.logError(
        'Internet connection exception: ${e.toString()}',
      );
      completionHandler(false);
    }
  }

  /// Internal method to check network status
  static Future<bool> _checkNetworkStatus() async {
    try {
      final List<ConnectivityResult> connectivityResults = await Connectivity()
          .checkConnectivity();

      // Check if any of the connectivity results indicate an active connection
      bool hasConnection = connectivityResults.any(
        (result) => result != ConnectivityResult.none,
      );

      if (hasConnection) {
        LoggerUtility.instance.logDebug(
          'Network connection detected: ${connectivityResults.map((e) => e.name).join(', ')}',
        );
      } else {
        LoggerUtility.instance.logWarning('No network connection detected');
      }

      return hasConnection;
    } catch (e) {
      LoggerUtility.instance.logError(
        'Network status check exception: ${e.toString()}',
      );
      return false;
    }
  }

  /// Get current connection type
  static Future<ConnectionType> getConnectionType() async {
    try {
      final List<ConnectivityResult> connectivityResults = await Connectivity()
          .checkConnectivity();

      if (connectivityResults.isEmpty ||
          connectivityResults.contains(ConnectivityResult.none)) {
        return ConnectionType.none;
      }

      // Return the first non-none connection type
      for (final result in connectivityResults) {
        switch (result) {
          case ConnectivityResult.wifi:
            return ConnectionType.wifi;
          case ConnectivityResult.mobile:
            return ConnectionType.mobile;
          case ConnectivityResult.ethernet:
            return ConnectionType.ethernet;
          case ConnectivityResult.bluetooth:
            return ConnectionType.bluetooth;
          case ConnectivityResult.vpn:
            return ConnectionType.vpn;
          case ConnectivityResult.other:
            return ConnectionType.other;
          case ConnectivityResult.none:
            continue;
        }
      }

      return ConnectionType.none;
    } catch (e) {
      LoggerUtility.instance.logError(
        'Get connection type exception: ${e.toString()}',
      );
      return ConnectionType.none;
    }
  }

  /// Get connection type as string
  static Future<String> getConnectionTypeString() async {
    final ConnectionType type = await getConnectionType();
    switch (type) {
      case ConnectionType.wifi:
        return 'WiFi';
      case ConnectionType.mobile:
        return 'Mobile Data';
      case ConnectionType.ethernet:
        return 'Ethernet';
      case ConnectionType.bluetooth:
        return 'Bluetooth';
      case ConnectionType.vpn:
        return 'VPN';
      case ConnectionType.other:
        return 'Other';
      case ConnectionType.none:
        return 'No Connection';
    }
  }

  /// Start listening to connectivity changes
  static void startConnectivityListener({
    required Function(bool isConnected) onConnectivityChanged,
    Function(ConnectionType type)? onConnectionTypeChanged,
  }) {
    try {
      _connectivitySubscription?.cancel();

      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
        (List<ConnectivityResult> results) {
          final bool isConnected = results.any(
            (result) => result != ConnectivityResult.none,
          );

          LoggerUtility.instance.logInfo(
            'Connectivity changed: ${results.map((e) => e.name).join(', ')}',
          );

          onConnectivityChanged(isConnected);

          if (onConnectionTypeChanged != null && results.isNotEmpty) {
            final ConnectionType type = _mapConnectivityResultToConnectionType(
              results.first,
            );
            onConnectionTypeChanged(type);
          }
        },
        onError: (error) {
          LoggerUtility.instance.logError(
            'Connectivity listener error: ${error.toString()}',
          );
          onConnectivityChanged(false);
        },
      );

      LoggerUtility.instance.logInfo('Connectivity listener started');
    } catch (e) {
      LoggerUtility.instance.logError(
        'Start connectivity listener exception: ${e.toString()}',
      );
    }
  }

  /// Stop listening to connectivity changes
  static void stopConnectivityListener() {
    try {
      _connectivitySubscription?.cancel();
      _connectivitySubscription = null;
      LoggerUtility.instance.logInfo('Connectivity listener stopped');
    } catch (e) {
      LoggerUtility.instance.logError(
        'Stop connectivity listener exception: ${e.toString()}',
      );
    }
  }

  /// Map ConnectivityResult to ConnectionType
  static ConnectionType _mapConnectivityResultToConnectionType(
    ConnectivityResult result,
  ) {
    switch (result) {
      case ConnectivityResult.wifi:
        return ConnectionType.wifi;
      case ConnectivityResult.mobile:
        return ConnectionType.mobile;
      case ConnectivityResult.ethernet:
        return ConnectionType.ethernet;
      case ConnectivityResult.bluetooth:
        return ConnectionType.bluetooth;
      case ConnectivityResult.vpn:
        return ConnectionType.vpn;
      case ConnectivityResult.other:
        return ConnectionType.other;
      case ConnectivityResult.none:
        return ConnectionType.none;
    }
  }

  /// Check internet with timeout
  static Future<bool> isInternetAvailableWithTimeout({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final bool result = await isInternetAvailable().timeout(
        timeout,
        onTimeout: () {
          LoggerUtility.instance.logWarning(
            'Internet check timed out after ${timeout.inSeconds} seconds',
          );
          return false;
        },
      );
      return result;
    } catch (e) {
      LoggerUtility.instance.logError(
        'Internet check with timeout exception: ${e.toString()}',
      );
      return false;
    }
  }

  /// Dispose method to clean up resources
  static void dispose() {
    stopConnectivityListener();
  }
}
