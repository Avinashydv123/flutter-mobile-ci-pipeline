import 'dart:async';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'logger_utility.dart';

/// Hive database utility class providing a clean interface for database operations
/// Based on Hive documentation: https://pub.dev/packages/hive
class HiveUtility {
  // Private constructor
  HiveUtility._();

  // Singleton instance
  static final HiveUtility _instance = HiveUtility._();

  // Getter to access the singleton instance
  static HiveUtility get instance => _instance;

  // Static properties
  static bool _isInitialized = false;
  static String _databasePath = '';

  // Common box names - centralized box management
  static const String userPreferencesBox = 'user_preferences';
  static const String userDataBox = 'user_data';
  static const String cacheBox = 'cache';
  static const String settingsBox = 'settings';
  static const String authBox = 'auth';

  // Getters
  static bool get isInitialized => _isInitialized;
  static String get databasePath => _databasePath;

  /// Initialize Hive database
  /// Must be called before any other Hive operations
  Future<void> initialize() async {
    if (_isInitialized) {
      LoggerUtility.instance.logWarning('Hive already initialized');
      return;
    }

    try {
      LoggerUtility.instance.logInfo('Initializing Hive database...');

      // Get the application documents directory with timeout
      final Directory appDocumentsDirectory = await _getAppDirectory().timeout(
        const Duration(seconds: 10),
      );
      _databasePath = appDocumentsDirectory.path;

      // Initialize Hive with the path
      Hive.init(_databasePath);

      LoggerUtility.instance.logInfo('Hive initialized at: $_databasePath');

      _isInitialized = true;

      // Register custom adapters if needed
      await _registerAdapters();

      LoggerUtility.instance.logInfo('Hive database initialization completed');
    } catch (error) {
      LoggerUtility.instance.logError('Failed to initialize Hive: $error');
      // Don't rethrow to prevent app crash, use fallback
      _isInitialized = true; // Mark as initialized to prevent retry loops
    }
  }

  /// Get application directory with fallback options
  Future<Directory> _getAppDirectory() async {
    try {
      return await getApplicationDocumentsDirectory();
    } catch (e) {
      LoggerUtility.instance.logWarning(
        'Failed to get documents directory: $e',
      );
      try {
        return await getApplicationSupportDirectory();
      } catch (e2) {
        LoggerUtility.instance.logWarning(
          'Failed to get support directory: $e2',
        );
        return await getTemporaryDirectory();
      }
    }
  }

  /// Register custom adapters for complex objects
  Future<void> _registerAdapters() async {
    try {
      // Example: Register a User adapter
      // Hive.registerAdapter(UserAdapter());

      LoggerUtility.instance.logDebug('Custom adapters registered');
    } catch (error) {
      LoggerUtility.instance.logError('Failed to register adapters: $error');
    }
  }

  /// Open a box with the given name
  /// Optionally specify a type for type safety
  Future<Box<T>> openBox<T>(String boxName, {bool encrypted = false}) async {
    _ensureInitialized();

    try {
      LoggerUtility.instance.logDebug('Opening box: $boxName');

      final Box<T> box = encrypted && _getEncryptionKey() != null
          ? await Hive.openBox<T>(
              boxName,
              encryptionCipher: HiveAesCipher(_getEncryptionKey()!),
            )
          : await Hive.openBox<T>(boxName);

      LoggerUtility.instance.logDebug('Box opened successfully: $boxName');
      return box;
    } catch (error) {
      LoggerUtility.instance.logError('Failed to open box $boxName: $error');
      rethrow;
    }
  }

  /// Get an already opened box
  Box<T> getBox<T>(String boxName) {
    _ensureInitialized();

    try {
      return Hive.box<T>(boxName);
    } catch (error) {
      LoggerUtility.instance.logError('Failed to get box $boxName: $error');
      rethrow;
    }
  }

  /// Check if a box is already open
  bool isBoxOpen(String boxName) {
    _ensureInitialized();
    return Hive.isBoxOpen(boxName);
  }

  /// Close a specific box
  Future<void> closeBox(String boxName) async {
    _ensureInitialized();

    try {
      if (isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        await box.close();
        LoggerUtility.instance.logDebug('Box closed: $boxName');
      }
    } catch (error) {
      LoggerUtility.instance.logError('Failed to close box $boxName: $error');
    }
  }

  /// Close all open boxes
  Future<void> closeAllBoxes() async {
    _ensureInitialized();

    try {
      await Hive.close();
      LoggerUtility.instance.logInfo('All Hive boxes closed');
    } catch (error) {
      LoggerUtility.instance.logError('Failed to close all boxes: $error');
    }
  }

  /// Delete a box and all its data
  Future<void> deleteBox(String boxName) async {
    _ensureInitialized();

    try {
      await closeBox(boxName);
      await Hive.deleteBoxFromDisk(boxName);
      LoggerUtility.instance.logInfo('Box deleted: $boxName');
    } catch (error) {
      LoggerUtility.instance.logError('Failed to delete box $boxName: $error');
    }
  }

  /// CRUD Operations

  /// Store a value in a box
  Future<void> put<T>(String boxName, String key, T value) async {
    try {
      final box = await _ensureBoxOpen<T>(boxName);
      await box.put(key, value);
      LoggerUtility.instance.logDebug('Stored key: $key in box: $boxName');
    } catch (error) {
      LoggerUtility.instance.logError('Failed to put $key in $boxName: $error');
      rethrow;
    }
  }

  /// Get a value from a box
  T? get<T>(String boxName, String key, {T? defaultValue}) {
    try {
      final box = getBox<T>(boxName);
      final value = box.get(key, defaultValue: defaultValue);
      LoggerUtility.instance.logDebug('Retrieved key: $key from box: $boxName');
      return value;
    } catch (error) {
      LoggerUtility.instance.logError(
        'Failed to get $key from $boxName: $error',
      );
      return defaultValue;
    }
  }

  /// Delete a key from a box
  Future<void> delete(String boxName, String key) async {
    try {
      final box = await _ensureBoxOpen(boxName);
      await box.delete(key);
      LoggerUtility.instance.logDebug('Deleted key: $key from box: $boxName');
    } catch (error) {
      LoggerUtility.instance.logError(
        'Failed to delete $key from $boxName: $error',
      );
    }
  }

  /// Check if a key exists in a box
  bool containsKey(String boxName, String key) {
    try {
      final box = getBox(boxName);
      return box.containsKey(key);
    } catch (error) {
      LoggerUtility.instance.logError(
        'Failed to check key $key in $boxName: $error',
      );
      return false;
    }
  }

  /// Get all keys from a box
  List<String> getKeys(String boxName) {
    try {
      final box = getBox(boxName);
      return box.keys.cast<String>().toList();
    } catch (error) {
      LoggerUtility.instance.logError(
        'Failed to get keys from $boxName: $error',
      );
      return [];
    }
  }

  /// Get all values from a box
  List<T> getValues<T>(String boxName) {
    try {
      final box = getBox<T>(boxName);
      return box.values.toList();
    } catch (error) {
      LoggerUtility.instance.logError(
        'Failed to get values from $boxName: $error',
      );
      return [];
    }
  }

  /// Clear all data from a box
  Future<void> clear(String boxName) async {
    try {
      final box = await _ensureBoxOpen(boxName);
      await box.clear();
      LoggerUtility.instance.logInfo('Cleared all data from box: $boxName');
    } catch (error) {
      LoggerUtility.instance.logError('Failed to clear box $boxName: $error');
    }
  }

  /// Get the number of entries in a box
  int getLength(String boxName) {
    try {
      final box = getBox(boxName);
      return box.length;
    } catch (error) {
      LoggerUtility.instance.logError(
        'Failed to get length of $boxName: $error',
      );
      return 0;
    }
  }

  /// Transaction operations

  /// Perform multiple operations in a transaction
  /// Note: Hive 2.x doesn't have explicit transactions, operations are atomic by default
  Future<T> transaction<T>(
    String boxName,
    Future<T> Function(Box box) operation,
  ) async {
    try {
      final box = await _ensureBoxOpen(boxName);
      final result = await operation(box);

      LoggerUtility.instance.logDebug(
        'Transaction completed for box: $boxName',
      );
      return result;
    } catch (error) {
      LoggerUtility.instance.logError(
        'Transaction failed for $boxName: $error',
      );
      rethrow;
    }
  }

  /// Bulk operations

  /// Store multiple key-value pairs
  Future<void> putAll<T>(String boxName, Map<String, T> entries) async {
    try {
      final box = await _ensureBoxOpen<T>(boxName);
      await box.putAll(entries);
      LoggerUtility.instance.logDebug(
        'Stored ${entries.length} entries in box: $boxName',
      );
    } catch (error) {
      LoggerUtility.instance.logError(
        'Failed to put all entries in $boxName: $error',
      );
      rethrow;
    }
  }

  /// Delete multiple keys
  Future<void> deleteAll(String boxName, List<String> keys) async {
    try {
      final box = await _ensureBoxOpen(boxName);
      await box.deleteAll(keys);
      LoggerUtility.instance.logDebug(
        'Deleted ${keys.length} keys from box: $boxName',
      );
    } catch (error) {
      LoggerUtility.instance.logError(
        'Failed to delete all keys from $boxName: $error',
      );
    }
  }

  /// User Preferences helpers

  /// Store user preference
  Future<void> setUserPreference<T>(String key, T value) async {
    await put(userPreferencesBox, key, value);
  }

  /// Get user preference
  T? getUserPreference<T>(String key, {T? defaultValue}) {
    return get(userPreferencesBox, key, defaultValue: defaultValue);
  }

  /// Store user data
  Future<void> setUserData<T>(String key, T value) async {
    await put(userDataBox, key, value);
  }

  /// Get user data
  T? getUserData<T>(String key, {T? defaultValue}) {
    return get(userDataBox, key, defaultValue: defaultValue);
  }

  /// Cache helpers

  /// Store cache data with optional expiry
  Future<void> setCache<T>(String key, T value, {Duration? expiry}) async {
    final cacheData = {
      'value': value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry': expiry?.inMilliseconds,
    };
    await put(cacheBox, key, cacheData);
  }

  /// Get cache data (returns null if expired)
  T? getCache<T>(String key) {
    final cacheData = get<Map>(cacheBox, key);
    if (cacheData == null) return null;

    final timestamp = cacheData['timestamp'] as int?;
    final expiry = cacheData['expiry'] as int?;

    if (expiry != null && timestamp != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - timestamp > expiry) {
        // Cache expired, delete it
        delete(cacheBox, key);
        return null;
      }
    }

    return cacheData['value'] as T?;
  }

  /// Utility methods

  /// Get database size information
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final Directory dir = Directory(_databasePath);
      final List<FileSystemEntity> files = dir.listSync();

      int totalSize = 0;
      int fileCount = 0;

      for (final file in files) {
        if (file is File && file.path.endsWith('.hive')) {
          totalSize += await file.length();
          fileCount++;
        }
      }

      return {
        'totalSize': totalSize,
        'fileCount': fileCount,
        'path': _databasePath,
        'isInitialized': _isInitialized,
      };
    } catch (error) {
      LoggerUtility.instance.logError('Failed to get database info: $error');
      return {};
    }
  }

  /// Backup database to a specific path
  Future<bool> backupDatabase(String backupPath) async {
    try {
      final Directory sourceDir = Directory(_databasePath);
      final Directory backupDir = Directory(backupPath);

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final List<FileSystemEntity> files = sourceDir.listSync();

      for (final file in files) {
        if (file is File && file.path.endsWith('.hive')) {
          final String fileName = file.path.split('/').last;
          await file.copy('${backupDir.path}/$fileName');
        }
      }

      LoggerUtility.instance.logInfo('Database backed up to: $backupPath');
      return true;
    } catch (error) {
      LoggerUtility.instance.logError('Failed to backup database: $error');
      return false;
    }
  }

  /// Private helper methods

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('HiveUtility not initialized. Call initialize() first.');
    }
  }

  Future<Box<T>> _ensureBoxOpen<T>(String boxName) async {
    if (!isBoxOpen(boxName)) {
      return await openBox<T>(boxName);
    }

    try {
      return getBox<T>(boxName);
    } catch (error) {
      // If there's a type mismatch, close the box and reopen with correct type
      LoggerUtility.instance.logWarning(
        'Box type mismatch for $boxName, reopening with correct type: $error',
      );
      await closeBox(boxName);
      return await openBox<T>(boxName);
    }
  }

  /// Generate encryption key (implement your own key generation logic)
  List<int>? _getEncryptionKey() {
    // For production, implement secure key generation/storage using:
    // - flutter_secure_storage for key storage
    // - crypto package for key generation
    // - Consider using device-specific identifiers

    // For now, returning null (no encryption)
    // When implementing, use a 32-byte key for AES-256
    return null;
  }

  /// Initialize common boxes
  Future<void> initializeCommonBoxes() async {
    try {
      await openBox(userPreferencesBox);
      await openBox(userDataBox);
      await openBox(cacheBox);
      await openBox(settingsBox);
      await openBox(authBox);

      LoggerUtility.instance.logInfo('Common boxes initialized');
    } catch (error) {
      LoggerUtility.instance.logError(
        'Failed to initialize common boxes: $error',
      );
    }
  }

  /// Clean up expired cache entries
  Future<void> cleanExpiredCache() async {
    try {
      final box = getBox(cacheBox);
      final keys = box.keys.cast<String>().toList();
      final keysToDelete = <String>[];

      for (final key in keys) {
        final cacheData = box.get(key) as Map?;
        if (cacheData != null) {
          final timestamp = cacheData['timestamp'] as int?;
          final expiry = cacheData['expiry'] as int?;

          if (expiry != null && timestamp != null) {
            final now = DateTime.now().millisecondsSinceEpoch;
            if (now - timestamp > expiry) {
              keysToDelete.add(key);
            }
          }
        }
      }

      if (keysToDelete.isNotEmpty) {
        await deleteAll(cacheBox, keysToDelete);
        LoggerUtility.instance.logInfo(
          'Cleaned ${keysToDelete.length} expired cache entries',
        );
      }
    } catch (error) {
      LoggerUtility.instance.logError('Failed to clean expired cache: $error');
    }
  }

  /// Clean up all user-related data for a specific UID
  Future<void> cleanupUserData(String uid) async {
    try {
      LoggerUtility.instance.logInfo('Cleaning up user data for UID: $uid');

      // Use consistent box access
      final userBox = isBoxOpen(userDataBox)
          ? getBox(userDataBox)
          : await openBox(userDataBox);

      final stringBox = isBoxOpen('user_data_strings')
          ? getBox<String>('user_data_strings')
          : await openBox<String>('user_data_strings');

      // Remove user profile data
      await userBox.delete('profile_$uid');

      // Remove current user UID if it matches
      final String? storedUid = stringBox.get('current_user_uid');
      if (storedUid == uid) {
        await stringBox.delete('current_user_uid');
      }

      // Clean up any other user-specific data
      await cleanUserSpecificCache(uid);

      LoggerUtility.instance.logInfo(
        'User data cleanup completed for UID: $uid',
      );
    } catch (error) {
      LoggerUtility.instance.logError(
        'Failed to cleanup user data for $uid: $error',
      );
    }
  }

  /// Clean up user-specific cache entries
  Future<void> cleanUserSpecificCache(String uid) async {
    try {
      final box = getBox(cacheBox);
      final keys = box.keys.cast<String>().toList();
      final keysToDelete = <String>[];

      for (final key in keys) {
        // Remove cache entries that contain the user's UID
        if (key.contains(uid)) {
          keysToDelete.add(key);
        }
      }

      if (keysToDelete.isNotEmpty) {
        await deleteAll(cacheBox, keysToDelete);
        LoggerUtility.instance.logInfo(
          'Cleaned ${keysToDelete.length} user-specific cache entries',
        );
      }
    } catch (error) {
      LoggerUtility.instance.logError(
        'Failed to clean user-specific cache: $error',
      );
    }
  }

  /// Check if user data exists for a specific UID
  Future<bool> hasUserData(String uid) async {
    try {
      final userBox = isBoxOpen(userDataBox)
          ? getBox(userDataBox)
          : await openBox(userDataBox);

      return userBox.containsKey('profile_$uid');
    } catch (error) {
      LoggerUtility.instance.logError(
        'Failed to check user data existence: $error',
      );
      return false;
    }
  }
}
